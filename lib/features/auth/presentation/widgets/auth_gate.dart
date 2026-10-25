import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/features/auth/presentation/pages/login_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/main_shell_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const MainShellScreen();
    }

    return const LoginScreen();
  }
}