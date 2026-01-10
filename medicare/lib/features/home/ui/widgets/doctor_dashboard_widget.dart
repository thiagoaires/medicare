import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  crossAxisCount: 1,
                  childAspectRatio: 1.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _DashboardCard(
                      title: 'Planos Ativos',
                      value: '$totalPlans',
                      svgAsset: 'assets/svg/medical_prescription_amico.svg',
                      onTap: () => context.read<HomeViewModel>().setIndex(1),
                    ),
                    _DashboardCard(
                      title: 'Adesão Hoje',
                      value: '$checkInsToday',
                      svgAsset: 'assets/svg/doctor_amico.svg',
                    ),
                    _DashboardCard(
                      title: 'Próximas Consultas',
                      value: '-',
                      svgAsset: 'assets/svg/online_doctor_amico.svg',
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
  final String svgAsset;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.svgAsset,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(svgAsset, height: 144),
            ],
          ),
        ),
      ),
    );
  }
}
