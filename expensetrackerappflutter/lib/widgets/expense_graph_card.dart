import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entities/expense.dart';
import '../widgets/expense_filter.dart';

class ExpenseGraphCard extends StatelessWidget {
  final List<Expense> filteredExpenses;
  final String currency;
  final ExpenseFilter activeFilter;

  const ExpenseGraphCard({
    super.key,
    required this.filteredExpenses,
    required this.currency,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredExpenses.isEmpty) {
      return Container(
        height: 160,
        decoration: _cardDecoration(),
        child: const Center(
          child: Text("Not record found to generate graph",
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    Map<String, double> dailySpends = {};

    for (var e in filteredExpenses) {
      final date = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      final key = '${date.year}-${date.month}-${date.day}';
      dailySpends[key] = (dailySpends[key] ?? 0) + e.amount;
    }

    final sortedDates = dailySpends.keys.map((k) {
      final parts = k.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()..sort();

    List<FlSpot> spots = [];
    double rawMaxY = 0;

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final key = '${date.year}-${date.month}-${date.day}';
      final amount = dailySpends[key] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), amount));
      if (amount > rawMaxY) rawMaxY = amount;
    }

    if (spots.length == 1) {
      spots.insert(0, FlSpot(-1, 0));
    }

    if (rawMaxY == 0) rawMaxY = 100;

    final interval = _calculateYInterval(rawMaxY);
    final maxY = ((rawMaxY / interval).ceil() + 1) * interval;

    final totalPoints = sortedDates.length - 1;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        height: 140,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Colors.purple.shade900.withOpacity(0.8),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    return LineTooltipItem(
                      '$currency${barSpot.y.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            minY: 0,
            maxY: maxY.toDouble(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: _calculateXInterval(totalPoints),
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= sortedDates.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        DateFormat('d MMM').format(sortedDates[idx]),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 55,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    if (value == maxY) return const SizedBox.shrink();
                    return Text(
                      '$currency${value.toInt()}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.purple.shade900,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: Colors.purple.shade900,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade900.withOpacity(0.25),
                      Colors.purple.shade900.withOpacity(0.0),
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

  double _calculateYInterval(double rawMaxY) {
    if (rawMaxY <= 100) return 50;
    if (rawMaxY <= 500) return 100;
    if (rawMaxY <= 1000) return 200;
    if (rawMaxY <= 5000) return 500;
    return 1000;
  }

  double _calculateXInterval(int totalPoints) {
    if (totalPoints <= 0) return 1;
    if (totalPoints <= 7) return 1;
    if (totalPoints <= 31) return 5;
    return (totalPoints / 5).ceilToDouble();
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
      border: Border.all(width: 0.3, color: Colors.grey.shade500),
    );
  }
}