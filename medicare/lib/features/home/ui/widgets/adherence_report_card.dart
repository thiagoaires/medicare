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
                  'Adesão ao Tratamento (7 dias)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                // final goal = goals[plan.id] ?? 0; // Optional to show goal
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '$count doses registradas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
