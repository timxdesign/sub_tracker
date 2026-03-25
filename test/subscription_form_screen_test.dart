import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sub_tracker/app/theme/app_colors.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/save_subscription.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/subscription_form_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/subscription_form_view_model.dart';

void main() {
  Future<SubscriptionFormViewModel> pumpFormScreen(WidgetTester tester) async {
    final viewModel = SubscriptionFormViewModel(
      saveSubscription: SaveSubscriptionUseCase(_FakeSubscriptionsRepository()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const SubscriptionFormScreen(),
        ),
      ),
    );
    await tester.pump();

    return viewModel;
  }

  testWidgets('starts with placeholder dates and inactive add button', (
    tester,
  ) async {
    await pumpFormScreen(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('subscription-form-start-date')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('mm/dd/yyyy'), findsNWidgets(2));
    expect(find.text('Lifetime'), findsNothing);

    final button = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('subscription-form-submit-surface')),
    );
    final decoration = button.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.surfaceMuted);
  });

  testWidgets('shows validation errors when tapped with empty values', (
    tester,
  ) async {
    await pumpFormScreen(tester);

    await tester.tap(
      find.byKey(const ValueKey('subscription-form-submit-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter a subscription name'), findsOneWidget);
    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(find.text('Select a category'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('subscription-form-start-date')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Select a start date'), findsOneWidget);
    expect(find.text('Enter a billing date'), findsOneWidget);
  });

  testWidgets('becomes active when required fields are valid', (tester) async {
    final viewModel = await pumpFormScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'Netflix Premium');
    await tester.enterText(find.byType(TextField).at(1), '5000');
    viewModel.updateCategory(SubscriptionCategory.apps);
    viewModel.updateStartDate(DateTime(2026, 1, 1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('subscription-form-next-date')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final button = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('subscription-form-submit-surface')),
    );
    final decoration = button.decoration! as BoxDecoration;

    expect(decoration.color, AppColors.brandGreen);
    expect(find.text('02/01/2026'), findsOneWidget);
  });

  testWidgets(
    'selected category and duration chips use the Figma active style',
    (tester) async {
      final viewModel = await pumpFormScreen(tester);

      viewModel.updateCategory(SubscriptionCategory.apps);
      viewModel.updateBillingCycle(SubscriptionBillingCycle.yearly);
      await tester.pumpAndSettle();

      final appsChip = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('subscription-category-chip-apps')),
      );
      final appsDecoration = appsChip.decoration! as BoxDecoration;
      final appsText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('subscription-category-chip-apps')),
          matching: find.text('Apps'),
        ),
      );

      expect(appsDecoration.color, AppColors.brandGreen);
      expect(appsText.style?.color, Colors.white);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('subscription-form-start-date')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final yearlyChip = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('subscription-duration-chip-yearly')),
      );
      final yearlyDecoration = yearlyChip.decoration! as BoxDecoration;
      final yearlyText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('subscription-duration-chip-yearly')),
          matching: find.text('Annually'),
        ),
      );

      expect(yearlyDecoration.color, AppColors.brandGreen);
      expect(yearlyText.style?.color, Colors.white);
    },
  );

  testWidgets('tapping a category chip turns it brand green', (tester) async {
    await pumpFormScreen(tester);

    await tester.tap(find.text('Apps'));
    await tester.pumpAndSettle();

    final appsChip = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('subscription-category-chip-apps')),
    );
    final appsDecoration = appsChip.decoration! as BoxDecoration;

    expect(appsDecoration.color, AppColors.brandGreen);
  });

  testWidgets(
    'service provider sheet fills the field from an asset-backed option',
    (tester) async {
      await pumpFormScreen(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('subscription-form-provider-button')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('subscription-form-provider-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Service Provider'), findsWidgets);
      await tester.tap(
        find.byKey(const ValueKey('subscription-provider-netflix')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Netflix'), findsOneWidget);
    },
  );
}

class _FakeSubscriptionsRepository implements SubscriptionsRepository {
  final List<Subscription> savedSubscriptions = [];

  @override
  Future<List<Subscription>> getSubscriptions() async => savedSubscriptions;

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    for (final subscription in savedSubscriptions) {
      if (subscription.id == id) {
        return subscription;
      }
    }
    return null;
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    savedSubscriptions.add(subscription);
  }
}
