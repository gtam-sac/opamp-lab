import 'dart:math' as math;

enum WaveformType { sine, square, triangle }

class WaveformGenerator {
  static const samplesPerCycle = 240;

  static void validateSimulationParameters({
    required double amplitudeV,
    required double frequencyHz,
    required double resistanceOhm,
    required double capacitanceF,
  }) {
    if (!amplitudeV.isFinite || amplitudeV <= 0) {
      throw ArgumentError.value(
          amplitudeV, 'amplitudeV', 'Must be finite and positive.');
    }
    if (!frequencyHz.isFinite || frequencyHz <= 0) {
      throw ArgumentError.value(
          frequencyHz, 'frequencyHz', 'Must be finite and positive.');
    }
    if (!resistanceOhm.isFinite || resistanceOhm <= 0) {
      throw ArgumentError.value(
          resistanceOhm, 'resistanceOhm', 'Must be finite and positive.');
    }
    if (!capacitanceF.isFinite || capacitanceF <= 0) {
      throw ArgumentError.value(
          capacitanceF, 'capacitanceF', 'Must be finite and positive.');
    }
    final rc = resistanceOhm * capacitanceF;
    if (!rc.isFinite || rc <= 0 || !(1 / rc).isFinite) {
      throw ArgumentError(
          'The selected R and C values produce an invalid RC time constant.');
    }
    final period = 1 / frequencyHz;
    final sampleInterval = period / samplesPerCycle;
    if (!period.isFinite || !sampleInterval.isFinite || sampleInterval <= 0) {
      throw ArgumentError(
          'The selected frequency is outside the numerical sampling range.');
    }
  }

  static double valueAt({
    required WaveformType type,
    required double amplitude,
    required double frequencyHz,
    required double timeSeconds,
  }) {
    if (!amplitude.isFinite ||
        !frequencyHz.isFinite ||
        frequencyHz <= 0 ||
        !timeSeconds.isFinite) {
      throw ArgumentError(
          'Waveform parameters and time must be finite; frequency must be positive.');
    }
    switch (type) {
      case WaveformType.sine:
        return amplitude * math.sin(2 * math.pi * frequencyHz * timeSeconds);
      case WaveformType.square:
        final period = 1 / frequencyHz;
        var timeInPeriod = timeSeconds % period;
        if (timeInPeriod < 0) timeInPeriod += period;
        return timeInPeriod < period / 2 ? amplitude : -amplitude;
      case WaveformType.triangle:
        final phase = ((timeSeconds * frequencyHz) % 1 + 1) % 1;
        if (phase < 0.25) return 4 * amplitude * phase;
        if (phase < 0.75) {
          return 2 * amplitude - 4 * amplitude * phase;
        }
        return -4 * amplitude + 4 * amplitude * phase;
    }
  }

  static List<double> generateTimeAxis({
    required double frequencyHz,
    int cycles = 3,
    int pointsPerCycle = samplesPerCycle,
  }) {
    if (!frequencyHz.isFinite || frequencyHz <= 0) {
      throw ArgumentError.value(
          frequencyHz, 'frequencyHz', 'Must be finite and positive.');
    }
    if (cycles <= 0 || pointsPerCycle < 4) {
      throw ArgumentError(
          'Cycles must be positive and pointsPerCycle must be at least 4.');
    }
    final period = 1 / frequencyHz;
    final duration = period * cycles;
    if (!period.isFinite || !duration.isFinite) {
      throw ArgumentError(
          'The selected frequency is outside the time-axis range.');
    }
    final totalPoints = cycles * pointsPerCycle;
    final dt = duration / totalPoints;
    if (!dt.isFinite || dt <= 0) {
      throw ArgumentError(
          'The selected frequency cannot be represented by the time axis.');
    }

    return List<double>.generate(
      totalPoints,
      (i) => i * dt,
    );
  }
}
