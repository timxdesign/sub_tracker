import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sub_tracker/app/theme/app_theme.dart';
import 'package:sub_tracker/features/profile/domain/models/profile.dart';
import 'package:sub_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:sub_tracker/features/profile/domain/usecases/create_profile.dart';
import 'package:sub_tracker/features/profile/domain/usecases/sync_pending_profile.dart';
import 'package:sub_tracker/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:sub_tracker/features/profile/presentation/viewmodels/create_profile_view_model.dart';
import 'package:sub_tracker/features/profile/presentation/widgets/profile_created_sheet.dart';

void main() {
  testWidgets('create profile screen starts with disabled proceed button', (
    tester,
  ) async {
    final viewModel = CreateProfileViewModel(
      createProfile: CreateProfileUseCase(_FakeProfileRepository()),
      syncPendingProfile: SyncPendingProfileUseCase(_FakeProfileRepository()),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<CreateProfileViewModel>.value(
          value: viewModel,
          child: const CreateProfileScreen(),
        ),
      ),
    );

    expect(find.text('Create a profile'), findsOneWidget);
    expect(
      find.byKey(const Key('create-profile-offline-note')),
      findsOneWidget,
    );
    expect(
      tester
              .widget<FilledButton>(
                find.byKey(const Key('create-profile-proceed-button')),
              )
              .onPressed ==
          null,
      isTrue,
    );
  });

  testWidgets('create profile screen shows validation error on blur', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    final viewModel = CreateProfileViewModel(
      createProfile: CreateProfileUseCase(repository),
      syncPendingProfile: SyncPendingProfileUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<CreateProfileViewModel>.value(
          value: viewModel,
          child: const CreateProfileScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(1), 'invalid-email');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(
      tester
              .widget<FilledButton>(
                find.byKey(const Key('create-profile-proceed-button')),
              )
              .onPressed ==
          null,
      isTrue,
    );
  });

  testWidgets('create profile screen enables proceed when form is valid', (
    tester,
  ) async {
    final repository = _FakeProfileRepository();
    final viewModel = CreateProfileViewModel(
      createProfile: CreateProfileUseCase(repository),
      syncPendingProfile: SyncPendingProfileUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<CreateProfileViewModel>.value(
          value: viewModel,
          child: const CreateProfileScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'example@gmail.com');
    await tester.pumpAndSettle();

    expect(
      tester
              .widget<FilledButton>(
                find.byKey(const Key('create-profile-proceed-button')),
              )
              .onPressed !=
          null,
      isTrue,
    );
  });

  testWidgets('profile created sheet appears as bottom overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showProfileCreatedSheet(context),
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(find.byKey(const Key('profile-created-sheet')), findsOneWidget);
    expect(find.text('Profile created'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
  });
}

class _FakeProfileRepository implements ProfileRepository {
  Profile? storedProfile;

  @override
  Future<Profile?> getStoredProfile() async => storedProfile;

  @override
  Future<Profile?> getPendingProfile() async => null;

  @override
  Future<Profile> createProfile({
    required String fullName,
    required String email,
  }) async {
    final profile = Profile(
      fullName: fullName,
      email: email,
      createdAt: DateTime(2026, 1, 1),
    );
    storedProfile = profile;
    return profile;
  }

  @override
  Future<Profile?> updateProfile({
    required String fullName,
    required String email,
  }) async {
    return storedProfile;
  }

  @override
  Future<void> syncPendingProfile() async {}

  @override
  void startSyncLoop() {}

  @override
  void dispose() {}
}
