import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/ui/view_model/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      final isLoggedIn = await authViewModel.checkAuthStatus();

      if (!mounted) return;

      if (isLoggedIn) {
        final user = authViewModel.user;
        if (user != null) {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: user.userType,
          );
        } else {
          // Fallback to login if user object missing despite 'true' (unlikely)
          Navigator.pushReplacementNamed(
            context,
            '/',
          ); // Assuming / is login or handled
        }
      } else {
        // Not logged in, go to Login
        // Assuming LoginScreen is home or '/' or specific route.
        // User request: "Navegue para /login (Navigator.pushReplacementNamed)"
        // But main.dart has 'home: LoginScreen()'. I should probable make LoginScreen accessible via route too or just use '/' if mapped.
        // I'll assume we might need to verify main.dart routes.
        // For now, I'll use simple pushReplacement to LoginScreen if I can import it,
        // OR use a named route if defined.
        // User asked for "Navigator.pushReplacementNamed".
        // I will use '/login' for clarity, need to ensure it's registered in main.dart.
        // OR since main.dart sets home: SplashScreen, I should navigate to LoginScreen.

        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
