// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'score_cell.dart';

class ScoreTable extends StatefulWidget {
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
  State<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<ScoreTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateCumulativeScore(String player, int roundNumber) {
    int cumul = 0;
    for (int i = 1; i <= roundNumber; i++) {
      final total = widget.allScores[i]?[player]?['total'];
      if (total != null) cumul += total as int;
    }
    return cumul;
  }

  List<String> _getLeaders() {
    Map<String, int> totals = {
      for (var p in widget.players) p: _calculateCumulativeScore(p, 10),
    };
    if (totals.values.every((v) => v == 0)) return [];
    final maxScore = totals.values.reduce((a, b) => a > b ? a : b);
    return totals.entries
        .where((e) => e.value == maxScore)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final leaders = _getLeaders();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double firstColWidth = 30;
        const double fixedPlayerColWidth = 90;
        final bool enableHorizontalScroll = widget.players.length > 3;

        final columnWidths = _buildColumnWidths(
          constraints.maxWidth,
          firstColWidth,
          fixedPlayerColWidth,
        );

        final table = Table(
          border: TableBorder.all(
            color: Colors.black.withOpacity(0.3),
            width: 0.6,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [_buildHeaderRow(leaders), ..._buildRoundRows(leaders)],
        );

        return ClipRRect(
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
        );
      },
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(
    double totalWidth,
    double firstColWidth,
    double fixedPlayerColWidth,
  ) {
    final widths = <int, TableColumnWidth>{0: FixedColumnWidth(firstColWidth)};
    if (widget.players.length <= 4) {
      final remainingWidth = totalWidth - firstColWidth;
      final dynamicWidth = remainingWidth / widget.players.length;
      for (int i = 0; i < widget.players.length; i++) {
        widths[i + 1] = FixedColumnWidth(dynamicWidth);
      }
    } else {
      for (int i = 0; i < widget.players.length; i++) {
        widths[i + 1] = FixedColumnWidth(fixedPlayerColWidth);
      }
    }
    return widths;
  }

  TableRow _buildHeaderRow(List<String> leaders) {
    return TableRow(
      children: [
        const SizedBox(),
        ...widget.players.map(
          (p) => AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: leaders.contains(p)
                ? Colors.amber.withOpacity(0.25)
                : Colors.transparent,
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
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
                  if (leaders.contains(p))
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: 1 + 0.1 * _glowAnimation.value,
                          child: SvgPicture.asset(
                            'assets/svg/crown.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildRoundRows(List<String> leaders) {
    return List.generate(10, (index) {
      final roundNumber = index + 1;
      final bool isCurrentRound = roundNumber == widget.currentRound;
      final bool isEven = roundNumber.isEven;
      final roundData = widget.allScores[roundNumber];

      return TableRow(
        decoration: BoxDecoration(
          color: isCurrentRound
              ? const Color(0xFF8B4513).withOpacity(0.15)
              : isEven
              ? Colors.black.withOpacity(0.03)
              : Colors.transparent,
        ),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                roundNumber.toString(),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          ...widget.players.map((player) {
            final data = roundData?[player];
            final isLeader = leaders.contains(player);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              color: isLeader && roundNumber < widget.currentRound
                  ? Colors.amber.withOpacity(0.15)
                  : Colors.transparent,
              child: ScoreCell(
                mise: data?['mise'],
                plis: data?['plis'],
                points: data?['points'],
                bonus: data?['bonus'],
                total: data?['total'],
                cumul: _calculateCumulativeScore(player, roundNumber),
                isPastRound: roundNumber < widget.currentRound,
              ),
            );
          }),
        ],
      );
    });
  }
}
