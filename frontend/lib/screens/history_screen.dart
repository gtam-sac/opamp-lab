import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/experiment_session.dart';
import '../services/api_client.dart';
import '../services/auth_provider.dart';
import '../services/experiment_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ExperimentSession> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'You are not logged in.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessions = await ExperimentService().listSessions(token);
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _deleteSession(ExperimentSession session) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || session.id == null) return;

    try {
      await ExperimentService().deleteSession(token, session.id!);
      await _loadSessions();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} ${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _experimentName(String value) {
    return value == 'differentiator' ? 'Differentiator' : 'Integrator';
  }

  String _waveformName(String value) =>
      value[0].toUpperCase() + value.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Runs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _sessions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _sessions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No saved runs yet — try an experiment and tap '
                          '**Save This Run**.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSessions,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                session.experimentType == 'differentiator'
                                    ? Icons.show_chart
                                    : Icons.stacked_line_chart,
                              ),
                              title: Text(
                                '${_experimentName(session.experimentType)} — '
                                '${_waveformName(session.waveformType)} wave',
                              ),
                              subtitle: Text(
                                'R: ${session.resistanceOhm.round()} Ω  •  '
                                'C: ${(session.capacitanceF * 1e9).round()} nF\n'
                                'A: ${session.amplitudeV.toStringAsFixed(2)} V  •  '
                                'f: ${session.frequencyHz.toStringAsFixed(1)} Hz\n'
                                '${_formatDate(session.createdAt)}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                tooltip: 'Delete',
                                onPressed: () => _deleteSession(session),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
