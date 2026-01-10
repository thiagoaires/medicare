import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../../care_plan/ui/widgets/care_plan_home_screen.dart';
import '../../../profile/ui/widgets/profile_screen.dart';
import 'doctor_dashboard_widget.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final List<Widget> _pages = const [
    DoctorDashboardWidget(),
    CarePlanHomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final currentIndex = viewModel.currentIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          viewModel.setIndex(index);
        },
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Planos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
