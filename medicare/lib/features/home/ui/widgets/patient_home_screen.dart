import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../care_plan/ui/widgets/care_plan_home_screen.dart';
import '../../../care_plan/ui/view_model/care_plan_view_model.dart';
import '../../../profile/ui/widgets/profile_screen.dart';

import '../../../../core/services/notification_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [CarePlanHomeScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize Notification Service
      final notificationService = context.read<NotificationService>();
      await notificationService.initialize();
      await notificationService.requestPermissions();

      // Listen to CarePlanViewModel to know when plans are loaded
      final carePlanViewModel = context.read<CarePlanViewModel>();
      carePlanViewModel.addListener(_onCarePlansChanged);
      // Check immediately if already loaded
      if (carePlanViewModel.plans.isNotEmpty) {
        _scheduleNotifications(carePlanViewModel.plans);
      }
    });
  }

  void _onCarePlansChanged() {
    final carePlanViewModel = context.read<CarePlanViewModel>();
    if (carePlanViewModel.plans.isNotEmpty) {
      _scheduleNotifications(carePlanViewModel.plans);
    }
  }

  Future<void> _scheduleNotifications(List<dynamic> plans) async {
    final notificationService = context.read<NotificationService>();
    await notificationService.cancelAll();

    for (final plan in plans) {
      await notificationService.scheduleFromPlan(plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
}
