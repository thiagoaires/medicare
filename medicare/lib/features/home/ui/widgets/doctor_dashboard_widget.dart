import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/ui/view_model/auth_view_model.dart';
import '../view_model/home_view_model.dart';

class DoctorDashboardWidget extends StatefulWidget {
  const DoctorDashboardWidget({super.key});

  @override
  State<DoctorDashboardWidget> createState() => _DoctorDashboardWidgetState();
}

class _DoctorDashboardWidgetState extends State<DoctorDashboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<HomeViewModel>().fetchDoctorStats(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthViewModel mainly for the name
    final user = context.select<AuthViewModel, dynamic>((vm) => vm.user);

    return Scaffold(
      appBar: AppBar(title: Text('Bem-vindo, Dr. ${user?.name ?? 'Médico'}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<HomeViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = viewModel.stats;
                final totalPlans = stats?.totalPlans ?? 0;
                final checkInsToday = stats?.checkInsToday ?? 0;

                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _DashboardCard(
                      title: 'Planos Ativos',
                      value: '$totalPlans',
                      icon: Icons.assignment,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary, // French Blue
                      onTap: () => context.read<HomeViewModel>().setIndex(1),
                    ),
                    _DashboardCard(
                      title: 'Adesão Hoje',
                      value: '$checkInsToday',
                      icon: Icons.check_circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary, // Dark Cyan
                    ),
                    _DashboardCard(
                      title: 'Próximas Consultas',
                      value: '-',
                      icon: Icons.calendar_today,
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary, // Evergreen (or similar)
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
