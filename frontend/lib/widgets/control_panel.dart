import 'package:flutter/material.dart';

import '../logic/waveform_generator.dart';
import '../models/simulation_params.dart';

class ControlPanel extends StatelessWidget {
  final SimulationParams params;
  final ValueChanged<SimulationParams> onChanged;
  final VoidCallback onRunPressed;
  final VoidCallback onResetPressed;
  final bool isRunning;

  const ControlPanel({
    super.key,
    required this.params,
    required this.onChanged,
    required this.onRunPressed,
    required this.onResetPressed,
    required this.isRunning,
  });

  String _formatResistance(double value) =>
      'Value: ${(value / 1000).toStringAsFixed(1)} kΩ';

  String _formatCapacitance(double value) =>
      'Value: ${(value / 1000).toStringAsFixed(1)} µF';

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueText,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            valueText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulation Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _slider(
              label: 'Resistance (R)',
              value: params.resistanceOhm,
              min: 100,
              max: 100000,
              divisions: 999,
              valueText: _formatResistance(params.resistanceOhm),
              onChanged: (value) => onChanged(
                params.copyWith(resistanceOhm: value),
              ),
            ),
            _slider(
              label: 'Capacitance (C)',
              value: params.capacitanceNf,
              min: 100,
              max: 10000,
              divisions: 99,
              valueText: _formatCapacitance(params.capacitanceNf),
              onChanged: (value) => onChanged(
                params.copyWith(capacitanceNf: value),
              ),
            ),
            _slider(
              label: 'Amplitude',
              value: params.amplitudeV,
              min: 0.5,
              max: 10,
              divisions: 95,
              valueText: 'Value: ${params.amplitudeV.toStringAsFixed(1)} V',
              onChanged: (value) => onChanged(
                params.copyWith(amplitudeV: value),
              ),
            ),
            _slider(
              label: 'Frequency',
              value: params.frequencyHz,
              min: 10,
              max: 2000,
              divisions: 199,
              valueText: 'Value: ${params.frequencyHz.round()} Hz',
              onChanged: (value) => onChanged(
                params.copyWith(frequencyHz: value),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Waveform',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WaveformType.values.map((type) {
                return ChoiceChip(
                  label: Text(
                    type.name[0].toUpperCase() + type.name.substring(1),
                  ),
                  selected: params.waveform == type,
                  onSelected: (_) => onChanged(
                    params.copyWith(waveform: type),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRunPressed,
                    icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(isRunning ? 'STOP' : 'RUN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? Theme.of(context).colorScheme.error
                          : null,
                      foregroundColor: isRunning
                          ? Theme.of(context).colorScheme.onError
                          : null,
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onResetPressed,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('RESET'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Reset restores the default circuit values and stops the simulation.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
