import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/check_in_view_model.dart';
import 'check_in_dialog.dart';

class DailyCheckInButton extends StatefulWidget {
  final String planId;

  const DailyCheckInButton({super.key, required this.planId});

  @override
  State<DailyCheckInButton> createState() => _DailyCheckInButtonState();
}

class _DailyCheckInButtonState extends State<DailyCheckInButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInViewModel>().checkStatus(widget.planId);
    });
  }

  @override
  void didUpdateWidget(covariant DailyCheckInButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.planId != widget.planId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CheckInViewModel>().checkStatus(widget.planId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && !viewModel.isCheckedInToday) {
          // Loading initial status
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Erro: ${viewModel.errorMessage}'),
            ),
          );
        }

        if (viewModel.isCheckedInToday) {
          return Card(
            color: Colors.green[100],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Tarefa de Hoje Concluída!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          color: Colors.blue[50],
          child: InkWell(
            onTap: viewModel.isLoading
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          CheckInDialog(planId: widget.planId),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  const Text(
                    'Tarefa do Dia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (viewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'MARCAR COMO REALIZADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
