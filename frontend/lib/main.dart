import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:opamp_lab_frontend/app.dart';
import 'package:opamp_lab_frontend/services/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const OpAmpLabApp(),
    ),
  );
}