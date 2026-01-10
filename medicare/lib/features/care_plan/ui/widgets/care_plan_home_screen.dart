import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../auth/ui/view_model/auth_view_model.dart';
import '../view_model/care_plan_view_model.dart';
import 'care_plan_form_screen.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../home/ui/widgets/patient_detail_screen.dart';
import '../../../home/ui/view_model/patient_detail_view_model.dart';
import '../../../check_in/ui/widgets/check_in_dialog.dart';
import '../../../check_in/ui/view_model/check_in_view_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

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
        final carePlanViewModel = context
            .read<CarePlanViewModel>(); // Store reference
        carePlanViewModel.fetchPlans(user.id, user.type).then((_) {
          // Load prefreences after plans are fetched
          if (mounted) {
            final notificationService = context.read<NotificationService>();
            carePlanViewModel.loadNotificationPreferences(
              notificationService,
              carePlanViewModel.plans,
            );

            // Check daily check-in status
            if (carePlanViewModel.plans.isNotEmpty && user.type != 'medico') {
              context.read<CheckInViewModel>().checkStatus(
                carePlanViewModel.plans.first.id,
              );
            }

            // Initialize TTS
            context.read<TtsService>().init();
          }
        });
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
      body: Consumer<CarePlanViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                await context.read<CarePlanViewModel>().fetchPlans(
                  user.id,
                  user.type,
                );
                if (context.mounted && !isDoctor) {
                  final plans = context.read<CarePlanViewModel>().plans;
                  if (plans.isNotEmpty) {
                    context.read<CheckInViewModel>().checkStatus(
                      plans.first.id,
                    );
                  }
                }
              }
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  snap: true,
                  floating: true,
                  primary: false,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80.0,
                  expandedHeight: 260.0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: Text(
                    'Planos de Cuidado',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: false,
                  titleSpacing: 24.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              isDoctor
                                  ? 'Gerencie tratamentos, monitore a adesão e acompanhe a evolução dos pacientes.'
                                  : 'Visualize seus planos, controle horários e reporte sua evolução para o médico.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 160,
                              child: SvgPicture.asset(
                                'assets/svg/online_doctor_amico.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isDoctor && viewModel.plans.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: _buildCheckInButton(
                        context,
                        viewModel.plans.first,
                      ),
                    ),
                  ),
                if (viewModel.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (viewModel.errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Erro: ${viewModel.errorMessage}'),
                    ),
                  )
                else if (viewModel.plans.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Nenhum plano encontrado.')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final plan = viewModel.plans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    plan.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isDoctor
                                                  ? Icons.person_outline
                                                  : Icons
                                                        .medical_services_outlined,
                                              size: 16,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isDoctor
                                                  ? '${plan.patientName ?? plan.patientId}'
                                                  : 'Dr. ${plan.doctorName ?? "Não informado"}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(plan.startDate),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (!isDoctor) ...[
                                const Divider(height: 24),
                                Text(
                                  'Status do Dia',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Consumer<CarePlanViewModel>(
                                  builder: (context, vm, _) {
                                    final count =
                                        vm.dailyTaskCounts[plan.id] ?? 0;
                                    final goal = vm.dailyGoals[plan.id] ?? 1;
                                    final isGoalMet = count >= goal;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Concluído: $count / $goal',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        if (isGoalMet)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Meta atingida',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (vm.isPlanExecuting(plan.id))
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        else
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              context
                                                  .read<CarePlanViewModel>()
                                                  .registerExecution(plan);
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              size: 16,
                                            ),
                                            label: const Text('Marcar Feito'),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isDoctor) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 24),
                                      onPressed: () =>
                                          _navigateToForm(plan: plan),
                                      padding: EdgeInsets.zero,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.assignment_ind,
                                        size: 24,
                                      ),
                                      tooltip: 'Ver Evolução',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChangeNotifierProvider(
                                              create: (_) =>
                                                  sl<PatientDetailViewModel>(),
                                              child: PatientDetailScreen(
                                                patient: UserEntity(
                                                  id: plan.patientId,
                                                  name:
                                                      plan.patientName ??
                                                      'Paciente',
                                                  email:
                                                      '', // Not needed for display
                                                  type: 'paciente',
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                    ),
                                  ] else ...[
                                    // Toggle Button for notifications - Interactive
                                    Consumer<CarePlanViewModel>(
                                      builder: (context, vm, _) {
                                        final isEnabled =
                                            vm.notificationStatus[plan.id] ??
                                            true;
                                        return IconButton(
                                          icon: Icon(
                                            isEnabled
                                                ? Icons.notifications_active
                                                : Icons
                                                      .notifications_off_outlined,
                                            color: isEnabled
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Colors.grey,
                                            size: 24,
                                          ),
                                          tooltip: isEnabled
                                              ? 'Desativar lembretes'
                                              : 'Ativar lembretes',
                                          onPressed: () async {
                                            final notificationService = context
                                                .read<NotificationService>();
                                            await vm.toggleNotification(
                                              plan,
                                              notificationService,
                                            );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    vm.notificationStatus[plan
                                                                .id] ==
                                                            true
                                                        ? 'Lembretes ativados para ${plan.title}'
                                                        : 'Lembretes desativados para ${plan.title}',
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                  // TTS Button
                                  ValueListenableBuilder<String?>(
                                    valueListenable: context
                                        .read<TtsService>()
                                        .currentPlayingPlanId,
                                    builder: (context, playingId, _) {
                                      final isPlaying = playingId == plan.id;
                                      return IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.record_voice_over
                                              : Icons.volume_up,
                                          color: isPlaying
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey,
                                          size: 24,
                                        ),
                                        tooltip: 'Ouvir instruções',
                                        onPressed: () {
                                          if (isPlaying) {
                                            context.read<TtsService>().stop();
                                          } else {
                                            final textToRead =
                                                'Remédio: ${plan.title}. Instruções: ${plan.description}';
                                            context.read<TtsService>().speak(
                                              textToRead,
                                              plan.id,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chat, size: 24),
                                    onPressed: () {
                                      debugPrint(
                                        'Other user ID: ${isDoctor ? plan.patientId : plan.doctorId}',
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        '/chat',
                                        arguments: {
                                          'otherUserId': isDoctor
                                              ? plan.patientId
                                              : plan.doctorId,
                                          'otherUserName': isDoctor
                                              ? (plan.patientName ?? 'Paciente')
                                              : (plan.doctorName ?? 'Médico'),
                                        },
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: viewModel.plans.length),
                  ),
              ],
            ),
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

  Widget _buildCheckInButton(BuildContext context, dynamic plan) {
    if (plan == null) return const SizedBox.shrink();

    // Trigger status check if not already checking
    // Ideally we should do this in initState or similar, but doing here for simplicity
    // ensuring we don't spam.
    // A better approach is listening to CarePlanViewModel changes or using a PostFrameCallback
    // For now, let's use the Consumer of CheckInViewModel to drive the UI.

    // We assume the service is already initialized or being called somewhere.
    // Actually, in PatientHomeScreen we removed the manual check.
    // So here we should probably trigger it if we want the button to reflect state.
    // However, build methods shouldn't trigger side effects.
    // Let's rely on CheckInViewModel being updated by something else OR
    // we use a post frame callback in this widget too?
    // Given the refactor, let's trigger it once when this widget is built if needed.
    // But modifying state during build is bad.
    // Let's assume CheckInViewModel is managing its state or we trigger it via a
    // proper lifecycle method if we were in a Stateful widget context for this specific item.
    // Since we are in CarePlanHomeScreenState, let's use a Consumer here.

    // Note: To be safe, we should probably check status in initState of CarePlanHomeScreen if we know the plan?
    // But plans are loaded asynchronously.
    // The previous implementation in PatientHomeScreen triggered it in build via a side effect comment/hack or post frame.
    // Let's just render the button that opens the dialog. The dialog logic handles the actual check-in process.
    // The "Status" (Diário Completo) requires knowledge of whether it was done today.

    return Consumer<CheckInViewModel>(
      builder: (context, checkInViewModel, child) {
        // Optimization: If we haven't checked status yet for this plan, we might show a default state
        // or trigger a check. But CheckInViewModel is global currently? It seems to check for "a plan".

        // Let's simplify:
        // Just show the "Check-in Diário" button.
        // inside the dialog it will handle logic.
        // If we want the nice "Complete" state, we need to ensure checkStatus is called.
        // We can do that by calling checkStatus when the button is pressed (before showing dialog? no, inside logic).

        // Let's keep it simple: A big action button "Fazer Check-in Diário".
        // If already done, the user will be told so in the flow or we can check status on mount.

        if (checkInViewModel.isCheckingStatus) {
          return const Center(child: CircularProgressIndicator());
        }

        if (checkInViewModel.isCheckedInToday) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Diário de hoje completo!",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ChangeNotifierProvider.value(
                  value: checkInViewModel,
                  child: CheckInDialog(planId: plan.id),
                ),
              );
            },
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('Fazer Check-in Diário'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
