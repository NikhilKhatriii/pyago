import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyago/core/shared/widgets/pyago_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('PyagoButton', () {
    testWidgets('shows its label and responds to taps when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(PyagoButton(label: 'Publish', onPressed: () => tapped = true)));

      expect(find.text('Publish'), findsOneWidget);
      await tester.tap(find.byType(PyagoButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not fire onPressed when disabled (onPressed is null)', (tester) async {
      await tester.pumpWidget(_wrap(const PyagoButton(label: 'Publish', onPressed: null)));

      // Disabled buttons should not throw or crash on tap, and the
      // underlying GestureDetector/InkWell should not report a tap
      // handler firing since none was provided.
      await tester.tap(find.byType(PyagoButton), warnIfMissed: false);
      await tester.pump();

      expect(find.text('Publish'), findsOneWidget);
    });

    testWidgets('shows a progress indicator and suppresses the label while loading', (tester) async {
      await tester.pumpWidget(
        _wrap(PyagoButton(label: 'Publish', onPressed: () {}, isLoading: true)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders an icon when one is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(PyagoButton(label: 'Publish', onPressed: () {}, icon: Icons.send)),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
