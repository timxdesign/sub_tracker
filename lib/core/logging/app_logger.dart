import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void error({
    required String context,
    required Object error,
    required StackTrace stackTrace,
  }) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'sub_tracker',
        context: ErrorDescription(context),
        silent: true,
        informationCollector: () sync* {
          yield ErrorDescription('Context: $context');
        },
      ),
    );

    if (kDebugMode) {
      debugPrint('[$context] $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
