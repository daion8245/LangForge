#!/usr/bin/env python3
"""Generate LangForge app icon PNG/ICO from DESIGN.md 12.1 geometry.

  python tool/generate_app_icon.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
BG = (0x10, 0x23, 0x1E, 255)
FG = (0x4F, 0xC0, 0xA1, 255)

# Master design space.
SIZE = 256


def _scale(points: list[tuple[float, float]], s: float) -> list[tuple[float, float]]:
    return [(x * s, y * s) for x, y in points]


def draw_icon(size: int) -> Image.Image:
    """Rasterize the icon into a square RGBA image."""
    img = Image.new('RGBA', (size, size), BG)
    draw = ImageDraw.Draw(img)
    s = size / SIZE
    stroke = max(1, round(14 * s))
    # DESIGN: line thickness at least 1/16 of canvas.
    stroke = max(stroke, max(1, size // 16))

    def line(a: tuple[float, float], b: tuple[float, float]) -> None:
        draw.line([a[0] * s, a[1] * s, b[0] * s, b[1] * s], fill=FG, width=stroke, joint='curve')

    def poly(points: list[tuple[float, float]]) -> None:
        draw.polygon(_scale(points, s), fill=FG)

    def rounded_rect(xy: tuple[float, float, float, float], radius: float) -> None:
        x0, y0, x1, y1 = (v * s for v in xy)
        r = max(1, radius * s)
        draw.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=FG)

    # --- Language mark A → 가 (simplified further below 24px) ---
    if size >= 24:
        # A
        line((36, 92), (56, 40))
        line((56, 40), (76, 92))
        line((44, 74), (68, 74))
        # arrow (shorter axis under 48px)
        if size < 48:
            line((88, 66), (118, 66))
            line((106, 54), (120, 66))
            line((106, 78), (120, 66))
        else:
            line((92, 66), (132, 66))
            line((118, 50), (134, 66))
            line((118, 82), (134, 66))
        # 가 = ㄱ + ㅏ
        line((152, 44), (196, 44))
        line((196, 44), (196, 92))
        line((214, 44), (214, 92))
        line((214, 68), (234, 68))
    else:
        # 16px: keep A and 가, drop arrow shaft length to a gap mark.
        tiny = max(1, size // 16)
        draw.line([(3 * tiny, 5 * tiny), (5 * tiny, 2 * tiny), (7 * tiny, 5 * tiny)], fill=FG, width=tiny)
        draw.line([(3.5 * tiny, 4 * tiny), (6.5 * tiny, 4 * tiny)], fill=FG, width=tiny)
        draw.line([(9 * tiny, 3.5 * tiny), (10.5 * tiny, 3.5 * tiny)], fill=FG, width=tiny)
        draw.line([(12 * tiny, 2.5 * tiny), (14.5 * tiny, 2.5 * tiny), (14.5 * tiny, 5.5 * tiny)], fill=FG, width=tiny)

    # --- Anvil ---
    # Horn + face
    poly(
        [
            (40, 118),
            (48, 108),
            (58, 104),
            (188, 104),
            (210, 108),
            (228, 124),
            (222, 140),
            (52, 140),
            (42, 132),
        ]
    )
    # Neck
    rounded_rect((100, 140, 156, 176), 4)
    # Base body
    poly([(72, 176), (184, 176), (196, 208), (60, 208)])
    # Foot
    rounded_rect((48, 204, 208, 222), 4)

    return img


def write_ico(path: Path, sizes: list[int]) -> None:
    """Write a multi-resolution ICO with one BMP entry per size.

    Pillow's ICO saver often keeps only a single frame; pack manually so
    Windows Explorer can pick 16 through 256 cleanly.
    """
    import struct
    from io import BytesIO

    images = [draw_icon(s).convert('RGBA') for s in sizes]
    payloads: list[bytes] = []
    for im in images:
        # ICO bitmap payload: BITMAPINFOHEADER + BGRA pixels (bottom-up) + AND mask.
        w, h = im.size
        pixels = im.split()  # R,G,B,A
        bgra = Image.merge('RGBA', (pixels[2], pixels[1], pixels[0], pixels[3]))
        row_stride = w * 4
        raw = bgra.tobytes()
        # Bottom-up DIB rows.
        flipped = b''.join(raw[y * row_stride : (y + 1) * row_stride] for y in range(h - 1, -1, -1))
        # AND mask: 1 bit/pixel, rows padded to 32 bits, bottom-up. Fully opaque → zeros.
        mask_row = ((w + 31) // 32) * 4
        and_mask = b'\x00' * (mask_row * h)
        header = struct.pack(
            '<IiiHHIIiiII',
            40,  # biSize
            w,
            h * 2,  # height includes AND mask
            1,  # planes
            32,  # bit count
            0,  # BI_RGB
            len(flipped) + len(and_mask),
            0,
            0,
            0,
            0,
        )
        payloads.append(header + flipped + and_mask)

    # ICONDIR + ICONDIRENTRY[] + payloads
    count = len(images)
    offset = 6 + 16 * count
    buf = BytesIO()
    buf.write(struct.pack('<HHH', 0, 1, count))
    for im, payload in zip(images, payloads, strict=True):
        w = 0 if im.width >= 256 else im.width
        h = 0 if im.height >= 256 else im.height
        buf.write(struct.pack('<BBBBHHII', w, h, 0, 0, 1, 32, len(payload), offset))
        offset += len(payload)
    for payload in payloads:
        buf.write(payload)
    path.write_bytes(buf.getvalue())


def main() -> None:
    icons_dir = ROOT / 'assets' / 'icons'
    icons_dir.mkdir(parents=True, exist_ok=True)
    runner_res = ROOT / 'windows' / 'runner' / 'resources'
    runner_res.mkdir(parents=True, exist_ok=True)

    # In-app / docs preview asset.
    draw_icon(256).save(icons_dir / 'app_icon.png', format='PNG')

    ico_sizes = [16, 24, 32, 48, 64, 128, 256]
    write_ico(runner_res / 'app_icon.ico', ico_sizes)
    # Keep a copy next to the SVG master for packaging/docs.
    write_ico(icons_dir / 'app_icon.ico', ico_sizes)

    print(f'wrote {icons_dir / "app_icon.png"}')
    print(f'wrote {runner_res / "app_icon.ico"} ({", ".join(str(s) for s in ico_sizes)})')
    print(f'wrote {icons_dir / "app_icon.ico"}')


if __name__ == '__main__':
    main()
