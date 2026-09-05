import 'package:flutter/material.dart';

import '../logic/simulation_result.dart';
import '../models/simulation_params.dart';

class ResultsSummary extends StatelessWidget {
  final SimulationResult result;
  final SimulationParams params;

  const ResultsSummary({
    super.key,
    required this.result,
    required this.params,
  });

  String _timeConstant(double seconds) {
    if (seconds >= 1) return '${seconds.toStringAsFixed(2)} s';
    if (seconds >= 1e-3) {
      return '${(seconds * 1e3).toStringAsFixed(2)} ms';
    }
    return '${(seconds * 1e6).toStringAsFixed(2)} µs';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = params.frequencyHz / result.cornerFrequencyHz;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'CALCULATED',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            _row('Time constant τ = RC', _timeConstant(result.rcSeconds)),
            _row(
              'Corner frequency fc',
              '${result.cornerFrequencyHz.toStringAsFixed(2)} Hz',
            ),
            Text(
              'Your input frequency is ~${ratio.toStringAsFixed(2)}× the corner frequency.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            const Text(
              'USER INPUT',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            _row('Resistance R', '${params.resistanceOhm.round()} Ω'),
            _row(
              'Capacitance C',
              '${params.capacitanceNf.toStringAsFixed(0)} nF',
            ),
            _row(
              'Amplitude',
              '${params.amplitudeV.toStringAsFixed(2)} V',
            ),
            _row(
              'Frequency',
              '${params.frequencyHz.toStringAsFixed(1)} Hz',
            ),
            _row(
              'Waveform',
              params.waveform.name[0].toUpperCase() +
                  params.waveform.name.substring(1),
            ),
            const Divider(height: 24),
            _row(
              'Computed output peak',
              '${result.outputPeakV.toStringAsFixed(2)} V',
            ),
            if (result.isSaturating) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '⚠ Output has reached the simulated op-amp supply-rail limit '
                  '(±13.5 V) and is clipping. Try reducing R, C, or amplitude.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'This is an idealized educational simulation based on ideal '
              'op-amp equations, not a physically perfect circuit.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
