enum SubscriptionBillingCycle { monthly, yearly }

extension SubscriptionBillingCycleX on SubscriptionBillingCycle {
  String get label {
    switch (this) {
      case SubscriptionBillingCycle.monthly:
        return 'Monthly';
      case SubscriptionBillingCycle.yearly:
        return 'Yearly';
    }
  }

  double monthlyEquivalent(double amount) {
    switch (this) {
      case SubscriptionBillingCycle.monthly:
        return amount;
      case SubscriptionBillingCycle.yearly:
        return amount / 12;
    }
  }
}

enum SubscriptionCategory {
  dataPlan,
  apps,
  tools,
  health,
  vehicle,
  insurance,
  identity,
  other;

  String get label {
    switch (this) {
      case SubscriptionCategory.dataPlan:
        return 'Data plan';
      case SubscriptionCategory.apps:
        return 'Apps';
      case SubscriptionCategory.tools:
        return 'Tools';
      case SubscriptionCategory.health:
        return 'Health';
      case SubscriptionCategory.vehicle:
        return 'Vehicle';
      case SubscriptionCategory.insurance:
        return 'Insurance';
      case SubscriptionCategory.identity:
        return 'Identity';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }

  String get slug {
    switch (this) {
      case SubscriptionCategory.dataPlan:
        return 'data-plan';
      case SubscriptionCategory.apps:
        return 'apps';
      case SubscriptionCategory.tools:
        return 'tools';
      case SubscriptionCategory.health:
        return 'health';
      case SubscriptionCategory.vehicle:
        return 'vehicle';
      case SubscriptionCategory.insurance:
        return 'insurance';
      case SubscriptionCategory.identity:
        return 'identity';
      case SubscriptionCategory.other:
        return 'other';
    }
  }

  static SubscriptionCategory fromStorage(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    switch (normalized) {
      case 'dataplan':
      case 'data':
      case 'internet':
        return SubscriptionCategory.dataPlan;
      case 'apps':
      case 'app':
      case 'entertainment':
        return SubscriptionCategory.apps;
      case 'tools':
      case 'tool':
      case 'software':
        return SubscriptionCategory.tools;
      case 'health':
      case 'medical':
        return SubscriptionCategory.health;
      case 'vehicle':
      case 'car':
      case 'transport':
        return SubscriptionCategory.vehicle;
      case 'insurance':
        return SubscriptionCategory.insurance;
      case 'identity':
      case 'id':
        return SubscriptionCategory.identity;
      default:
        return SubscriptionCategory.other;
    }
  }

  static SubscriptionCategory? tryParseSlug(String value) {
    final normalized = value.trim().toLowerCase();
    for (final category in SubscriptionCategory.values) {
      if (category.slug == normalized) {
        return category;
      }
    }
    return null;
  }
}

enum SubscriptionRenewalStatus {
  active,
  expiringSoon,
  expiresToday,
  expired,
}

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.currencyCode,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.createdAt,
    this.description = '',
  });

  final String id;
  final String name;
  final SubscriptionCategory category;
  final double price;
  final String currencyCode;
  final SubscriptionBillingCycle billingCycle;
  final DateTime nextBillingDate;
  final DateTime createdAt;
  final String description;

  double get monthlyCost => billingCycle.monthlyEquivalent(price);

  String get categoryLabel => category.label;

  bool get isExpired {
    final today = _dateOnly(DateTime.now());
    return _dateOnly(nextBillingDate).isBefore(today);
  }

  bool get expiresToday => _sameDay(nextBillingDate, DateTime.now());

  bool get isExpiringSoon {
    if (isExpired) {
      return false;
    }

    return daysUntilRenewal <= 7;
  }

  int get daysUntilRenewal {
    final today = _dateOnly(DateTime.now());
    return _dateOnly(nextBillingDate).difference(today).inDays;
  }

  SubscriptionRenewalStatus get renewalStatus {
    if (isExpired) {
      return SubscriptionRenewalStatus.expired;
    }

    if (expiresToday) {
      return SubscriptionRenewalStatus.expiresToday;
    }

    if (isExpiringSoon) {
      return SubscriptionRenewalStatus.expiringSoon;
    }

    return SubscriptionRenewalStatus.active;
  }
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
