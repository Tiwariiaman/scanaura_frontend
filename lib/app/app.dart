import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'theme/app_theme.dart';

class ScanAuraApp extends StatelessWidget {
  final GoRouter router;

  const ScanAuraApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'ScanAura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Keep your existing theme/configuration here.
    );
  }
}