import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../logic/simulation_result.dart';

class WaveformChart extends StatefulWidget {
  final SimulationResult result;
  final bool isRunning;

  const WaveformChart({
    super.key,
    required this.result,
    required this.isRunning,
  });

  @override
  State<WaveformChart> createState() => _WaveformChartState();
}

class _WaveformChartState extends State<WaveformChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  SimulationResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant WaveformChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.isRunning) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _animatedValues(List<double> values) {
    if (!widget.isRunning || values.length < 2) return values;
    final shift = (_controller.value * values.length).round() % values.length;
    return [...values.skip(shift), ...values.take(shift)];
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < result.time.length; i++)
          FlSpot(result.time[i], values[i]),
      ],
      isCurved: false,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
    );
  }

  LineChartData _chartData(List<double> values, Color color) {
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY).abs() * 0.12).clamp(0.5, double.infinity);

    return LineChartData(
      minX: result.time.first,
      maxX: result.time.last,
      minY: minY - padding,
      maxY: maxY + padding,
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: true),
      lineBarsData: [_line(values, color)],
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text('Voltage (V)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Time (ms)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) => Text(
              (value * 1000).toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _chart({
    required String title,
    required List<double> values,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            _legend(color, title.contains('Input') ? 'Vin' : 'Vout'),
            const SizedBox(height: 8),
            SizedBox(
              height: 340,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => LineChart(
                  _chartData(_animatedValues(values), color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _chart(
          title: 'Input Waveform',
          values: result.vin,
          color: Colors.blue,
        ),
        _chart(
          title: 'Output Waveform',
          values: result.vout,
          color: Colors.deepOrange,
        ),
        if (result.isSaturating)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Output clipped at ±${kOpAmpSaturationVoltage.toStringAsFixed(1)} V',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
