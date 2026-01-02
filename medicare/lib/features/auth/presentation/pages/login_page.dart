import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthProvider>().login(email, password);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Listen for state changes (side effects are tricky in build, but for simple snackbars we can use a listener or check status change)
          // Ideally, use a addPostFrameCallback or a separate listener widget.
          // For simplicity in Provider, we often handle side effects in the view explicitly or use a package like provider_architecture or just check state in build carefully.
          // However, showing SnackBar during build is forbidden.
          // Better approach: use a cohesive listener pattern or Check status in `didUpdateWidget` or similar.
          // Given the prompt "simple but functional", I will check status and show snackbar only if it changed? No, that triggers every build.
          // Correct pattern with vanilla Provider: Use `addListener` in `initState` or similar.
          // Refactoring to keep it simple: We will handle navigation/snackbar in the button callback await?
          // No, the provider is void.
          // Let's stick to a Listener wrapper widget or add a listener in initState.

          if (authProvider.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (authProvider.status == AuthStatus.error) ...[
                  Text(
                    authProvider.errorMessage ?? 'Erro',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                ],
                if (authProvider.status == AuthStatus.success) ...[
                  Text(
                    'Bem-vindo, ${authProvider.user?.name}!',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onLogin,
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
