import 'dart:math' as math;

enum WaveformType { sine, square, triangle }

class WaveformGenerator {
  static double valueAt({
    required WaveformType type,
    required double amplitude,
    required double frequencyHz,
    required double timeSeconds,
  }) {
    final period = 1 / frequencyHz;
    final phase = (timeSeconds % period) / period;

    switch (type) {
      case WaveformType.sine:
        return amplitude *
            math.sin(2 * math.pi * frequencyHz * timeSeconds);
      case WaveformType.square:
        return phase < 0.5 ? amplitude : -amplitude;
      case WaveformType.triangle:
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
    int pointsPerCycle = 240,
  }) {
    final period = 1 / frequencyHz;
    final totalPoints = cycles * pointsPerCycle;
    final dt = (period * cycles) / totalPoints;

    return List<double>.generate(
      totalPoints + 1,
      (i) => i * dt,
    );
  }
}
