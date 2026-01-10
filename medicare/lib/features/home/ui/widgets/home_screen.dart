import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../check_in/ui/view_model/check_in_view_model.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../care_plan/ui/view_model/care_plan_view_model.dart';
import '../../../profile/ui/view_model/profile_view_model.dart';
import '../view_model/home_view_model.dart';
import 'doctor_home_screen.dart';
import 'patient_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userType;

  const HomeScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<HomeViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<CarePlanViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<CheckInViewModel>()),
        Provider<NotificationService>(create: (_) => sl<NotificationService>()),
      ],
      child: Builder(
        builder: (context) {
          if (userType == 'medico') {
            return const DoctorHomeScreen();
          } else if (userType == 'paciente') {
            return const PatientHomeScreen();
          } else {
            // Fallback for unknown user type
            return const Scaffold(
              body: Center(child: Text('Unknown user type')),
            );
          }
        },
      ),
    );
  }
}
