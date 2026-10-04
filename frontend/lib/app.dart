import 'package:flutter/material.dart';

import 'logic/experiment_config.dart';
import 'screens/experiment_screen.dart';
import 'theme/app_theme.dart';

class OpAmpLabApp extends StatelessWidget {
  const OpAmpLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Op-Amp Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ExperimentScreen(
        config: ExperimentConfig.differentiator,
      ),
    );
  }
}
