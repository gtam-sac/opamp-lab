import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:opamp_lab_frontend/logic/differentiator_simulator.dart';
import 'package:opamp_lab_frontend/logic/integrator_simulator.dart';
import 'package:opamp_lab_frontend/logic/simulation_result.dart';
import 'package:opamp_lab_frontend/logic/waveform_generator.dart';

const _amplitude = 1.0;
const _frequency = 100.0;
const _resistance = 10000.0;
const _capacitance = 100e-9;
const _rc = _resistance * _capacitance;
const _samplesPerCycle = WaveformGenerator.samplesPerCycle;

void main() {
  group('Waveform generation', () {
    test('sine, square, and triangle have the selected amplitude and period',
        () {
      for (final waveform in WaveformType.values) {
        final samples = WaveformGenerator.generateTimeAxis(
          frequencyHz: _frequency,
          cycles: 1,
        ).map(
          (time) => WaveformGenerator.valueAt(
            type: waveform,
            amplitude: 2,
            frequencyHz: _frequency,
            timeSeconds: time,
          ),
        );
        final values = samples.toList();

        expect(values.length, _samplesPerCycle);
        expect(values.reduce((a, b) => a < b ? a : b), closeTo(-2, 1e-9));
        expect(values.reduce((a, b) => a > b ? a : b), closeTo(2, 1e-9));
      }
    });

    test('square wave has only two levels with instantaneous transitions', () {
      final times = WaveformGenerator.generateTimeAxis(
        frequencyHz: _frequency,
        cycles: 1,
      );
      final values = times
          .map(
            (time) => WaveformGenerator.valueAt(
              type: WaveformType.square,
              amplitude: 5,
              frequencyHz: _frequency,
              timeSeconds: time,
            ),
          )
          .toList();
      final transitionIndices = <int>[
        for (int i = 0; i < values.length; i++)
          if (values[i] != values[(i + 1) % values.length]) i,
      ];

      expect(values.toSet(), {-5.0, 5.0});
      expect(transitionIndices,
          [(_samplesPerCycle ~/ 2) - 1, _samplesPerCycle - 1]);
      for (int i = 0; i < values.length; i++) {
        expect(values[i], anyOf(-5.0, 5.0));
      }
    });

    test('rejects non-finite or non-positive simulation parameters', () {
      expect(
        () => _differentiate(WaveformType.sine, frequencyHz: 0),
        throwsArgumentError,
      );
      expect(
        () => _integrate(WaveformType.sine, capacitanceF: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => _differentiate(WaveformType.sine, frequencyHz: 1e-320),
        throwsArgumentError,
      );
      expect(
        () => _integrate(WaveformType.sine, capacitanceF: 1e-320),
        throwsArgumentError,
      );
    });
  });

  group('Differentiator simulation', () {
    test('sine derivative has the correct negative-cosine sign and scale', () {
      final result = _differentiate(WaveformType.sine);
      const expectedPeak = _rc * _amplitude * 2 * math.pi * _frequency;

      expect(result.vout[0], closeTo(-expectedPeak, 0.002));
      expect(result.vout[_samplesPerCycle ~/ 4].abs(), lessThan(0.05));
      expect(
        result.vout[_samplesPerCycle ~/ 2],
        closeTo(expectedPeak, 0.002),
      );
      _expectFiniteAndClipped(result);
    });

    test('square wave transitions produce correctly signed derivative pulses',
        () {
      final result = _differentiate(WaveformType.square, amplitudeV: 5);
      const fallingEdge = _samplesPerCycle ~/ 2;

      expect(result.vout[fallingEdge], 13.5);
      expect(result.vout[0], -13.5);
      expect(result.vout[fallingEdge - 1], 0);
      expect(result.vout[fallingEdge + 1], 0);
      _expectFiniteAndClipped(result);
    });

    test('triangle wave differentiates to two signed flat levels', () {
      final result = _differentiate(WaveformType.triangle);

      expect(
          result.vout[20], closeTo(-4 * _rc * _amplitude * _frequency, 1e-8));
      expect(result.vout[80], closeTo(4 * _rc * _amplitude * _frequency, 1e-8));
      _expectFiniteAndClipped(result);
    });

    test('sine output scales with R, C, frequency, and input amplitude', () {
      final baseline = _differentiate(WaveformType.sine);
      expect(
        _differentiate(WaveformType.sine, resistanceOhm: 2 * _resistance)
            .outputPeakV,
        closeTo(2 * baseline.outputPeakV, 0.003),
      );
      expect(
        _differentiate(WaveformType.sine, capacitanceF: 2 * _capacitance)
            .outputPeakV,
        closeTo(2 * baseline.outputPeakV, 0.003),
      );
      expect(
        _differentiate(WaveformType.sine, frequencyHz: 2 * _frequency)
            .outputPeakV,
        closeTo(2 * baseline.outputPeakV, 0.003),
      );
      expect(
        _differentiate(WaveformType.sine, amplitudeV: 2 * _amplitude)
            .outputPeakV,
        closeTo(2 * baseline.outputPeakV, 0.003),
      );
    });
  });

  group('Integrator simulation', () {
    test('sine integral is a positive-cosine steady-state response', () {
      final result = _integrate(WaveformType.sine);
      const expectedPeak = _amplitude / (_rc * 2 * math.pi * _frequency);

      expect(result.vout[0], closeTo(expectedPeak, 0.002));
      expect(result.vout[_samplesPerCycle ~/ 4].abs(), lessThan(0.002));
      expect(
        result.vout[_samplesPerCycle ~/ 2],
        closeTo(-expectedPeak, 0.002),
      );
      _expectFiniteAndClipped(result);
    });

    test('square wave integrates to linear alternating ramps', () {
      final result = _integrate(WaveformType.square);
      const quarterCycle = _samplesPerCycle ~/ 4;
      const halfCycle = _samplesPerCycle ~/ 2;

      expect(result.vout[quarterCycle], lessThan(result.vout[0]));
      expect(result.vout[halfCycle], lessThan(result.vout[quarterCycle]));
      expect(
          result.vout[3 * quarterCycle], greaterThan(result.vout[halfCycle]));
      _expectFiniteAndClipped(result);
    });

    test('triangle wave integration has opposite signed curvature', () {
      final result = _integrate(WaveformType.triangle);
      final risingCurvature = _secondDifference(result.vout, 30);
      final fallingCurvature = _secondDifference(result.vout, 90);

      expect(risingCurvature, lessThan(0));
      expect(fallingCurvature, greaterThan(0));
      _expectFiniteAndClipped(result);
    });

    test('sine output scales inversely with R, C, and frequency and with input',
        () {
      final baseline = _integrate(WaveformType.sine);
      expect(
        _integrate(WaveformType.sine, resistanceOhm: 2 * _resistance)
            .outputPeakV,
        closeTo(baseline.outputPeakV / 2, 0.002),
      );
      expect(
        _integrate(WaveformType.sine, capacitanceF: 2 * _capacitance)
            .outputPeakV,
        closeTo(baseline.outputPeakV / 2, 0.002),
      );
      expect(
        _integrate(WaveformType.sine, frequencyHz: 2 * _frequency).outputPeakV,
        closeTo(baseline.outputPeakV / 2, 0.002),
      );
      expect(
        _integrate(WaveformType.sine, amplitudeV: 2 * _amplitude).outputPeakV,
        closeTo(2 * baseline.outputPeakV, 0.002),
      );
    });
  });
}

SimulationResult _differentiate(
  WaveformType waveform, {
  double amplitudeV = _amplitude,
  double frequencyHz = _frequency,
  double resistanceOhm = _resistance,
  double capacitanceF = _capacitance,
}) {
  return DifferentiatorSimulator.run(
    waveform: waveform,
    amplitudeV: amplitudeV,
    frequencyHz: frequencyHz,
    resistanceOhm: resistanceOhm,
    capacitanceF: capacitanceF,
  );
}

SimulationResult _integrate(
  WaveformType waveform, {
  double amplitudeV = _amplitude,
  double frequencyHz = _frequency,
  double resistanceOhm = _resistance,
  double capacitanceF = _capacitance,
}) {
  return IntegratorSimulator.run(
    waveform: waveform,
    amplitudeV: amplitudeV,
    frequencyHz: frequencyHz,
    resistanceOhm: resistanceOhm,
    capacitanceF: capacitanceF,
  );
}

double _secondDifference(List<double> values, int i) =>
    values[i + 1] - 2 * values[i] + values[i - 1];

void _expectFiniteAndClipped(SimulationResult result) {
  expect(result.time.every((value) => value.isFinite), isTrue);
  expect(result.vin.every((value) => value.isFinite), isTrue);
  expect(result.vout.every((value) => value.isFinite), isTrue);
  expect(result.vout.every((value) => value.abs() <= 13.5), isTrue);
}
