import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/ui/view_model/auth_view_model.dart';

class DoctorDashboardWidget extends StatelessWidget {
  const DoctorDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthViewModel, dynamic>((vm) => vm.user);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo, Dr. ${user?.name ?? 'Médico'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  title: 'Planos Ativos',
                  value: '5',
                  icon: Icons.assignment_turned_in,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  title: 'Pacientes',
                  value: '12',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _DashboardCard(
            title: 'Próximas Consultas',
            value: '3 Hoje',
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
