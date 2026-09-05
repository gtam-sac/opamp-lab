import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../logic/simulation_result.dart';

class WaveformChart extends StatelessWidget {
  final SimulationResult result;

  const WaveformChart({super.key, required this.result});

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < result.time.length; i++)
          FlSpot(result.time[i], values[i]),
      ],
      isCurved: false,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }

  LineChartData _chartData({
    required List<double> values,
    required Color color,
  }) {
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
          axisNameWidget: const Text('Time (s)'),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(3),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: LineChart(_chartData(values: values, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outputColor =
        result.isSaturating ? Colors.orange : Colors.deepOrange;

    return Column(
      children: [
        _chart(
          title: 'Input Voltage (Vin) vs Time',
          values: result.vin,
          color: Colors.blue,
        ),
        _chart(
          title: 'Output Voltage (Vout) vs Time',
          values: result.vout,
          color: outputColor,
        ),
      ],
    );
  }
}
