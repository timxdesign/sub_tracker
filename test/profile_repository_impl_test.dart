import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sub_tracker/core/storage/json_preferences_store.dart';
import 'package:sub_tracker/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:sub_tracker/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:sub_tracker/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores a created profile locally and queues it for submission', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = ProfileRepositoryImpl(
      localDataSource: ProfileLocalDataSource(
        JsonPreferencesStore(preferences),
      ),
      remoteDataSource: ProfileRemoteDataSource(
        client: MockClient((request) async => http.Response('', 200)),
        endpoint: 'https://example.com/forms/profile',
      ),
    );

    await repository.createProfile(
      fullName: 'John Doe',
      email: 'john@example.com',
    );

    final storedProfile = await repository.getStoredProfile();
    final pendingProfile = await repository.getPendingProfile();

    expect(storedProfile?.fullName, 'John Doe');
    expect(storedProfile?.email, 'john@example.com');
    expect(pendingProfile?.email, 'john@example.com');
  });

  test('clears queued submissions after a successful form post', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = ProfileRepositoryImpl(
      localDataSource: ProfileLocalDataSource(
        JsonPreferencesStore(preferences),
      ),
      remoteDataSource: ProfileRemoteDataSource(
        client: MockClient((request) async => http.Response('', 200)),
        endpoint: 'https://example.com/forms/profile',
      ),
    );

    await repository.createProfile(
      fullName: 'Jane Doe',
      email: 'jane@example.com',
    );
    await repository.syncPendingProfile();

    expect(await repository.getPendingProfile(), isNull);
  });

  test('keeps queued submissions when the form post fails', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = ProfileRepositoryImpl(
      localDataSource: ProfileLocalDataSource(
        JsonPreferencesStore(preferences),
      ),
      remoteDataSource: ProfileRemoteDataSource(
        client: MockClient((request) async => http.Response('', 503)),
        endpoint: 'https://example.com/forms/profile',
      ),
    );

    await repository.createProfile(
      fullName: 'Alex Doe',
      email: 'alex@example.com',
    );
    await repository.syncPendingProfile();

    expect(await repository.getPendingProfile(), isNotNull);
  });
}
