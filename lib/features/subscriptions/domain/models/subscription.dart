enum SubscriptionBillingCycle { monthly, yearly, custom, lifetime }

extension SubscriptionBillingCycleX on SubscriptionBillingCycle {
  String get label {
    switch (this) {
      case SubscriptionBillingCycle.monthly:
        return 'Monthly';
      case SubscriptionBillingCycle.yearly:
        return 'Annually';
      case SubscriptionBillingCycle.custom:
        return 'Custom';
      case SubscriptionBillingCycle.lifetime:
        return 'Lifetime';
    }
  }

  double monthlyEquivalent(
    double amount, {
    DateTime? startDate,
    DateTime? nextBillingDate,
  }) {
    switch (this) {
      case SubscriptionBillingCycle.monthly:
        return amount;
      case SubscriptionBillingCycle.yearly:
        return amount / 12;
      case SubscriptionBillingCycle.custom:
        final firstDate = startDate;
        final secondDate = nextBillingDate;
        if (firstDate == null || secondDate == null) {
          return amount;
        }

        final intervalDays = _dateOnly(
          secondDate,
        ).difference(_dateOnly(firstDate)).inDays;
        if (intervalDays <= 0) {
          return amount;
        }

        final monthsEquivalent = intervalDays / 30;
        if (monthsEquivalent <= 0) {
          return amount;
        }

        return amount / monthsEquivalent;
      case SubscriptionBillingCycle.lifetime:
        return 0;
    }
  }

  DateTime advanceDate(
    DateTime currentDate, {
    DateTime? startDate,
    DateTime? nextBillingDate,
  }) {
    switch (this) {
      case SubscriptionBillingCycle.monthly:
        return _addMonths(currentDate, 1);
      case SubscriptionBillingCycle.yearly:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
      case SubscriptionBillingCycle.custom:
        final intervalDays = _resolveCustomIntervalDays(
          startDate: startDate,
          nextBillingDate: nextBillingDate,
        );
        return currentDate.add(Duration(days: intervalDays));
      case SubscriptionBillingCycle.lifetime:
        return currentDate;
    }
  }

  int _resolveCustomIntervalDays({
    DateTime? startDate,
    DateTime? nextBillingDate,
  }) {
    if (startDate == null || nextBillingDate == null) {
      return 30;
    }

    final days = _dateOnly(
      nextBillingDate,
    ).difference(_dateOnly(startDate)).inDays;
    return days <= 0 ? 30 : days;
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
  others;

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
      case SubscriptionCategory.others:
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
      case SubscriptionCategory.others:
        return 'other';
    }
  }

  static SubscriptionCategory fromStorage(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

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
        return SubscriptionCategory.others;
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

enum SubscriptionRenewalStatus { active, expiringSoon, expiresToday, expired }

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
    this.serviceProvider = '',
    this.website = '',
    this.startDate,
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
  final String serviceProvider;
  final String website;
  final DateTime? startDate;

  Subscription copyWith({
    String? id,
    String? name,
    SubscriptionCategory? category,
    double? price,
    String? currencyCode,
    SubscriptionBillingCycle? billingCycle,
    DateTime? nextBillingDate,
    DateTime? createdAt,
    String? description,
    String? serviceProvider,
    String? website,
    DateTime? startDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      website: website ?? this.website,
      startDate: startDate ?? this.startDate,
    );
  }

  DateTime get effectiveStartDate => startDate ?? createdAt;

  double get monthlyCost => billingCycle.monthlyEquivalent(
    price,
    startDate: effectiveStartDate,
    nextBillingDate: nextBillingDate,
  );

  String get categoryLabel => category.label;

  bool get supportsRenewal => billingCycle != SubscriptionBillingCycle.lifetime;

  bool get isExpired {
    if (!supportsRenewal) {
      return false;
    }

    final today = _dateOnly(DateTime.now());
    return _dateOnly(nextBillingDate).isBefore(today);
  }

  bool get expiresToday {
    if (!supportsRenewal) {
      return false;
    }

    return _sameDay(nextBillingDate, DateTime.now());
  }

  bool get isExpiringSoon {
    if (!supportsRenewal || isExpired) {
      return false;
    }

    return daysUntilRenewal <= 7;
  }

  int get daysUntilRenewal {
    if (!supportsRenewal) {
      return 0;
    }

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

  DateTime get renewedBillingDate => billingCycle.advanceDate(
    nextBillingDate,
    startDate: effectiveStartDate,
    nextBillingDate: nextBillingDate,
  );

  double get totalAmountSpent {
    if (price <= 0) {
      return 0;
    }

    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(effectiveStartDate);
    if (today.isBefore(start)) {
      return 0;
    }

    if (billingCycle == SubscriptionBillingCycle.lifetime) {
      return price;
    }

    var occurrences = 0;
    var cursor = start;
    for (var index = 0; index < 1000 && !cursor.isAfter(today); index++) {
      occurrences++;
      final nextCursor = billingCycle.advanceDate(
        cursor,
        startDate: effectiveStartDate,
        nextBillingDate: nextBillingDate,
      );
      if (!nextCursor.isAfter(cursor)) {
        break;
      }
      cursor = nextCursor;
    }

    return price * occurrences;
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _addMonths(DateTime value, int monthsToAdd) {
  final targetMonth = value.month + monthsToAdd;
  final year = value.year + ((targetMonth - 1) ~/ 12);
  final month = ((targetMonth - 1) % 12) + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = value.day > lastDayOfMonth ? lastDayOfMonth : value.day;
  return DateTime(
    year,
    month,
    day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
