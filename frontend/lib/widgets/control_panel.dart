import 'package:flutter/material.dart';

import '../logic/waveform_generator.dart';
import '../models/simulation_params.dart';

class ControlPanel extends StatelessWidget {
  final SimulationParams params;
  final ValueChanged<SimulationParams> onChanged;
  final VoidCallback onRunPressed;
  final VoidCallback onSavePressed;
  final bool isSaving;
  final String? saveMessage;

  const ControlPanel({
    super.key,
    required this.params,
    required this.onChanged,
    required this.onRunPressed,
    required this.onSavePressed,
    required this.isSaving,
    required this.saveMessage,
  });

  String _formatResistance(double value) =>
      '${value.round()} Ω';

  String _formatCapacitance(double value) =>
      '${value.round()} nF';

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String valueText,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(valueText),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
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
              min: 1000,
              max: 100000,
              valueText: _formatResistance(params.resistanceOhm),
              onChanged: (value) => onChanged(
                params.copyWith(resistanceOhm: value),
              ),
            ),
            _slider(
              label: 'Capacitance (C)',
              value: params.capacitanceNf,
              min: 1,
              max: 1000,
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
              valueText: '${params.amplitudeV.toStringAsFixed(1)} V',
              onChanged: (value) => onChanged(
                params.copyWith(amplitudeV: value),
              ),
            ),
            _slider(
              label: 'Frequency',
              value: params.frequencyHz,
              min: 10,
              max: 2000,
              valueText: '${params.frequencyHz.round()} Hz',
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
            ElevatedButton.icon(
              onPressed: onRunPressed,
              icon: const Icon(Icons.play_arrow),
              label: const Text('RUN / UPDATE SIMULATION'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: isSaving ? null : onSavePressed,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : 'Save This Run'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
            ),
            if (saveMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                saveMessage!,
                style: TextStyle(
                  color: saveMessage!.toLowerCase().contains('failed') ||
                          saveMessage!.toLowerCase().contains('could not')
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
