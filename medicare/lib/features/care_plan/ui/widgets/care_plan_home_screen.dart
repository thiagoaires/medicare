import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/ui/view_model/auth_view_model.dart';
import '../view_model/care_plan_view_model.dart';
import 'care_plan_form_screen.dart';
import '../../../check_in/ui/widgets/daily_check_in_button.dart';
import '../../../check_in/ui/view_model/check_in_view_model.dart';
import '../../../../injection_container.dart';

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

  void _navigateToForm({dynamic plan}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<CarePlanViewModel>(),
          child: CarePlanFormScreen(planToEdit: plan),
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // Refresh list
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<CarePlanViewModel>().fetchPlans(user.id, user.type);
      }
    }
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

          return Column(
            children: [
              if (!isDoctor && viewModel.plans.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ChangeNotifierProvider(
                    create: (_) => sl<CheckInViewModel>(),
                    child: DailyCheckInButton(planId: viewModel.plans.first.id),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.plans.length,
                  itemBuilder: (context, index) {
                    final plan = viewModel.plans[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        title: Text(plan.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.description),
                            const SizedBox(height: 4),
                            Text(
                              'Paciente: ${plan.patientName ?? plan.patientId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(plan.startDate.toString().split(' ')[0]),
                            if (isDoctor)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _navigateToForm(plan: plan),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton(
              onPressed: () => _navigateToForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
