import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

abstract class AppViewModel extends ChangeNotifier {
  @protected
  void reportError(
    Object error,
    StackTrace stackTrace, {
    required String context,
  }) {
    AppLogger.error(context: context, error: error, stackTrace: stackTrace);
  }
}
