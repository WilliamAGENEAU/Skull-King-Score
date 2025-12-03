// current_game_chart.dart
// ignore_for_file: unintended_html_in_doc_comment

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CurrentGameChart extends StatelessWidget {
  /// allScores: Map<roundNumber, Map<playerName, dynamic>>
  /// each player entry can be:
  ///  - an int (points of the round)
  ///  - a Map<String, dynamic> containing 'total' or 'score' or 'points'
  final Map<int, Map<String, dynamic>> allScores;
  final List<String> players;
  final int currentRound; // current round index (1..10)

  const CurrentGameChart({
    super.key,
    required this.allScores,
    required this.players,
    required this.currentRound,
  });

  @override
  Widget build(BuildContext context) {
    // If nothing yet
    if (players.isEmpty || allScores.isEmpty) {
      return const Center(
        child: Text(
          "Aucune donnée disponible",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    // Colors generator stable by name
    Color colorForPlayer(String name) {
      final hash = name.codeUnits.fold(0, (a, b) => a + b);
      final hue = (hash * 37) % 360;
      return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.45, 0.65).toColor();
    }

    // --- Build ordered list of rounds we will display ---
    final roundsKeys = allScores.keys.toList()..sort();
    // Only take rounds <= currentRound (defensive)
    final roundsToUse = roundsKeys
        .where((r) => r <= currentRound)
        .toList(growable: false);

    // If no rounds yet (shouldn't happen because allScores.isNotEmpty), fallback:
    if (roundsToUse.isEmpty) {
      return const Center(child: Text("Pas de manches jouées"));
    }

    // For each player build cumulative series starting at x=0 -> y=0
    final List<LineChartBarData> lineBars = [];
    final List<double> allY = [];

    for (final player in players) {
      double cumulative = 0.0;
      final List<FlSpot> spots = [];

      // start at 0,0
      spots.add(const FlSpot(0, 0));
      allY.add(0);

      for (int idx = 0; idx < roundsToUse.length; idx++) {
        final roundNum = roundsToUse[idx];
        final roundMap = allScores[roundNum] ?? {};

        // extract value for this player in this round (robust)
        double roundValue = 0.0;
        if (roundMap.containsKey(player)) {
          final v = roundMap[player];
          if (v is num) {
            roundValue = v.toDouble();
          } else if (v is Map) {
            // prefer 'total' then 'score' then 'points'
            final cand = v['total'] ?? v['score'] ?? v['points'] ?? 0;
            if (cand is num) roundValue = cand.toDouble();
          } else {
            roundValue = 0.0;
          }
        } else {
          roundValue = 0.0;
        }

        // cumulative total after this round
        cumulative += roundValue;
        // x is roundNum (keeps original round numbers)
        spots.add(FlSpot(roundNum.toDouble(), cumulative));
        allY.add(cumulative);
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colorForPlayer(player),
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
          barWidth: 3,
        ),
      );
    }

    // X axis: 0..10 as requested
    const double minX = 0.0;
    const double maxX = 10.0;

    // Y axis auto
    final double maxY = allY.isEmpty
        ? 10.0
        : allY.reduce((a, b) => a > b ? a : b);
    final double minY = allY.isEmpty
        ? -10.0
        : allY.reduce((a, b) => a < b ? a : b);

    // Pad ranges a bit
    final double paddedMaxY = (maxY == 0) ? 10 : (maxY * 1.15).ceilToDouble();
    final double paddedMinY = (minY == 0) ? -10 : (minY * 1.15).floorToDouble();

    double yRange = (paddedMaxY - paddedMinY).abs();
    double yInterval = (yRange <= 0) ? 10 : (yRange / 5);
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
                minY: paddedMinY,
                maxY: paddedMaxY,
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
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.black26, strokeWidth: 0.6),
                  getDrawingVerticalLine: (_) =>
                      const FlLine(color: Colors.black26, strokeWidth: 0.6),
                ),
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
                        final playerColor = spot.bar.color ?? Colors.black;
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
                lineBarsData: lineBars,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: players.map((p) {
            final color = colorForPlayer(p);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 14, height: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  p,
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
