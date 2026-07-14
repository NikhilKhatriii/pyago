import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pyago/core/storage/hive_service.dart';
import 'package:pyago/core/storage/local_storage_service.dart';
import 'package:pyago/features/auth/domain/models/app_user.dart';
import 'package:pyago/features/auth/presentation/providers/auth_provider.dart';
import 'package:pyago/main.dart';

/// Critical-path smoke test: with a pre-authenticated session, every
/// bottom-nav destination should open without error. This intentionally
/// bypasses the register/OTP/onboarding flow (covered separately by
/// widget tests on those individual screens) so the test stays fast and
/// focused on the authenticated shell + each top-level screen mounting
/// cleanly — including the Create screen, whose autosave/media-picker
/// wiring is the riskiest part of this phase's changes.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bottom navigation reaches every top-level destination', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await HiveService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(LocalStorageService(prefs)),
          hiveServiceProvider.overrideWithValue(HiveService()),
          authControllerProvider.overrideWith((ref) => AuthController(ref.watch(authRepositoryProvider))
            ..state = const AuthState(
              status: AuthStatus.authenticated,
              user: AppUser(id: 'u1', email: 'test@pyago.app', displayName: 'Test User'),
            )),
        ],
        child: const PyagoApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Explore', 'Create', 'Communities', 'Profile', 'Home']) {
      final destination = find.text(label);
      expect(destination, findsWidgets, reason: '$label destination should be visible');
      await tester.tap(destination.first);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('write a post on the Create screen and publish it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await HiveService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(LocalStorageService(prefs)),
          hiveServiceProvider.overrideWithValue(HiveService()),
          authControllerProvider.overrideWith((ref) => AuthController(ref.watch(authRepositoryProvider))
            ..state = const AuthState(
              status: AuthStatus.authenticated,
              user: AppUser(id: 'u2', email: 'writer@pyago.app', displayName: 'Writer'),
            )),
        ],
        child: const PyagoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Title (optional)'), 'A quiet Tuesday');
    await tester.enterText(
      find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.startsWith('Start writing') == true),
      'Some short thoughts written entirely inside an integration test.',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
    await tester.pumpAndSettle();

    // Publishing (against the mock backend) surfaces a confirmation
    // SnackBar and returns to the previous screen.
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
