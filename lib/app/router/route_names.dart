abstract final class AppRouteNames {
  static const splash = 'splash';
  static const welcome = 'welcome';
  static const createProfile = 'create_profile';
  static const home = 'home';
  static const subscriptions = 'subscriptions';
  static const categorySubscriptions = 'category_subscriptions';
  static const insights = 'insights';
  static const upcoming = 'upcoming';
  static const newSubscription = 'new_subscription';
  static const subscriptionDetails = 'subscription_details';
  static const settings = 'settings';
  static const editProfile = 'edit_profile';
  static const terms = 'terms';
}

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const createProfile = '/profile/create';
  static const home = '/home';
  static const subscriptions = '/subscriptions';
  static const insights = '/insights';
  static const upcoming = '/upcoming';
  static const newSubscription = '/add';
  static const settings = '/settings';
  static const editProfile = '/settings/profile/edit';
  static const terms = '/settings/terms';

  static String subscriptionsView({bool list = false}) =>
      list ? '$subscriptions?view=list' : subscriptions;

  static String categorySubscriptions(String categorySlug) =>
      '/subscriptions/$categorySlug';

  static String subscriptionDetails(String subscriptionId) =>
      '/subscriptions/details/$subscriptionId';
}
