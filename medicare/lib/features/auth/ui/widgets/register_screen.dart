import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedType = 'paciente';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().resetState();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.register(
        name: name,
        email: email,
        password: password,
        type: _selectedType,
      );

      if (!mounted) return;

      if (authViewModel.status == AuthStatus.success &&
          authViewModel.user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {
            'userType': authViewModel.user!.type,
            'userId': authViewModel.user!.id,
          },
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          if (authViewModel.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (authViewModel.status == AuthStatus.error) ...[
                  Text(
                    authViewModel.errorMessage ?? 'Erro',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                ],
                if (authViewModel.status == AuthStatus.success) ...[
                  const Text(
                    'Conta criada com sucesso!',
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Usuário',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'paciente',
                      child: Text('Paciente'),
                    ),
                    DropdownMenuItem(value: 'medico', child: Text('Médico')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onRegister,
                  child: const Text('Cadastrar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
