import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/core/shared/widgets/pyago_avatar.dart';
import 'package:pyago/core/shared/widgets/pyago_badge.dart';
import 'package:pyago/core/shared/widgets/pyago_button.dart';
import 'package:pyago/core/theme/app_theme.dart';

/// Golden tests for the core design-system components in both light and
/// dark themes, per the Phase 2 requirement.
///
/// **Note on running these**: this sandbox has no Flutter SDK, so no
/// baseline PNGs exist yet. The first time these run locally, use:
///
/// ```
/// flutter test --update-goldens test/golden/
/// ```
///
/// to generate `test/golden/goldens/*.png`, review them, and commit
/// them. Subsequent `flutter test` runs will then diff against those
/// baselines as normal.
Widget _themed(Widget child, {required bool dark}) {
  return MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

void main() {
  group('PyagoButton golden', () {
    testWidgets('primary button — light', (tester) async {
      await tester.pumpWidget(_themed(
        PyagoButton(label: 'Publish', onPressed: () {}),
        dark: false,
      ));
      await expectLater(
        find.byType(PyagoButton),
        matchesGoldenFile('goldens/pyago_button_primary_light.png'),
      );
    });

    testWidgets('primary button — dark', (tester) async {
      await tester.pumpWidget(_themed(
        PyagoButton(label: 'Publish', onPressed: () {}),
        dark: true,
      ));
      await expectLater(
        find.byType(PyagoButton),
        matchesGoldenFile('goldens/pyago_button_primary_dark.png'),
      );
    });

    testWidgets('disabled button — light', (tester) async {
      await tester.pumpWidget(_themed(
        const PyagoButton(label: 'Publish', onPressed: null),
        dark: false,
      ));
      await expectLater(
        find.byType(PyagoButton),
        matchesGoldenFile('goldens/pyago_button_disabled_light.png'),
      );
    });

    testWidgets('secondary/destructive variants — light', (tester) async {
      await tester.pumpWidget(_themed(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PyagoButton(label: 'Save draft', onPressed: () {}, variant: PyagoButtonVariant.secondary),
            const SizedBox(height: 12),
            PyagoButton(label: 'Delete', onPressed: () {}, variant: PyagoButtonVariant.destructive),
          ],
        ),
        dark: false,
      ));
      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/pyago_button_variants_light.png'),
      );
    });
  });

  group('PyagoAvatar golden', () {
    testWidgets('initials fallback — light', (tester) async {
      await tester.pumpWidget(_themed(const PyagoAvatar(name: 'Maya Osei'), dark: false));
      await expectLater(
        find.byType(PyagoAvatar),
        matchesGoldenFile('goldens/pyago_avatar_initials_light.png'),
      );
    });

    testWidgets('initials fallback — dark', (tester) async {
      await tester.pumpWidget(_themed(const PyagoAvatar(name: 'Maya Osei'), dark: true));
      await expectLater(
        find.byType(PyagoAvatar),
        matchesGoldenFile('goldens/pyago_avatar_initials_dark.png'),
      );
    });
  });

  group('PyagoTag golden', () {
    testWidgets('selected vs unselected — light', (tester) async {
      await tester.pumpWidget(_themed(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PyagoTag(label: 'All', selected: true),
            SizedBox(width: 8),
            PyagoTag(label: 'Poetry', selected: false),
          ],
        ),
        dark: false,
      ));
      await expectLater(
        find.byType(Row),
        matchesGoldenFile('goldens/pyago_tag_states_light.png'),
      );
    });
  });
}
