import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/logging/app_logger.dart';
import '../dto/subscription_dto.dart';

class SubscriptionsRemoteDataSource {
  SubscriptionsRemoteDataSource({
    required http.Client client,
    required String endpoint,
  }) : _client = client,
       _endpoint = endpoint.trim();

  final http.Client _client;
  final String _endpoint;

  bool get isConfigured => _endpoint.isNotEmpty;

  Future<List<SubscriptionDto>> fetchSubscriptions() async {
    if (!isConfigured) {
      return const [];
    }

    final endpoint = Uri.tryParse(_endpoint);
    if (endpoint == null) {
      return const [];
    }

    try {
      final response = await _client
          .get(endpoint)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (entry) =>
                SubscriptionDto.fromJson(Map<String, dynamic>.from(entry)),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        context: 'SubscriptionsRemoteDataSource.fetchSubscriptions',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> upsertSubscription(SubscriptionDto subscription) async {
    if (!isConfigured) {
      return;
    }

    final endpoint = Uri.tryParse(_endpoint);
    if (endpoint == null) {
      return;
    }

    try {
      await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(subscription.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      AppLogger.error(
        context: 'SubscriptionsRemoteDataSource.upsertSubscription',
        error: error,
        stackTrace: stackTrace,
      );
      // Local data remains the source of truth for offline-first behavior.
    }
  }
}
