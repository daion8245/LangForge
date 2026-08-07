import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../security/sensitive_filter.dart';

/// One line as the in-app viewer shows it.
class LogLine {
  const LogLine({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
    this.error,
  });

  final DateTime time;
  final Level level;
  final String loggerName;
  final String message;
  final String? error;

  String get formatted =>
      '[${time.toIso8601String()}] [${level.name}] [$loggerName]: $message'
      '${error == null ? '' : ' | Error: $error'}';
}

/// The last [capacity] log records, for the in-app log viewer (ROADMAP 10.7).
///
/// The file log stays the record of truth; this only exists so the user does
/// not have to leave the app to see what happened. Values pass through
/// [SensitiveFilter] exactly as they do on the way to disk — an API key must
/// not appear on screen either.
class LogBuffer extends ChangeNotifier {
  LogBuffer._();

  static final LogBuffer instance = LogBuffer._();

  /// Enough to cover a full translation run without holding a session's worth
  /// of text in memory.
  static const int capacity = 2000;

  final List<LogLine> _lines = [];
  StreamSubscription<LogRecord>? _subscription;

  /// Oldest first.
  List<LogLine> get lines => List.unmodifiable(_lines);

  bool get isListening => _subscription != null;

  void start() {
    if (_subscription != null) return;
    _subscription = Logger.root.onRecord.listen(_add);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  void _add(LogRecord record) {
    _lines.add(
      LogLine(
        time: record.time,
        level: record.level,
        loggerName: record.loggerName,
        message: SensitiveFilter.scrub(record.message),
        error: record.error == null
            ? null
            : SensitiveFilter.scrub(record.error.toString()),
      ),
    );
    if (_lines.length > capacity) {
      _lines.removeRange(0, _lines.length - capacity);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
