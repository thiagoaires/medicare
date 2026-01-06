import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/ui/view_model/auth_view_model.dart';
import '../view_model/care_plan_view_model.dart';
import 'create_care_plan_screen.dart';

class CarePlanHomeScreen extends StatefulWidget {
  const CarePlanHomeScreen({super.key});

  @override
  State<CarePlanHomeScreen> createState() => _CarePlanHomeScreenState();
}

class _CarePlanHomeScreenState extends State<CarePlanHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final user = authViewModel.user;
      if (user != null) {
        context.read<CarePlanViewModel>().fetchPlans(
          user.id,
          user.type,
        ); // user.type field name correction
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access property via method or getter to ensure type safety if possible, or dynamic
    // Ideally AuthViewModel should be properly typed in selector.
    // Assuming AuthViewModel exposes 'user' which is UserEntity?.
    final user = context.select<AuthViewModel, dynamic>((vm) => vm.user);
    final isDoctor = user?.type == 'medico';

    return Scaffold(
      appBar: AppBar(title: const Text('Planos de Cuidado')),
      body: Consumer<CarePlanViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('Erro: ${viewModel.errorMessage}'));
          }

          if (viewModel.plans.isEmpty) {
            return const Center(child: Text('Nenhum plano encontrado.'));
          }

          return ListView.builder(
            itemCount: viewModel.plans.length,
            itemBuilder: (context, index) {
              final plan = viewModel.plans[index];
              return ListTile(
                title: Text(plan.title),
                subtitle: Text(plan.description),
                trailing: Text(plan.startDate.toString().split(' ')[0]),
              );
            },
          );
        },
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCarePlanScreen(),
                  ),
                );

                if (result == true && mounted) {
                  // Refresh list
                  final user = context.read<AuthViewModel>().user;
                  if (user != null) {
                    context.read<CarePlanViewModel>().fetchPlans(
                      user.id,
                      user.type,
                    );
                  }
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
