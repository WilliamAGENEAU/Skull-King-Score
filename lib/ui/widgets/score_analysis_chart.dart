import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> allPlayers;
  final List<Map<String, dynamic>> roundsData;

  const ScoreAnalysisChart({
    super.key,
    required this.allPlayers,
    required this.roundsData,
  });

  @override
  Widget build(BuildContext context) {
    if (roundsData.isEmpty || allPlayers.isEmpty) {
      return const Center(
        child: Text(
          "Aucune donnée à afficher",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final List<double> allYValues = [];

    final List<Color> availableColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
    ];

    Color colorForPlayer(String name) {
      final index =
          name.codeUnits.fold(0, (a, b) => a + b) % availableColors.length;
      return availableColors[index];
    }

    final List<LineChartBarData> lineBarsData = [];

    for (final player in allPlayers) {
      final String playerName = player['name'];
      final playerColor = colorForPlayer(playerName);
      final List<FlSpot> spots = [];
      double cumulativeScore = 0;

      for (int i = 0; i < roundsData.length; i++) {
        final round = roundsData[i];
        final scores = Map<String, dynamic>.from(round['scores'] ?? {});
        final score = (scores[playerName] ?? 0).toDouble();
        cumulativeScore += score;
        spots.add(FlSpot((i + 1).toDouble(), cumulativeScore));
        allYValues.add(cumulativeScore);
      }

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: playerColor,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
          barWidth: 3,
        ),
      );
    }

    final minX = 1.0;
    final maxX = roundsData.length.toDouble();

    final double maxY = allYValues.isEmpty
        ? 10.0
        : allYValues.reduce((a, b) => a > b ? a : b) * 1.1;

    final double minY = allYValues.isEmpty
        ? 0.0
        : allYValues.reduce((a, b) => a < b ? a : b) * 1.1;

    double xInterval = (maxX - minX) / 9;
    if (xInterval <= 0) xInterval = 1;

    double yRange = (maxY - minY).abs();
    double yInterval = (yRange / 5).ceilToDouble();
    if (yInterval == 0) yInterval = 10;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: yInterval,
                  verticalInterval: xInterval,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.black26, strokeWidth: 0.6),
                  getDrawingVerticalLine: (_) =>
                      const FlLine(color: Colors.black26, strokeWidth: 0.6),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: lineBarsData,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: allPlayers.map((p) {
            final color = colorForPlayer(p['name']);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 14, height: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  p['name'],
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
