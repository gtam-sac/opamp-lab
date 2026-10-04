import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/experiment_config.dart';
import '../logic/simulation_result.dart';
import '../models/simulation_params.dart';
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
  late ExperimentConfig _config;
  SimulationParams _params = SimulationParams.defaults;
  late SimulationResult _result;
  bool _isRunning = false;
  bool _controlsOpen = false;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _result = _run();
  }

  SimulationResult _run() {
    return _config.run(
      waveform: _params.waveform,
      amplitudeV: _params.amplitudeV,
      frequencyHz: _params.frequencyHz,
      resistanceOhm: _params.resistanceOhm,
      capacitanceF: _params.capacitanceF,
    );
  }

  void _toggleSimulation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _result = _run();
      }
    });
  }

  void _selectExperiment(ExperimentConfig config) {
    if (_config.type == config.type) return;
    setState(() {
      _config = config;
      _isRunning = false;
      _result = _run();
    });
  }

  void _updateParams(SimulationParams params) {
    setState(() {
      _params = params;
      _result = _run();
    });
  }

  void _resetSimulation() {
    setState(() {
      _params = SimulationParams.defaults;
      _isRunning = false;
      _result = _run();
    });
  }

  Widget _content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WaveformChart(result: _result, isRunning: _isRunning),
          ResultsSummary(result: _result, params: _params),
          if (_config.type == LabExperiment.differentiator)
            const DifferentiatorCircuitDiagram()
          else
            const IntegratorCircuitDiagram(),
          InfoSection(config: _config),
        ],
      ),
    );
  }

  Widget _controls() {
    return ControlPanel(
      params: _params,
      onChanged: _updateParams,
      onRunPressed: _toggleSimulation,
      onResetPressed: _resetSimulation,
      isRunning: _isRunning,
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
      appBar: AppBar(
        title: Text(_config.title),
        actions: [
          PopupMenuButton<LabExperiment>(
            tooltip: 'Choose experiment',
            icon: const Icon(Icons.swap_horiz),
            onSelected: (experiment) => _selectExperiment(
              experiment == LabExperiment.differentiator
                  ? ExperimentConfig.differentiator
                  : ExperimentConfig.integrator,
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: LabExperiment.differentiator,
                child: Text('Differentiator'),
              ),
              PopupMenuItem(
                value: LabExperiment.integrator,
                child: Text('Integrator'),
              ),
            ],
          ),
        ],
      ),
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
                      onChanged: _updateParams,
                      onRunPressed: _toggleSimulation,
                      onResetPressed: _resetSimulation,
                      isRunning: _isRunning,
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
