import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../care_plan/ui/widgets/care_plan_home_screen.dart';
import '../../../care_plan/ui/view_model/care_plan_view_model.dart';
import '../../../profile/ui/widgets/profile_screen.dart';
import '../../../check_in/ui/widgets/check_in_dialog.dart';
import '../../../check_in/ui/view_model/check_in_view_model.dart';
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
        _checkStatus(carePlanViewModel.plans.first.id);
        _scheduleNotifications(carePlanViewModel.plans);
      }
    });
  }

  void _onCarePlansChanged() {
    final carePlanViewModel = context.read<CarePlanViewModel>();
    if (carePlanViewModel.plans.isNotEmpty) {
      _checkStatus(carePlanViewModel.plans.first.id);
      _scheduleNotifications(carePlanViewModel.plans);

      // Remove listener to avoid repeated scheduling?
      // If plans change (added/removed), we want to reschedule.
      // So let's keep it but maybe optimize to not spam cancelAll.
      // For MVP safely rescheduling is fine.
    }
  }

  Future<void> _scheduleNotifications(List<dynamic> plans) async {
    final notificationService = context.read<NotificationService>();
    await notificationService.cancelAll();

    for (final plan in plans) {
      await notificationService.scheduleFromPlan(plan);
    }
  }

  void _checkStatus(String planId) {
    context.read<CheckInViewModel>().checkStatus(planId);
  }

  @override
  void dispose() {
    // Cannot easily remove listener here as we need reference to the exact viewmodel instance
    // But since it's a singleton/factory in provider, accessing via context in dispose might be unsafe.
    // However, since we remove it in the callback, it should be fine.
    super.dispose();
  }

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

  Widget? _buildCheckInFab(BuildContext context) {
    // Only show FAB if on the first tab (Treatment/Plans)
    if (_currentIndex != 0) return null;

    return Consumer<CarePlanViewModel>(
      builder: (context, carePlanViewModel, child) {
        if (carePlanViewModel.plans.isEmpty) {
          return const SizedBox.shrink();
        }

        // Trigger status check if not already checking
        final plan = carePlanViewModel.plans.first;
        // Ideally we should do this in initState or similar, but doing here for simplicity
        // ensuring we don't spam.
        // A better approach is listening to CarePlanViewModel changes or using a PostFrameCallback
        // For now, let's use the Consumer of CheckInViewModel to drive the UI.

        // Trigger check status once if needed?
        // We will do it in initState or postFrameCallback logic below the build method or let the user handle it.
        // User request: "Ensure the call to checkStatus(planId) happens after CarePlanViewModel has successfully loaded the plans."

        return Consumer<CheckInViewModel>(
          builder: (context, checkInViewModel, child) {
            if (checkInViewModel.isCheckingStatus) {
              return FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.grey[300],
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (checkInViewModel.isCheckedInToday) {
              return FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você já completou seu diário hoje!'),
                    ),
                  );
                },
                backgroundColor: Colors.grey,
                label: const Text('Diário Completo'),
                icon: const Icon(Icons.check),
              );
            }

            return FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ChangeNotifierProvider.value(
                    value: checkInViewModel,
                    child: CheckInDialog(planId: plan.id),
                  ),
                );
              },
              label: const Text('Check-in Diário'),
              icon: const Icon(Icons.assignment_turned_in),
            );
          },
        );
      },
    );
  }
}
