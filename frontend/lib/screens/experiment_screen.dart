import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/experiment_config.dart';
import '../logic/simulation_result.dart';
import '../models/experiment_session.dart';
import '../models/simulation_params.dart';
import '../services/api_client.dart';
import '../services/auth_provider.dart';
import '../services/experiment_service.dart';
import '../widgets/circuit_diagrams.dart';
import '../widgets/control_panel.dart';
import '../widgets/info_section.dart';
import '../widgets/results_summary.dart';
import '../widgets/waveform_chart.dart';

class ExperimentScreen extends StatefulWidget {
  final ExperimentConfig config;

  const ExperimentScreen({super.key, required this.config});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  SimulationParams _params = SimulationParams.defaults;
  late SimulationResult _result;
  bool _isSaving = false;
  String? _saveMessage;
  bool _controlsOpen = false;

  @override
  void initState() {
    super.initState();
    _result = _run();
  }

  SimulationResult _run() {
    return widget.config.run(
      waveform: _params.waveform,
      amplitudeV: _params.amplitudeV,
      frequencyHz: _params.frequencyHz,
      resistanceOhm: _params.resistanceOhm,
      capacitanceF: _params.capacitanceF,
    );
  }

  void _recompute() {
    setState(() {
      _result = _run();
      _saveMessage = null;
    });
  }

  Future<void> _saveRun() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      setState(() {
        _saveMessage = 'Could not save: you are not logged in.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveMessage = null;
    });

    final session = ExperimentSession(
      id: null,
      experimentType: widget.config.apiValue,
      waveformType: _params.waveform.name,
      resistanceOhm: _params.resistanceOhm,
      capacitanceF: _params.capacitanceF,
      amplitudeV: _params.amplitudeV,
      frequencyHz: _params.frequencyHz,
      notes: null,
      createdAt: null,
    );

    try {
      await ExperimentService().saveSession(
        token: token,
        session: session,
      );
      if (mounted) {
        setState(() {
          _saveMessage = 'Run saved successfully.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _saveMessage = 'Save failed: ${e.message}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WaveformChart(result: _result),
          ResultsSummary(result: _result, params: _params),
          if (widget.config.type == LabExperiment.differentiator)
            const DifferentiatorCircuitDiagram()
          else
            const IntegratorCircuitDiagram(),
          InfoSection(config: widget.config),
        ],
      ),
    );
  }

  Widget _controls() {
    return ControlPanel(
      params: _params,
      onChanged: (params) {
        setState(() {
          _params = params;
          _result = _run();
          _saveMessage = null;
        });
      },
      onRunPressed: _recompute,
      onSavePressed: _saveRun,
      isSaving: _isSaving,
      saveMessage: _saveMessage,
    );
  }

  Widget _mobileLayout() {
    final drawerWidth = math.min(360.0, MediaQuery.sizeOf(context).width * .9);

    return Stack(
      children: [
        Positioned.fill(child: _content()),
        if (_controlsOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _controlsOpen = false),
              child: const ColoredBox(color: Colors.black26),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          left: _controlsOpen ? 0 : -drawerWidth,
          top: 0,
          bottom: 0,
          width: drawerWidth,
          child: Material(
            elevation: 12,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              right: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                child: _controls(),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
                elevation: 5,
                child: IconButton(
                  tooltip: _controlsOpen ? 'Close controls' : 'Open controls',
                  color: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () =>
                      setState(() => _controlsOpen = !_controlsOpen),
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: AlwaysStoppedAnimation(_controlsOpen ? 1 : 0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: ControlPanel(
                      params: _params,
                      onChanged: (params) {
                        setState(() {
                          _params = params;
                          _result = _run();
                          _saveMessage = null;
                        });
                      },
                      onRunPressed: _recompute,
                      onSavePressed: _saveRun,
                      isSaving: _isSaving,
                      saveMessage: _saveMessage,
                    ),
                  ),
                ),
                Expanded(child: _content()),
              ],
            );
          }

          return _mobileLayout();
        },
      ),
    );
  }
}
