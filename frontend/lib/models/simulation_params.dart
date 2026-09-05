import '../logic/waveform_generator.dart';

class SimulationParams {
  final double resistanceOhm;
  final double capacitanceNf;
  final double amplitudeV;
  final double frequencyHz;
  final WaveformType waveform;

  const SimulationParams({
    required this.resistanceOhm,
    required this.capacitanceNf,
    required this.amplitudeV,
    required this.frequencyHz,
    required this.waveform,
  });

  double get capacitanceF => capacitanceNf * 1e-9;

  SimulationParams copyWith({
    double? resistanceOhm,
    double? capacitanceNf,
    double? amplitudeV,
    double? frequencyHz,
    WaveformType? waveform,
  }) {
    return SimulationParams(
      resistanceOhm: resistanceOhm ?? this.resistanceOhm,
      capacitanceNf: capacitanceNf ?? this.capacitanceNf,
      amplitudeV: amplitudeV ?? this.amplitudeV,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      waveform: waveform ?? this.waveform,
    );
  }

  static const defaults = SimulationParams(
    resistanceOhm: 10000,
    capacitanceNf: 100,
    amplitudeV: 5,
    frequencyHz: 100,
    waveform: WaveformType.sine,
  );
}
