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
  late TextEditingController _crmController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _crmController = TextEditingController();

    // Load profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _crmController.dispose();
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
      if (_crmController.text != (viewModel.profile!.crm ?? '')) {
        _crmController.text = viewModel.profile!.crm ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        viewModel.isEditing ? Icons.check : Icons.edit_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      onPressed: () {
                        if (viewModel.isEditing) {
                          viewModel.saveProfile(
                            _nameController.text,
                            _phoneController.text,
                            _crmController.text,
                          );
                        } else {
                          viewModel.toggleEdit();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          child: Text(
                            initials.toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneInputFormatter(),
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
                    controller: _crmController,
                    readOnly: !viewModel.isEditing,
                    decoration: InputDecoration(
                      labelText: 'CRM',
                      border: viewModel.isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                  ),
                ],

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair do Aplicativo'),
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
