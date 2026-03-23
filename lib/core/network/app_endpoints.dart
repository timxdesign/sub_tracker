abstract final class AppEndpoints {
  static const profileSync = String.fromEnvironment('FORM_SERVICE_ENDPOINT');
  static const subscriptionsSync = String.fromEnvironment(
    'SUBSCRIPTIONS_SERVICE_ENDPOINT',
  );
}
