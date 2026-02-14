import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Wrapper over the Talker package.
/// Taken from: https://github.com/strvcom/flutter-template/blob/master/lib/core/flogger.dart
final class Flogger {
  static final _talker = TalkerFlutter.init(
    settings: TalkerSettings(
      colors: colors,
      // ignore: avoid_redundant_argument_values
      enabled: kDebugMode,
    ), // Disable logs for Production.
  );

  static Talker get talker => _talker;

  static final colors = {
    'httpRequest': AnsiPen()..xterm(50),
    'httpResponse': AnsiPen()..xterm(42),
    'httpError': AnsiPen()..xterm(196),
    'verbose': AnsiPen()..xterm(242),
    'debug': AnsiPen()..xterm(46),
    'info': AnsiPen()..xterm(6),
    'warning': AnsiPen()..xterm(3),
    'error': AnsiPen()..xterm(9),
  };

  static void v(dynamic message, {Object? exception, StackTrace? stackTrace}) {
    _talker.logCustom(
      _Log(
        message.toString(),
        exception: exception,
        stackTrace: stackTrace,
        pen: colors['verbose'],
        key: TalkerKey.verbose,
      ),
    );
  }

  static void d(dynamic message, {Object? exception, StackTrace? stackTrace}) {
    _talker.logCustom(
      _Log(
        message.toString(),
        exception: exception,
        stackTrace: stackTrace,
        pen: colors['debug'],
        key: TalkerKey.debug,
      ),
    );
  }

  static void i(dynamic message, {Object? exception, StackTrace? stackTrace}) {
    _talker.logCustom(
      _Log(message.toString(), exception: exception, stackTrace: stackTrace, pen: colors['info'], key: TalkerKey.info),
    );
  }

  static void w(dynamic message, {Object? exception, StackTrace? stackTrace}) {
    _talker.logCustom(
      _Log(
        message.toString(),
        exception: exception,
        stackTrace: stackTrace,
        pen: colors['warning'],
        key: TalkerKey.warning,
      ),
    );
  }

  static void e(dynamic message, {Object? exception, StackTrace? stackTrace}) {
    _talker.logCustom(
      _Log(
        message.toString(),
        exception: exception,
        stackTrace: stackTrace,
        pen: colors['error'],
        key: TalkerKey.error,
      ),
    );
  }

  static void httpRequest(dynamic message) =>
      talker.logCustom(_Log(message.toString(), pen: colors['httpRequest'], key: TalkerKey.httpRequest));

  static void httpResponse(dynamic message) =>
      talker.logCustom(_Log(message.toString(), pen: colors['httpResponse'], key: TalkerKey.httpResponse));

  static void httpError(dynamic message) =>
      talker.logCustom(_Log(message.toString(), pen: colors['httpError'], key: TalkerKey.error));
}

final class _Log extends TalkerLog {
  _Log(String super.message, {super.key, super.exception, super.stackTrace, super.pen});

  @override
  String generateTextMessage({TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    return '$displayMessage $displayException $displayStackTrace';
  }
}

// ignore: unused_element
class _LoggerFormatter implements LoggerFormatter {
  final _maxOutputThreshold = 880;

  bool _shouldShowBorder(LogDetails details) {
    return switch (details.level) {
      LogLevel.critical => true,
      LogLevel.error => true,
      _ => false,
    };
  }

  @override
  String fmt(LogDetails details, TalkerLoggerSettings settings) {
    final showBorder = _shouldShowBorder(details);

    final underline = ConsoleUtils.getUnderline(
      settings.maxLineWidth,
      lineSymbol: settings.lineSymbol,
      withCorner: true,
    );
    final topLine = ConsoleUtils.getTopline(settings.maxLineWidth, lineSymbol: settings.lineSymbol, withCorner: true);
    final msg = details.message?.toString() ?? '';
    final msgBorderedLines = _splitLongLines(msg, _maxOutputThreshold).split('\n').map((e) => '│ $e');
    if (!settings.enableColors) {
      return showBorder ? '$topLine\n${msgBorderedLines.join('\n')}\n$underline' : msgBorderedLines.join('\n');
    }
    var lines = [if (showBorder) topLine, ...msgBorderedLines, if (showBorder) underline];
    lines = lines.map((e) => details.pen.write(e)).toList();
    final coloredMsg = lines.join('\n');
    return coloredMsg;
  }

  static String _splitLongLines(String input, int maxLineLength) {
    final lines = input.split('\n');
    final outputLines = <String>[];

    for (final line in lines) {
      if (line.length > maxLineLength) {
        // Split the line into chunks of maxLineLength
        for (var i = 0; i < line.length; i += maxLineLength) {
          final end = (i + maxLineLength < line.length) ? i + maxLineLength : line.length;
          outputLines.add(line.substring(i, end));
        }
      } else {
        outputLines.add(line);
      }
    }

    return outputLines.join('\n');
  }
}
