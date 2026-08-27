import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/landing/presentation/scanaura_landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LandingGate extends StatefulWidget {
  const LandingGate({
    super.key,
  });

  @override
  State<LandingGate> createState() =>
      _LandingGateState();
}

class _LandingGateState
    extends State<LandingGate> {
  static const String _introSeenKey =
      'scanaura_intro_seen';

  bool _loading = true;
  bool _introSeen = false;

  @override
  void initState() {
    super.initState();
    _loadIntroState();
  }

  Future<void> _loadIntroState() async {
    final preferences =
    await SharedPreferences
        .getInstance();

    final seen =
        preferences.getBool(
          _introSeenKey,
        ) ??
            false;

    if (!mounted) {
      return;
    }

    setState(() {
      _introSeen = seen;
      _loading = false;
    });

    if (seen) {
      context.go('/login');
    }
  }

  Future<void> _markIntroSeen() async {
    final preferences =
    await SharedPreferences
        .getInstance();

    await preferences.setBool(
      _introSeenKey,
      true,
    );
  }

  Future<void> _getStarted() async {
    await _markIntroSeen();

    if (!mounted) {
      return;
    }

    context.go('/register');
  }

  Future<void> _login() async {
    await _markIntroSeen();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  Future<void> _skip() async {
    await _markIntroSeen();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (_introSeen) {
      return const SizedBox.shrink();
    }

    return ScanAuraLandingScreen(
      onGetStarted: _getStarted,
      onLogin: _login,
      onSkip: _skip,
    );
  }
}