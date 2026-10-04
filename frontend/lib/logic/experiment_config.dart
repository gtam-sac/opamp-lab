import 'differentiator_simulator.dart';
import 'integrator_simulator.dart';
import 'simulation_result.dart';
import 'waveform_generator.dart';

enum LabExperiment { differentiator, integrator }

typedef RunSimulation = SimulationResult Function({
  required WaveformType waveform,
  required double amplitudeV,
  required double frequencyHz,
  required double resistanceOhm,
  required double capacitanceF,
});

class ExperimentConfig {
  final LabExperiment type;
  final String title;
  final String formula;
  final String principle;
  final List<String> keyPoints;
  final RunSimulation run;

  const ExperimentConfig({
    required this.type,
    required this.title,
    required this.formula,
    required this.principle,
    required this.keyPoints,
    required this.run,
  });

  static const differentiator = ExperimentConfig(
    type: LabExperiment.differentiator,
    title: 'Op-Amp Differentiator',
    formula: 'Vout(t) = −RC · dVin/dt',
    principle:
        'An op-amp differentiator outputs a voltage proportional to the rate '
        'of change of the input. The input capacitor passes changing signals '
        'as current into the inverting input (a virtual ground); the feedback '
        'resistor converts that current back into an output voltage.',
    keyPoints: [
      'Increasing R or C increases the output magnitude for the same input.',
      'Sharp edges (square wave) produce large, narrow spikes because dV/dt is huge at a transition.',
      'A sine input produces a negative-cosine output, lagging the input by 90°.',
      'A triangle wave (constant-slope segments) produces a square-wave output.',
      'This is an idealized simulation — real differentiators add a small series resistor to tame high-frequency noise gain, which this simplified model omits.',
    ],
    run: DifferentiatorSimulator.run,
  );

  static const integrator = ExperimentConfig(
    type: LabExperiment.integrator,
    title: 'Op-Amp Integrator',
    formula: 'Vout(t) = −(1/RC) · ∫ Vin dt',
    principle:
        'An op-amp integrator outputs a voltage proportional to the running '
        'accumulation (area under the curve) of the input signal. The input '
        'resistor sets a current into the virtual-ground inverting input; the '
        'feedback capacitor accumulates that current as charge, producing an '
        'output voltage.',
    keyPoints: [
      'Increasing R or C decreases the output magnitude for the same input.',
      'A square-wave input produces a triangle-wave output.',
      'A sine input produces a positive-cosine output, leading the input by 90°.',
      'A triangle-wave input produces a parabolic (piecewise-quadratic) output.',
      'The periodic response is centered to show its steady-state waveform; a real integrator can drift without a leakage/reset path.',
    ],
    run: IntegratorSimulator.run,
  );
}
