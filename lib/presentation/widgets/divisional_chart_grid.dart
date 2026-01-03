import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'svg_diamond_chart_widget.dart';

class DivisionalChartGrid extends StatelessWidget {
  final Map<String, dynamic> charts;

  const DivisionalChartGrid({
    super.key,
    required this.charts,
  });

  static const Map<String, String> chartNames = {
    'D1': 'Rashi (Birth Chart)',
    'D2': 'Hora',
    'D3': 'Dreshkana',
    'D4': 'Chaturthamsa',
    'D7': 'Saptamsa',
    'D9': 'Navamsa',
    'D10': 'Dashamsa',
    'D12': 'Dwadashamsa',
    'D16': 'Shodashamsa',
  };

  @override
  Widget build(BuildContext context) {
    final chartEntries = charts.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: chartEntries.length,
      itemBuilder: (context, index) {
        final entry = chartEntries[index];
        final chartKey = entry.key;
        final chartData = entry.value as Map<String, dynamic>? ?? {};

        return _ChartCard(
          chartKey: chartKey,
          chartName: chartNames[chartKey] ?? chartKey,
          chartData: chartData,
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String chartKey;
  final String chartName;
  final Map<String, dynamic> chartData;

  const _ChartCard({
    required this.chartKey,
    required this.chartName,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final planets = chartData['planets'] as Map<String, dynamic>? ?? {};
    final houses = chartData['houses'] as Map<String, dynamic>? ?? {};
    final ascendant = (chartData['ascendant'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chartKey,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SVGDiamondChartWidget(
                planets: planets,
                houses: houses,
                ascendant: ascendant,
                showLabels: false,
                size: 150,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              chartName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

