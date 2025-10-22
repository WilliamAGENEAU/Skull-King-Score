// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skull_king/ui/widgets/score_cell.dart';

class ScoreTable extends StatelessWidget {
  final List<String> players;
  final int currentRound;
  final Map<int, Map<String, Map<String, dynamic>>> allScores;

  const ScoreTable({
    super.key,
    required this.players,
    required this.currentRound,
    required this.allScores,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double firstColWidth = 30;
        const double fixedPlayerColWidth = 90;

        final bool enableHorizontalScroll = players.length > 3;

        final Map<int, TableColumnWidth> columnWidths = _buildColumnWidths(
          constraints.maxWidth,
          firstColWidth,
          fixedPlayerColWidth,
        );

        final table = Table(
          border: TableBorder.all(
            color: Colors.black.withOpacity(0.6),
            width: 1,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [_buildHeaderRow(), ..._buildRoundRows()],
        );

        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: enableHorizontalScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: table,
                    )
                  : table,
            ),
          ),
        );
      },
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(
    double totalWidth,
    double firstColWidth,
    double fixedPlayerColWidth,
  ) {
    final Map<int, TableColumnWidth> widths = {
      0: FixedColumnWidth(firstColWidth),
    };

    if (players.length <= 4) {
      final double remainingWidth = totalWidth - firstColWidth;
      final double dynamicWidth = remainingWidth / players.length;

      for (int i = 0; i < players.length; i++) {
        widths[i + 1] = FixedColumnWidth(dynamicWidth);
      }
    } else {
      for (int i = 0; i < players.length; i++) {
        widths[i + 1] = FixedColumnWidth(fixedPlayerColWidth);
      }
    }
    return widths;
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        const SizedBox(),
        ...players.map(
          (p) => Padding(
            padding: const EdgeInsets.all(6),
            child: Center(
              child: Text(
                p,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildRoundRows() {
    return List.generate(10, (index) {
      final roundNumber = index + 1;
      final bool isCurrentRound = roundNumber == currentRound;
      final roundData = allScores[roundNumber];

      return TableRow(
        decoration: BoxDecoration(
          color: isCurrentRound
              ? const Color(0xFF8B4513).withOpacity(0.2)
              : Colors.transparent,
        ),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                roundNumber.toString(),
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          ),
          ...players.map((player) {
            final data = roundData?[player];
            return ScoreCell(
              mise: data?['mise'],
              plis: data?['plis'],
              points: data?['points'],
              bonus: data?['bonus'],
              total: data?['total'],
              cumul: _calculateCumulativeScore(player, roundNumber),
              isPastRound:
                  roundNumber <
                  currentRound, // ✅ cumul seulement manches passées
            );
          }),
        ],
      );
    });
  }

  int _calculateCumulativeScore(String player, int roundNumber) {
    int cumul = 0;
    for (int i = 1; i <= roundNumber; i++) {
      final total = allScores[i]?[player]?['total'];
      if (total != null) cumul += total as int;
    }
    return cumul;
  }
}
