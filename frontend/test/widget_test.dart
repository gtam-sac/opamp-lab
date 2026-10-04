import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:opamp_lab_frontend/app.dart';
import 'package:opamp_lab_frontend/widgets/circuit_diagrams.dart';
import 'package:opamp_lab_frontend/widgets/waveform_chart.dart';

void main() {
  testWidgets('Opens directly in the differentiator lab', (tester) async {
    await tester.pumpWidget(const OpAmpLabApp());
    await tester.pump();

    expect(find.text('Op-Amp Differentiator'), findsWidgets);
    expect(find.text('Simulation Controls'), findsOneWidget);
    expect(find.byType(WaveformChart), findsOneWidget);
    expect(find.byType(LineChart), findsNWidgets(2));
    for (final chart in tester.widgetList<LineChart>(find.byType(LineChart))) {
      expect(chart.data.lineBarsData, hasLength(1));
    }
    expect(find.text('Input Waveform'), findsOneWidget);
    expect(find.text('Output Waveform'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(find.text('Sign up'), findsNothing);
    expect(find.text('RESET'), findsOneWidget);
  });

  testWidgets('Switches directly to the integrator lab', (tester) async {
    await tester.pumpWidget(const OpAmpLabApp());
    await tester.tap(find.byTooltip('Choose experiment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Integrator').last);
    await tester.pumpAndSettle();

    expect(find.text('Op-Amp Integrator'), findsWidgets);
    expect(
      tester
          .widget<CircuitDiagram>(find.byType(CircuitDiagram))
          .isDifferentiator,
      isFalse,
    );
    expect(find.text('Login'), findsNothing);
    expect(find.text('Sign up'), findsNothing);
  });

  testWidgets('Circuit diagrams paint within a mobile-width card',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final isDifferentiator in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: CircuitDiagram(isDifferentiator: isDifferentiator),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircuitDiagram), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Waveforms, parameter controls, and reset remain available',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const OpAmpLabApp());
    await tester.pump();

    for (final waveform in ['Sine', 'Square', 'Triangle']) {
      expect(find.widgetWithText(ChoiceChip, waveform), findsOneWidget);
    }

    final updatedValues = [50000.0, 300.0, 7.0, 500.0];
    for (var i = 0; i < updatedValues.length; i++) {
      tester.widget<Slider>(find.byType(Slider).at(i)).onChanged!(
        updatedValues[i],
      );
      await tester.pump();
      expect(
        tester.widget<Slider>(find.byType(Slider).at(i)).value,
        updatedValues[i],
      );
    }
    expect(find.text('Value: 50.0 kΩ'), findsOneWidget);
    expect(find.text('Value: 0.3 µF'), findsOneWidget);

    for (final waveform in ['Square', 'Triangle', 'Sine']) {
      await tester.tap(find.widgetWithText(ChoiceChip, waveform));
      await tester.pump();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, waveform))
            .selected,
        isTrue,
      );
    }

    await tester.tap(find.text('RESET'));
    await tester.pump();
    expect(
      [
        for (final slider in tester.widgetList<Slider>(find.byType(Slider)))
          slider.value,
      ],
      [10000.0, 100.0, 5.0, 100.0],
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Sine'))
          .selected,
      isTrue,
    );
    expect(find.text('STOP'), findsNothing);

    final outputPeaks = <double>[];
    for (final waveform in ['Sine', 'Square', 'Triangle']) {
      await tester.tap(find.widgetWithText(ChoiceChip, waveform));
      await tester.pump();
      outputPeaks.add(
        tester
            .widget<WaveformChart>(find.byType(WaveformChart))
            .result
            .outputPeakV,
      );
    }
    expect(outputPeaks.toSet(), hasLength(3));

    await tester.tap(find.text('RUN'));
    await tester.pump();
    expect(find.text('STOP'), findsOneWidget);
  });
}
