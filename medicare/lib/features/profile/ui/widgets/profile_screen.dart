import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter
import '../view_model/profile_view_model.dart';
import '../../../core/utils/phone_input_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    // Load profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Update controllers when profile changes
  void _updateControllers(ProfileViewModel viewModel) {
    if (viewModel.profile != null && !viewModel.isEditing) {
      if (_nameController.text != viewModel.profile!.name) {
        _nameController.text = viewModel.profile!.name;
      }
      if (_phoneController.text.replaceAll(RegExp(r'[^0-9]'), '') !=
          (viewModel.profile!.phone ?? '')) {
        _phoneController.text = PhoneInputFormatter.format(
          viewModel.profile!.phone ?? '',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          Consumer<ProfileViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(viewModel.isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  if (viewModel.isEditing) {
                    viewModel.saveProfile(
                      _nameController.text,
                      _phoneController.text,
                    );
                  } else {
                    viewModel.toggleEdit();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          _updateControllers(viewModel);

          if (viewModel.isLoading && viewModel.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.profile == null) {
            return Center(child: Text('Erro: ${viewModel.errorMessage}'));
          }

          final profile = viewModel.profile;
          if (profile == null) return const SizedBox.shrink();

          // Initials for avatar
          final initials = profile.name.trim().isNotEmpty
              ? profile.name.trim().split(' ').map((e) => e[0]).take(2).join()
              : '?';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  readOnly: !viewModel.isEditing,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: viewModel.isEditing
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  readOnly: !viewModel.isEditing,
                  keyboardType: TextInputType.number, // Input numérico
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Garante que só entra número antes do custom
                    PhoneInputFormatter(), // Aplica a máscara
                  ],
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: viewModel.isEditing
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                  ),
                ),

                if (profile.userType == 'medico') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: profile.crm,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'CRM',
                      border: InputBorder.none,
                    ),
                  ),
                ],

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.logout(context),
                    child: const Text('Sair do Aplicativo'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
