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

    // 🎨 Générateur dynamique de couleurs claires uniques pour chaque joueur
    Color colorForPlayer(String name) {
      // On transforme le nom en nombre pour garantir une couleur stable
      final hash = name.codeUnits.fold(0, (a, b) => a + b);

      // Génère des teintes et saturations dans un spectre clair et varié
      final hue = (hash * 37) % 360; // variation de la teinte
      const saturation = 0.45; // ton pastel (0 = gris, 1 = vif)
      const lightness = 0.65; // plus clair que la moyenne

      // Conversion HSL → Color
      return HSLColor.fromAHSL(
        1.0,
        hue.toDouble(),
        saturation,
        lightness,
      ).toColor();
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
          height: 260,
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

                // 🎯 Tooltip coloré et centré
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final playerColor = spot.bar.color ?? Colors.white;

                        return LineTooltipItem(
                          "${spot.y.toStringAsFixed(0)} pts",
                          TextStyle(
                            color: playerColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            const FlLine(color: Colors.black26, strokeWidth: 1),
                            FlDotData(
                              show: true,
                              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                                radius: 5,
                                color: barData.color ?? Colors.black,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                          );
                        }).toList();
                      },
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
