import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show TargetPlatform, visibleForTesting;

/// Which host the app is actually running on.
///
/// Deliberately `dart:io`, not `defaultTargetPlatform`: that one answers "which
/// design language should this widget use", and `flutter_test` pins it to
/// Android for every widget test. Choosing the mobile shell off it would put
/// the desktop suite on the phone layout.
abstract final class AppPlatform {
  static TargetPlatform? _override;

  /// Pretends the app is on [platform] for the length of a test.
  ///
  /// Pass `null` to go back to the real host.
  @visibleForTesting
  static void debugOverride(TargetPlatform? platform) => _override = platform;

  static bool get isAndroid => _override == null
      ? Platform.isAndroid
      : _override == TargetPlatform.android;

  static bool get isIOS =>
      _override == null ? Platform.isIOS : _override == TargetPlatform.iOS;

  /// Phones and tablets. The mobile shell (DESIGN.md 6.3) is chosen on this.
  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => !isMobile;
}
