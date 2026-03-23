import '../../domain/models/subscription.dart';

class SubscriptionDto {
  const SubscriptionDto({
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
  final String category;
  final double price;
  final String currencyCode;
  final String billingCycle;
  final DateTime nextBillingDate;
  final DateTime createdAt;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'currencyCode': currencyCode,
      'billingCycle': billingCycle,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currencyCode: json['currencyCode'] as String? ?? 'NGN',
      billingCycle: json['billingCycle'] as String? ?? 'monthly',
      nextBillingDate:
          DateTime.tryParse(json['nextBillingDate'] as String? ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      description: json['description'] as String? ?? '',
    );
  }

  Subscription toDomain() {
    return Subscription(
      id: id,
      name: name,
      category: SubscriptionCategory.fromStorage(category),
      price: price,
      currencyCode: currencyCode,
      billingCycle: _toBillingCycle(billingCycle),
      nextBillingDate: nextBillingDate,
      createdAt: createdAt,
      description: description,
    );
  }

  factory SubscriptionDto.fromDomain(Subscription subscription) {
    return SubscriptionDto(
      id: subscription.id,
      name: subscription.name,
      category: subscription.category.slug,
      price: subscription.price,
      currencyCode: subscription.currencyCode,
      billingCycle: subscription.billingCycle.name,
      nextBillingDate: subscription.nextBillingDate,
      createdAt: subscription.createdAt,
      description: subscription.description,
    );
  }

  static SubscriptionBillingCycle _toBillingCycle(String value) {
    return SubscriptionBillingCycle.values.firstWhere(
      (cycle) => cycle.name == value,
      orElse: () => SubscriptionBillingCycle.monthly,
    );
  }
}
