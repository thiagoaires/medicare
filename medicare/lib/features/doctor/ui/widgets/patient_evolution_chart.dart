import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../check_in/domain/entities/check_in_entity.dart';

class PatientEvolutionChart extends StatelessWidget {
  final List<CheckInEntity> checkIns;

  const PatientEvolutionChart({super.key, required this.checkIns});

  @override
  Widget build(BuildContext context) {
    if (checkIns.length < 2) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Dados insuficientes para gráfico',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort by date (Ascending: Old -> New)
    final sortedCheckIns = List<CheckInEntity>.from(checkIns)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Convert to spots (X: index, Y: feeling)
    // Filter out items without feeling or invalid feeling
    final validPoints = sortedCheckIns.where((c) => c.feeling != null).toList();

    if (validPoints.length < 2) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Dados de humor insuficientes para gráfico',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final spots = validPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final checkIn = entry.value;
      return FlSpot(index.toDouble(), checkIn.feeling!.toDouble());
    }).toList();

    final primaryColor = Theme.of(context).colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18.0,
          left: 12.0,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 0.5,
                  dashArray: [5, 5],
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 0.5,
                  dashArray: [5, 5],
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < validPoints.length) {
                      // Logic to prevent label overlap:
                      // If list is small (< 7), show all.
                      // Else show first, last, and middle points.
                      bool showLabel = false;
                      int total = validPoints.length;

                      if (total < 7) {
                        showLabel = true;
                      } else {
                        // Show every (total/5)th item roughly
                        int interval = (total / 5).ceil();
                        if (index % interval == 0) showLabel = true;
                      }

                      if (showLabel) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM').format(validPoints[index].date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    // Only integer values 1-5
                    if (value % 1 == 0 && value >= 1 && value <= 5) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.left,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 28,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            minY: 1,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.3),
                      primaryColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
