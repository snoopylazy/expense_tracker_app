// import 'dart:math';

import 'package:expense_tracker_app/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker_app/helper/helper_fun.dart';
// import 'package:isar/isar.dart';

class Graph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const Graph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> with SingleTickerProviderStateMixin {
  List<IndividualBar> barData = [];

  late AnimationController _barAnimController;
  double _t = 0.0;

  static const double kGraphMaxY = 250.0; // Fixed max as requested

  @override
  void initState(){
    super.initState();

    _barAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          _t = Curves.easeOutCubic.transform(_barAnimController.value);
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToEnd();
      _barAnimController.forward(from: 0);
    });
  }

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  double calculateMax() {
    // Force graph max to 250 as requested
    return kGraphMaxY;
  }

  final ScrollController _scrollController = ScrollController();
  void scrollToEnd(){
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Graph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthlySummary.length != widget.monthlySummary.length ||
        oldWidget.monthlySummary != widget.monthlySummary) {
      _barAnimController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();
    if (barData.isEmpty) {
      return const Center(child: Text('No data'));
    }
    double barWidth = 20;
    double spaceBetweenBar = 15;

    Widget bottomTitleBuilder(double value, TitleMeta meta) {
      const textstyle = TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      // Align month label with the actual start month
      final index = value.toInt();
      final monthIndex = (widget.startMonth - 1 + index) % 12; // 0-based
      const labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
      final text = labels[monthIndex];
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(text, style: textstyle),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: SizedBox(
        width: (barWidth * barData.length) + (spaceBetweenBar * (barData.length - 1)) + 32,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: calculateMax(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitleBuilder,
                  reservedSize: 24,
                ),
              ),
            ),
            barGroups: barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.x,
                    barRods: [
                      BarChartRodData(
                        toY: (data.y * (_t <= 0 ? 0.001 : _t)).clamp(0, kGraphMaxY),
                        width: barWidth,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue.shade400,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: calculateMax(),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
            alignment: BarChartAlignment.end,
            groupsSpace: spaceBetweenBar,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final value = rod.toY;
                  return BarTooltipItem(
                    formatAmount(value),
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 500),
          swapAnimationCurve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}
