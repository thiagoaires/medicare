import 'package:flutter/material.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';

class AdherenceReportCard extends StatelessWidget {
  final double overallAdherence;
  final List<CarePlanEntity> plans;
  final Map<String, int> counts;
  final Map<String, int> goals;

  const AdherenceReportCard({
    super.key,
    required this.overallAdherence,
    required this.plans,
    required this.counts,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final adherencePercent = overallAdherence / 100;
    Color statusColor;
    if (overallAdherence >= 80) {
      statusColor = Colors.green;
    } else if (overallAdherence >= 50) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Adesão Acumulada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Overall Summary (Optional or keep as header)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: adherencePercent,
                      backgroundColor: Colors.grey[200],
                      color: statusColor,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${overallAdherence.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (plans.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...plans.map((plan) {
                final count = counts[plan.id] ?? 0;
                final goal = goals[plan.id] ?? 0;
                double planPercent = 0.0;
                if (goal > 0) {
                  planPercent = count / goal;
                  if (planPercent > 1.0) planPercent = 1.0;
                }

                Color planColor;
                if (planPercent >= 0.8) {
                  planColor = Colors.green;
                } else if (planPercent >= 0.5) {
                  planColor = Colors.orange;
                } else {
                  planColor = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (plan.endDate != null &&
                                    plan.endDate!.isBefore(DateTime.now()))
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Concluído em ${plan.endDate!.day}/${plan.endDate!.month}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${(planPercent * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: planColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: planPercent,
                          backgroundColor: Colors.grey[200],
                          color: planColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tomou $count de $goal esperados desde o início',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Nenhum plano ativo.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
