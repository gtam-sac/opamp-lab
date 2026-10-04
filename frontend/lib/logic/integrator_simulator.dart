import 'dart:math' as math;

import 'simulation_result.dart';
import 'waveform_generator.dart';

class IntegratorSimulator {
  static SimulationResult run({
    required WaveformType waveform,
    required double amplitudeV,
    required double frequencyHz,
    required double resistanceOhm,
    required double capacitanceF,
  }) {
    WaveformGenerator.validateSimulationParameters(
      amplitudeV: amplitudeV,
      frequencyHz: frequencyHz,
      resistanceOhm: resistanceOhm,
      capacitanceF: capacitanceF,
    );
    final time = WaveformGenerator.generateTimeAxis(frequencyHz: frequencyHz);
    final vin = time
        .map(
          (t) => WaveformGenerator.valueAt(
            type: waveform,
            amplitude: amplitudeV,
            frequencyHz: frequencyHz,
            timeSeconds: t,
          ),
        )
        .toList();

    final rc = resistanceOhm * capacitanceF;
    final n = time.length;
    final vout = List<double>.filled(n, 0);
    double integral = 0;

    for (int i = 1; i < n; i++) {
      final dt = time[i] - time[i - 1];
      integral += (vin[i] + vin[i - 1]) / 2 * dt;
      vout[i] = -(1 / rc) * integral;
    }

    // An ideal integrator's DC initial condition is arbitrary. Center this
    // periodic steady-state trace so a sine input displays its cosine response.
    final mean = vout.reduce((sum, value) => sum + value) / n;
    for (int i = 0; i < n; i++) {
      vout[i] = (vout[i] - mean)
          .clamp(-kOpAmpSaturationVoltage, kOpAmpSaturationVoltage)
          .toDouble();
    }

    final peak = vout.fold<double>(0, (p, v) => math.max(p, v.abs()));

    return SimulationResult(
      time: time,
      vin: vin,
      vout: vout,
      rcSeconds: rc,
      cornerFrequencyHz: 1 / (2 * math.pi * rc),
      outputPeakV: peak,
    );
  }
}
