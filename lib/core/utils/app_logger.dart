import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

/// Centralized logging utility for the karmgyan app
/// Provides structured logging with levels, file output, and context
class AppLogger {
  static Logger? _logger;
  static File? _logFile;
  static bool _initialized = false;
  static final List<String> _logBuffer = [];
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static const int _maxLogFiles = 3;

  /// Initialize the logger
  static Future<void> initialize({bool enableFileLogging = true}) async {
    if (_initialized) return;

    try {
      // Setup file logging if enabled
      FileOutput? fileOutput;
      if (enableFileLogging && !kIsWeb) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final logDir = Directory('${directory.path}/logs');
          if (!await logDir.exists()) {
            await logDir.create(recursive: true);
          }

          _logFile = File('${logDir.path}/app_${DateTime.now().millisecondsSinceEpoch}.log');
          await _logFile!.create();
          
          // Rotate old log files
          await _rotateLogFiles(logDir);

          fileOutput = FileOutput(file: _logFile!);
        } catch (e) {
          debugPrint('⚠️ Failed to setup file logging: $e');
        }
      }

      // Create logger with outputs
      final outputs = <LogOutput>[];
      
      // Always add console output
      outputs.add(ConsoleOutput());
      
      // Add file output if available
      if (fileOutput != null) {
        outputs.add(fileOutput);
      }

      // Create logger
      _logger = Logger(
        level: kDebugMode ? Level.debug : Level.info,
        output: outputs.length > 1 ? MultiOutput(outputs) : outputs.first,
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );

      // Flush buffered logs
      if (_logBuffer.isNotEmpty) {
        for (final log in _logBuffer) {
          _logger?.d(log);
        }
        _logBuffer.clear();
      }

      _initialized = true;
      _logger?.i('✅ AppLogger initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize AppLogger: $e');
      // Fallback to basic logger
      _logger = Logger(
        level: kDebugMode ? Level.debug : Level.info,
        printer: SimplePrinter(colors: true),
      );
      _initialized = true;
    }
  }

  /// Rotate log files to prevent disk space issues
  static Future<void> _rotateLogFiles(Directory logDir) async {
    try {
      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .map((entity) => entity as File)
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Delete old files if we have too many
      if (files.length >= _maxLogFiles) {
        for (var i = _maxLogFiles - 1; i < files.length; i++) {
          await files[i].delete();
        }
      }

      // Check and rotate if file is too large
      for (final file in files.take(_maxLogFiles)) {
        final size = await file.length();
        if (size > _maxLogFileSize) {
          // Archive old file
          final archivePath = file.path.replaceAll('.log', '_${DateTime.now().millisecondsSinceEpoch}.log');
          await file.rename(archivePath);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to rotate log files: $e');
    }
  }

  /// Log debug message
  static void d(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(Level.debug, message, error, stackTrace, context);
  }

  /// Log info message
  static void i(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(Level.info, message, error, stackTrace, context);
  }

  /// Log warning message
  static void w(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(Level.warning, message, error, stackTrace, context);
  }

  /// Log error message
  static void e(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(Level.error, message, error, stackTrace, context);
  }

  /// Log fatal error
  static void f(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(Level.fatal, message, error, stackTrace, context);
  }

  /// Internal logging method
  static void _log(Level level, String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    if (!_initialized) {
      // Buffer logs until initialized
      _logBuffer.add('[$level] $message');
      return;
    }

    try {
      final fullMessage = context != null && context.isNotEmpty
          ? '$message | Context: ${context.toString()}'
          : message;

      if (error != null || stackTrace != null) {
        _logger?.log(level, fullMessage, error: error, stackTrace: stackTrace);
      } else {
        _logger?.log(level, fullMessage);
      }
    } catch (e) {
      // Fallback to debugPrint if logger fails
      debugPrint('[$level] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
  }

  /// Log API request
  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    final context = <String, dynamic>{
      'method': method,
      'url': url,
      if (queryParams != null && queryParams.isNotEmpty) 'queryParams': queryParams,
      if (headers != null && headers.isNotEmpty) 'headers': _sanitizeHeaders(headers),
      if (body != null) 'body': _sanitizeBody(body),
    };
    i('🌐 API Request: $method $url', null, null, context);
  }

  /// Log API response
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic body,
    Duration? duration,
  }) {
    final context = <String, dynamic>{
      'method': method,
      'url': url,
      'statusCode': statusCode,
      if (duration != null) 'duration': '${duration.inMilliseconds}ms',
      if (body != null) 'body': _sanitizeBody(body),
    };
    
    if (statusCode >= 200 && statusCode < 300) {
      i('✅ API Response: $method $url → $statusCode', null, null, context);
    } else if (statusCode >= 400 && statusCode < 500) {
      w('⚠️ API Client Error: $method $url → $statusCode', null, null, context);
    } else {
      e('❌ API Server Error: $method $url → $statusCode', null, null, context);
    }
  }

  /// Log API error
  static void logApiError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
    int? statusCode,
    dynamic responseBody,
  }) {
    final context = <String, dynamic>{
      'method': method,
      'url': url,
      if (statusCode != null) 'statusCode': statusCode,
      if (responseBody != null) 'responseBody': _sanitizeBody(responseBody),
    };
    e('❌ API Error: $method $url', error, stackTrace, context);
  }

  /// Sanitize headers to remove sensitive data
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    final sensitiveKeys = ['authorization', 'cookie', 'x-api-key', 'apikey', 'token'];
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '***REDACTED***';
      }
    }
    return sanitized;
  }

  /// Sanitize body to remove sensitive data
  static dynamic _sanitizeBody(dynamic body) {
    if (body is Map) {
      final sanitized = Map<String, dynamic>.from(body);
      final sensitiveKeys = ['password', 'token', 'secret', 'key', 'authorization'];
      for (final key in sensitiveKeys) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '***REDACTED***';
        }
      }
      return sanitized;
    }
    return body;
  }

  /// Get log file path (for sharing/debugging)
  static String? getLogFilePath() {
    return _logFile?.path;
  }

  /// Clear log file
  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
      i('📝 Log file cleared');
    }
  }
}

