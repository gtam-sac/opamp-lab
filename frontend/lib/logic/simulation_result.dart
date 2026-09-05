const double kOpAmpSaturationVoltage = 13.5;

class SimulationResult {
  final List<double> time;
  final List<double> vin;
  final List<double> vout;
  final double rcSeconds;
  final double cornerFrequencyHz;
  final double outputPeakV;

  const SimulationResult({
    required this.time,
    required this.vin,
    required this.vout,
    required this.rcSeconds,
    required this.cornerFrequencyHz,
    required this.outputPeakV,
  });

  bool get isSaturating =>
      outputPeakV >= kOpAmpSaturationVoltage - 0.05;
}
