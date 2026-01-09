import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../care_plan/ui/widgets/care_plan_home_screen.dart';
import '../../../care_plan/ui/view_model/care_plan_view_model.dart';
import '../../../profile/ui/widgets/profile_screen.dart';
import '../../../check_in/ui/widgets/check_in_dialog.dart';
import '../../../check_in/ui/view_model/check_in_view_model.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [CarePlanHomeScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      floatingActionButton: _buildCheckInFab(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Meu Tratamento',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget? _buildCheckInFab(BuildContext context) {
    // Only show FAB if on the first tab (Treatment/Plans)
    if (_currentIndex != 0) return null;

    return Consumer<CarePlanViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.plans.isEmpty) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () {
            final checkInViewModel = context.read<CheckInViewModel>();
            showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider.value(
                value: checkInViewModel,
                child: CheckInDialog(planId: viewModel.plans.first.id),
              ),
            );
          },
          label: const Text('Check-in Diário'),
          icon: const Icon(Icons.assignment_turned_in),
        );
      },
    );
  }
}
