import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dto/profile_dto.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required http.Client client,
    required String endpoint,
  })  : _client = client,
        _endpoint = endpoint.trim();

  final http.Client _client;
  final String _endpoint;

  bool get isConfigured => _endpoint.isNotEmpty;

  Future<bool> syncProfile(ProfileDto profile) async {
    if (!isConfigured) {
      return false;
    }

    final endpoint = Uri.tryParse(_endpoint);
    if (endpoint == null) {
      return false;
    }

    try {
      final response = await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': profile.fullName,
              'email': profile.email,
              'createdAt': profile.createdAt.toIso8601String(),
              'source': 'sub_tracker',
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
