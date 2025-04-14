import 'package:ansicolor/ansicolor.dart';
import '';
// ignore_for_file: avoid_print

// ignore: avoid_classes_with_only_static_members
class LogService {
  static final AnsiPen _penError = AnsiPen()..red(bold: true);
  static final AnsiPen _penSuccess = AnsiPen()..green(bold: true);
  static final AnsiPen _penInfo = AnsiPen()..blue(bold: true);
  static final AnsiPen _penDebug = AnsiPen()..yellow(bold: true);
  static final AnsiPen _penStack = AnsiPen()..gray(level: 0.7);

  static final AnsiPen code =
      AnsiPen()
        ..black(bold: false, bg: true)
        ..white();

  static final AnsiPen codeBold = AnsiPen()..gray(level: 1);

  static const String _separator = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  //  static var _errorWrapper = '_' * 40;
  static void error(String msg, {dynamic error, StackTrace? stackTrace}) {
    const sep = '\n';
    final buffer = StringBuffer();
    // Main error message
    buffer.write('${sep}❌ ${_penError('ERROR: ${msg.trim()}')}${sep}');
    // Error details if provided
    if (error != null) {
      buffer.write('${_penError('DETAILS: ')}${error}${sep}');
    }

    // Stacktrace if provided
    if (stackTrace != null) {
      buffer.write('${_separator}${sep}');
      buffer.write('${_penStack('STACK TRACE:')}${sep}');
      buffer.write('${_penStack(stackTrace.toString())}${sep}');
      buffer.write('${_separator}${sep}');
    }

    print(buffer.toString());

    msg = '✖  + ${_penError(msg.trim())}';
    msg = msg + sep;
    print(msg);
  }

  static void success(dynamic msg) {
    print('✅ ${_penSuccess(msg.toString())}');
  }

  static void info(String msg, [bool trim = false, bool newLines = true]) {
    final sep = newLines ? '\n' : '';
    if (trim) msg = msg.trim();
    msg = _penInfo(msg);
    // ignore: prefer_interpolation_to_compose_strings
    msg = sep + 'ℹ️  '+ msg.toString() + sep;
    print(msg);
  }

  static void debug(String msg, {dynamic error, StackTrace? stackTrace}) {
    final buffer = StringBuffer();
    
    // Main debug message
    buffer.write('🔍 ${_penDebug(msg)}');
    
    if (error != null || stackTrace != null) {
      buffer.write('\n${_separator}');
    }
    
    // Error details if provided
    if (error != null) {
      buffer.write('\n${_penDebug('DEBUG DETAILS: ')}${error}');
    }
    
    // Stacktrace if provided
    if (stackTrace != null) {
      buffer.write('\n${_penStack('STACK TRACE:')}');
      buffer.write('\n${_penStack(stackTrace.toString())}');
      buffer.write('\n${_separator}');
    }
    
    print(buffer.toString());
  }
}
