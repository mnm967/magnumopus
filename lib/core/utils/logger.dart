import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A utility class for logging events and errors
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  // Initialize Logger
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to be displayed
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 80, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Show emojis
      printTime: true, // Should print time
    ),
  );

  /// Log an informational message
  static void info(String message) {
    if (kDebugMode) {
      _logger.i('📘 INFO: $message');
    }
  }

  /// Log a debug message
  static void debug(String message) {
    if (kDebugMode) {
      _logger.d('🔍 DEBUG: $message');
    }
  }

  /// Log a warning message
  static void warning(String message) {
    if (kDebugMode) {
      _logger.w('⚠️ WARNING: $message');
    }
  }

  /// Log an error with optional stack trace
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.e(
        '❌ ERROR: $message',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a fatal error
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.f(
        '💥 FATAL: $message',
        error: error,
        stackTrace: stackTrace,
      );
      // In a production app, you might want to report to a crash reporting service
    }
  }
} 