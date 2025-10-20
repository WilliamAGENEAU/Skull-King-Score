// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScoreTable extends StatefulWidget {
  final List<String> players;

  const ScoreTable({super.key, required this.players});

  @override
  State<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<ScoreTable> {
  final ScrollController _verticalControllerLeft = ScrollController();
  final ScrollController _verticalControllerRight = ScrollController();

  @override
  void dispose() {
    _verticalControllerLeft.dispose();
    _verticalControllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double firstColWidth = 40;
    const double playerColWidth = 60; // ✅ Largeur fixe augmentée à 120

    final bool enableHorizontalScroll = widget.players.length > 4;

    // Colonne fixe : "Manche"
    final fixedColumn = Table(
      border: TableBorder.all(color: Colors.black.withOpacity(0.6), width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: FixedColumnWidth(firstColWidth)},
      children: [
        // En-tête vide
        const TableRow(children: [SizedBox(height: 45)]),
        ...List.generate(10, (index) {
          final roundNumber = index + 1;
          return TableRow(
            children: [
              Container(
                alignment: Alignment.center,
                height: 65,
                child: Text(
                  roundNumber.toString(),
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
            ],
          );
        }),
      ],
    );

    // Colonnes scrollables : joueurs
    final playerColumns = Table(
      border: TableBorder.all(color: Colors.black.withOpacity(0.6), width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: _buildColumnWidths(context, playerColWidth, firstColWidth),
      children: [_buildHeaderRow(), ..._buildRoundRows()],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne fixe à gauche
            SizedBox(
              width: firstColWidth,
              child: SingleChildScrollView(
                controller: _verticalControllerLeft,
                scrollDirection: Axis.vertical,
                child: fixedColumn,
              ),
            ),

            // Colonnes des joueurs à droite (scrollables horizontalement)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: enableHorizontalScroll
                    ? Axis.horizontal
                    : Axis.vertical,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notif) {
                    if (notif is ScrollUpdateNotification &&
                        notif.metrics.axis == Axis.vertical) {
                      // Synchronise le scroll vertical
                      _verticalControllerLeft.jumpTo(
                        _verticalControllerRight.offset,
                      );
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _verticalControllerRight,
                    scrollDirection: Axis.vertical,
                    child: playerColumns,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(
    BuildContext context,
    double fixedWidth,
    double firstColWidth,
  ) {
    // ✅ Largeur fixe pour toutes les colonnes joueurs
    return {
      for (int i = 0; i < widget.players.length; i++)
        i: const FixedColumnWidth(120),
    };
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: widget.players.map((p) {
        return Container(
          height: 45,
          width: 120,
          alignment: Alignment.center,
          child: Text(
            p,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TableRow> _buildRoundRows() {
    return List.generate(10, (index) {
      return TableRow(
        children: widget.players.map((_) {
          return Container(
            height: 65,
            alignment: Alignment.center,
            child: const Text(
              '-',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
          );
        }).toList(),
      );
    });
  }
}
