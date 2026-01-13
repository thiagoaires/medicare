import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../doctor/ui/widgets/patient_evolution_chart.dart';
import '../view_model/patient_detail_view_model.dart';
import 'adherence_report_card.dart';

class PatientDetailScreen extends StatefulWidget {
  final UserEntity patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientDetailViewModel>().fetchHistory(widget.patient.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.patient.username)),
      body: Consumer<PatientDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('Erro: ${viewModel.errorMessage}'));
          }

          if (viewModel.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum histórico disponível para este paciente',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              AdherenceReportCard(
                overallAdherence: viewModel.overallAdherence,
                plans: viewModel.patientPlans,
                counts: viewModel.adherenceCounts,
                goals: viewModel.adherenceGoals,
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evolução da Dor/Humor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      PatientEvolutionChart(checkIns: viewModel.history),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final checkIn = viewModel.history[index];
                    final dateFormatted = DateFormat(
                      'dd/MM/yyyy - HH:mm',
                    ).format(checkIn.date);

                    return ListTile(
                      leading: Text(
                        _getFeelingEmoji(checkIn.feeling),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        dateFormatted,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          checkIn.notes != null && checkIn.notes!.isNotEmpty
                          ? Text(checkIn.notes!)
                          : null,
                      trailing: checkIn.photoUrl != null
                          ? IconButton(
                              icon: const Icon(Icons.image, color: Colors.blue),
                              onPressed: () =>
                                  _showImageDialog(context, checkIn.photoUrl!),
                            )
                          : null,
                      onTap: checkIn.photoUrl != null
                          ? () => _showImageDialog(context, checkIn.photoUrl!)
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getFeelingEmoji(int? feeling) {
    if (feeling == null) return '✔️';
    switch (feeling) {
      case 1:
        return '😫';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😃';
      default:
        return '✔️';
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
