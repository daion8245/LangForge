// Generates assets/pack/pack.png — the default resource pack icon.
//
// Run from the project root:
//   dart run tool/generate_pack_icon.dart
//
// The output is committed. This script exists so the icon can be regenerated
// deterministically instead of being an opaque binary nobody can edit.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Minecraft displays pack icons at 32px but ships them at 128px.
const int iconSize = 128;

/// Drawn at 4x and averaged down, which is cheaper than writing a real
/// rasteriser and gives clean edges on the diagonals.
const int supersample = 4;

// DESIGN.md 2.1 / 2.5.
const Rgba background = Rgba(0x16, 0x16, 0x16);
const Rgba border = Rgba(0x2C, 0x2C, 0x2C);
const Rgba accent = Rgba(0x4F, 0xC0, 0xA1);
const Rgba accentDim = Rgba(0x3D, 0x4F, 0x4A);

void main() {
  final canvas = Canvas(iconSize * supersample, iconSize * supersample)
    ..fill(background);

  _draw(canvas);

  final image = canvas.downsample(supersample);
  final png = _encodePng(image);

  final file = File('assets/pack/pack.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(png);

  stdout.writeln(
    'Wrote ${file.path} (${png.length} bytes, '
    '${iconSize}x$iconSize)',
  );
}

/// The mark: two chevrons pointing right — source language flowing into
/// target — over a solid accent underline.
void _draw(Canvas c) {
  final s = supersample.toDouble();
  final size = iconSize * s;

  // A hairline inset border keeps the icon from bleeding into dark launcher
  // backgrounds.
  c.strokeRect(
    left: 2 * s,
    top: 2 * s,
    right: size - 2 * s,
    bottom: size - 2 * s,
    thickness: 2 * s,
    color: border,
  );

  const chevronThickness = 11.0;
  const chevronHeight = 34.0;
  final centerY = 54.0 * s;

  _chevron(
    c,
    tipX: 62.0 * s,
    centerY: centerY,
    height: chevronHeight * s,
    thickness: chevronThickness * s,
    color: accentDim,
  );
  _chevron(
    c,
    tipX: 88.0 * s,
    centerY: centerY,
    height: chevronHeight * s,
    thickness: chevronThickness * s,
    color: accent,
  );

  c.fillRect(
    left: 34 * s,
    top: 92 * s,
    right: 94 * s,
    bottom: 100 * s,
    color: accent,
  );
}

/// A `>` shape: two strokes meeting at [tipX].
void _chevron(
  Canvas c, {
  required double tipX,
  required double centerY,
  required double height,
  required double thickness,
  required Rgba color,
}) {
  final halfHeight = height / 2;
  final startX = tipX - halfHeight;

  c.strokeLine(
    x0: startX,
    y0: centerY - halfHeight,
    x1: tipX,
    y1: centerY,
    thickness: thickness,
    color: color,
  );
  c.strokeLine(
    x0: startX,
    y0: centerY + halfHeight,
    x1: tipX,
    y1: centerY,
    thickness: thickness,
    color: color,
  );
}

class Rgba {
  const Rgba(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;

  /// The icon is fully opaque; alpha exists only because PNG RGBA needs it.
  static const int a = 255;
}

class Canvas {
  Canvas(this.width, this.height) : pixels = Uint8List(width * height * 4);

  final int width;
  final int height;
  final Uint8List pixels;

  void fill(Rgba color) {
    for (var i = 0; i < pixels.length; i += 4) {
      pixels[i] = color.r;
      pixels[i + 1] = color.g;
      pixels[i + 2] = color.b;
      pixels[i + 3] = Rgba.a;
    }
  }

  void setPixel(int x, int y, Rgba color) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final i = (y * width + x) * 4;
    pixels[i] = color.r;
    pixels[i + 1] = color.g;
    pixels[i + 2] = color.b;
    pixels[i + 3] = Rgba.a;
  }

  void fillRect({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Rgba color,
  }) {
    for (var y = top.floor(); y < bottom.ceil(); y++) {
      for (var x = left.floor(); x < right.ceil(); x++) {
        setPixel(x, y, color);
      }
    }
  }

  void strokeRect({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double thickness,
    required Rgba color,
  }) {
    fillRect(
      left: left,
      top: top,
      right: right,
      bottom: top + thickness,
      color: color,
    );
    fillRect(
      left: left,
      top: bottom - thickness,
      right: right,
      bottom: bottom,
      color: color,
    );
    fillRect(
      left: left,
      top: top,
      right: left + thickness,
      bottom: bottom,
      color: color,
    );
    fillRect(
      left: right - thickness,
      top: top,
      right: right,
      bottom: bottom,
      color: color,
    );
  }

  /// Round-capped line, drawn by testing each pixel's distance to the segment.
  void strokeLine({
    required double x0,
    required double y0,
    required double x1,
    required double y1,
    required double thickness,
    required Rgba color,
  }) {
    final radius = thickness / 2;
    final minX = math.min(x0, x1) - radius;
    final maxX = math.max(x0, x1) + radius;
    final minY = math.min(y0, y1) - radius;
    final maxY = math.max(y0, y1) + radius;

    final dx = x1 - x0;
    final dy = y1 - y0;
    final lengthSquared = dx * dx + dy * dy;

    for (var y = minY.floor(); y <= maxY.ceil(); y++) {
      for (var x = minX.floor(); x <= maxX.ceil(); x++) {
        final px = x + 0.5;
        final py = y + 0.5;

        var t = lengthSquared == 0
            ? 0.0
            : ((px - x0) * dx + (py - y0) * dy) / lengthSquared;
        t = t.clamp(0.0, 1.0);

        final nearestX = x0 + t * dx;
        final nearestY = y0 + t * dy;
        final distX = px - nearestX;
        final distY = py - nearestY;

        if (distX * distX + distY * distY <= radius * radius) {
          setPixel(x, y, color);
        }
      }
    }
  }

  /// Box filter down by [factor], which is what turns the hard supersampled
  /// edges into antialiased ones.
  Image downsample(int factor) {
    final outWidth = width ~/ factor;
    final outHeight = height ~/ factor;
    final out = Uint8List(outWidth * outHeight * 4);
    final samples = factor * factor;

    for (var y = 0; y < outHeight; y++) {
      for (var x = 0; x < outWidth; x++) {
        var r = 0, g = 0, b = 0, a = 0;
        for (var sy = 0; sy < factor; sy++) {
          for (var sx = 0; sx < factor; sx++) {
            final i = ((y * factor + sy) * width + (x * factor + sx)) * 4;
            r += pixels[i];
            g += pixels[i + 1];
            b += pixels[i + 2];
            a += pixels[i + 3];
          }
        }
        final o = (y * outWidth + x) * 4;
        out[o] = r ~/ samples;
        out[o + 1] = g ~/ samples;
        out[o + 2] = b ~/ samples;
        out[o + 3] = a ~/ samples;
      }
    }

    return Image(outWidth, outHeight, out);
  }
}

class Image {
  const Image(this.width, this.height, this.rgba);

  final int width;
  final int height;
  final Uint8List rgba;
}

/// Minimal PNG writer: IHDR, IDAT, IEND with 8-bit RGBA and no interlacing.
Uint8List _encodePng(Image image) {
  final out = BytesBuilder();
  out.add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  final ihdr = BytesBuilder()
    ..add(_uint32(image.width))
    ..add(_uint32(image.height))
    ..addByte(8) // bit depth
    ..addByte(6) // colour type: RGBA
    ..addByte(0) // deflate
    ..addByte(0) // adaptive filtering
    ..addByte(0); // no interlace
  out.add(_chunk('IHDR', ihdr.takeBytes()));

  // Every scanline is prefixed with filter type 0 (None).
  final raw = BytesBuilder();
  final stride = image.width * 4;
  for (var y = 0; y < image.height; y++) {
    raw.addByte(0);
    raw.add(Uint8List.sublistView(image.rgba, y * stride, (y + 1) * stride));
  }
  out.add(_chunk('IDAT', ZLibEncoder().encode(raw.takeBytes())));

  out.add(_chunk('IEND', Uint8List(0)));
  return out.takeBytes();
}

Uint8List _chunk(String type, List<int> data) {
  final typeBytes = ascii.encode(type);
  final body = Uint8List.fromList([...typeBytes, ...data]);

  final out = BytesBuilder()
    ..add(_uint32(data.length))
    ..add(body)
    ..add(_uint32(getCrc32(body)));
  return out.takeBytes();
}

Uint8List _uint32(int value) {
  final bytes = Uint8List(4);
  ByteData.view(bytes.buffer).setUint32(0, value);
  return bytes;
}
