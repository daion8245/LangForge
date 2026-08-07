import 'package:flutter/material.dart';

import 'core/app_scope.dart';
import 'core/theme.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'state/app_state.dart';

class LangForgeApp extends StatefulWidget {
  const LangForgeApp({super.key});

  @override
  State<LangForgeApp> createState() => _LangForgeAppState();
}

class _LangForgeAppState extends State<LangForgeApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (context, _) => MaterialApp(
          title: 'LangForge',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: _state.themeMode,
          // Onboarding and the shell swap at the root rather than pushing,
          // so Reset progress can return here without unwinding a stack.
          home: _state.onboarded ? const HomeShell() : const OnboardingScreen(),
        ),
      ),
    );
  }
}
