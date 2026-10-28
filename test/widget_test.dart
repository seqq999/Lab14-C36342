import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focustrack_movil/main.dart';

void main() {
  testWidgets('Incrementa y decrementa metas', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusTrackApp());

    expect(find.text('0 / 5'), findsOneWidget);
    expect(find.text('Inicial'), findsOneWidget);

    await tester.tap(find.byTooltip('Completar meta'));
    await tester.pump();
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text('En Progreso'), findsOneWidget);

    await tester.tap(find.byTooltip('Restar meta completada'));
    await tester.pump();
    expect(find.text('0 / 5'), findsOneWidget);
  });

  testWidgets('No permite superar el limite de 10 metas',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FocusTrackApp());

    for (var i = 0; i < 11; i++) {
      await tester.tap(find.byTooltip('Completar meta'));
      await tester.pump();
    }

    expect(find.text('10 / 5'), findsOneWidget);
    expect(
      find.textContaining('límite máximo diario de metas (10/10)'),
      findsOneWidget,
    );
  });

  testWidgets('El selector de prioridad actualiza el panel',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FocusTrackApp());

    expect(find.textContaining('Prioridad Media'), findsOneWidget);

    await tester.tap(find.text('Alta'));
    await tester.pump();
    expect(find.textContaining('Prioridad Alta'), findsOneWidget);
  });

  testWidgets('Reinicia contadores tras confirmar', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusTrackApp());

    await tester.tap(find.byTooltip('Completar meta'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 5'), findsOneWidget);
  });
}
