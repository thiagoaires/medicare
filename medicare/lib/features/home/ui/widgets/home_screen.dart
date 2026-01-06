import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../injection_container.dart';
import '../../../care_plan/ui/widgets/care_plan_home_screen.dart';
import '../../../care_plan/ui/view_model/care_plan_view_model.dart';
import '../../../profile/ui/view_model/profile_view_model.dart';
import '../../../profile/ui/widgets/profile_screen.dart';
import '../view_model/home_view_model.dart';
import 'doctor_dashboard_widget.dart';

class HomeScreen extends StatelessWidget {
  final String userType;

  const HomeScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<HomeViewModel>(),
      child: Scaffold(
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            final isDoctor = userType == 'medico';

            // Define tabs based on user type
            final List<Widget> pages = isDoctor
                ? [
                    const DoctorDashboardWidget(),
                    ChangeNotifierProvider(
                      create: (_) => sl<CarePlanViewModel>(),
                      child: const CarePlanHomeScreen(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => sl<ProfileViewModel>(),
                      child: const ProfileScreen(),
                    ),
                  ]
                : [
                    ChangeNotifierProvider(
                      create: (_) => sl<CarePlanViewModel>(),
                      child: const CarePlanHomeScreen(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => sl<ProfileViewModel>(),
                      child: const ProfileScreen(),
                    ),
                  ];

            return IndexedStack(index: viewModel.currentIndex, children: pages);
          },
        ),
        bottomNavigationBar: Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            final isDoctor = userType == 'medico';

            return BottomNavigationBar(
              currentIndex: viewModel.currentIndex,
              onTap: (index) => viewModel.setIndex(index),
              items: isDoctor
                  ? const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'Planos',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Perfil',
                      ),
                    ]
                  : const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.medical_services),
                        label: 'Meu Tratamento',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Perfil',
                      ),
                    ],
            );
          },
        ),
      ),
    );
  }
}
