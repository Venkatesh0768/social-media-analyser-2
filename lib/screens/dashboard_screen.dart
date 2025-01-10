import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import 'dart:math' as math;

import 'package:social_media/screens/chat_scrren.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<List<dynamic>> _data = [];
  bool _isLoading = false;
  String _fileName = '';
  Map<String, double> _pieChartData = {};
  List<Map<String, dynamic>> _lineChartData = [];

  @override
  void initState() {
    super.initState();
    _loadCSVFromAssets();
  }

  Future<void> _loadCSVFromAssets() async {
    try {
      setState(() {
        _isLoading = true;
        _data = [];
        _pieChartData = {};
        _lineChartData = [];
      });
      
      final csvData = await rootBundle.loadString('assets/social_media_data.csv');
      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      final listData = const CsvToListConverter().convert(csvData);
      if (listData.isEmpty) {
        throw Exception('No data found in CSV');
      }

      // Process data for charts
      _processDataForCharts(listData);

      setState(() {
        _data = listData;
        _fileName = 'social_media_data.csv';
      });
    } catch (e) {
      print('Error loading CSV: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading CSV file: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processDataForCharts(List<List<dynamic>> data) {
    if (data.isEmpty) return;

    try {
      final limitedData = data.length > 21 
          ? [data[0], ...data.sublist(1, 21)] 
          : data;

      // Process bar and line chart data
      _lineChartData = limitedData.skip(1).map((row) {
        try {
          return {
            'x': row[0]?.toString() ?? 'Unknown',
            'likes': double.tryParse(row[2]?.toString() ?? '') ?? 0.0,
            'shares': double.tryParse(row[3]?.toString() ?? '') ?? 0.0,
            'comments': double.tryParse(row[4]?.toString() ?? '') ?? 0.0,
            'views': double.tryParse(row[5]?.toString() ?? '') ?? 0.0,
            'saves': double.tryParse(row[6]?.toString() ?? '') ?? 0.0,
          };
        } catch (e) {
          print('Error parsing row: $e');
          return {
            'x': 'Error',
            'likes': 0.0,
            'shares': 0.0,
            'comments': 0.0,
            'views': 0.0,
            'saves': 0.0,
          };
        }
      }).toList();

      // Calculate totals for pie chart
      Map<String, double> totals = {
        'Likes': 0.0,
        'Shares': 0.0,
        'Comments': 0.0,
        'Views': 0.0,
        'Saves': 0.0,
      };

      for (var item in _lineChartData) {
        totals['Likes'] = (totals['Likes'] ?? 0) + (item['likes'] as double);
        totals['Shares'] = (totals['Shares'] ?? 0) + (item['shares'] as double);
        totals['Comments'] = (totals['Comments'] ?? 0) + (item['comments'] as double);
        totals['Views'] = (totals['Views'] ?? 0) + (item['views'] as double);
        totals['Saves'] = (totals['Saves'] ?? 0) + (item['saves'] as double);
      }

      double total = totals.values.reduce((a, b) => a + b);
      _pieChartData = Map.fromEntries(
        totals.entries.map((e) => MapEntry(e.key, (e.value / total) * 100)),
      );

      _data = limitedData;
    } catch (e) {
      print('Error processing chart data: $e');
      _pieChartData = {};
      _lineChartData = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        },
        child: const Icon(Icons.chat),

      ),
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCSVFromAssets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis for data',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildChartSection(),
          const SizedBox(height: 24),
          _buildPieChart(),
          const SizedBox(height: 24),
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalRecords = _data.length - 1;
    int categories = _pieChartData.length;
    double averagePerCategory = totalRecords / (categories > 0 ? categories : 1);

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Records',
          totalRecords.toString(),
          Icons.analytics,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Categories',
          categories.toString(),
          Icons.category,
          Colors.purple,
        ),
        _buildSummaryCard(
          'Avg per Category',
          averagePerCategory.toStringAsFixed(1),
          Icons.show_chart,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      children: [
        _buildLineChart(),
        const SizedBox(height: 16),
        _buildBarChart(),
      ],
    );
  }

  Widget _buildLineChart() {
    if (_lineChartData.isEmpty) {
      return const Card(
        child: Center(child: Text('No data available for line chart')),
      );
    }

    final metrics = ['likes', 'shares', 'comments', 'views', 'saves'];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metrics Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                metrics.length,
                (i) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: colors[i],
                      ),
                      const SizedBox(width: 4),
                      Text(metrics[i].toUpperCase()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _lineChartData.length) {
                            return Rotate(
                              angle: 45,
                              child: Text(
                                _lineChartData[value.toInt()]['x'].toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: List.generate(
                    metrics.length,
                    (i) => LineChartBarData(
                      spots: _lineChartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value[metrics[i]].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: colors[i],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_pieChartData.isEmpty) {
      return const Card(
        child: Center(
          child: Text('No data available for pie chart'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Distribution (%)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _pieChartData.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_lineChartData.isEmpty) {
      return const Card(
        child: Center(child: Text('No data available for bar chart')),
      );
    }

    final metrics = ['likes', 'shares', 'comments', 'views', 'saves'];
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Engagement Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: metrics.map((metric) => 
                    _lineChartData.map((data) => data[metric] as double)
                      .reduce((a, b) => a > b ? a : b)
                  ).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final metric = metrics[rodIndex];
                        final value = _lineChartData[groupIndex][metric];
                        return BarTooltipItem(
                          '${metric.toUpperCase()}\n${value.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _lineChartData.length) {
                            return Rotate(
                              angle: 45,
                              child: Text(
                                _lineChartData[value.toInt()]['x'].toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  barGroups: _lineChartData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: metrics.asMap().entries.map((metric) {
                        return BarChartRodData(
                          toY: entry.value[metric.value].toDouble(),
                          color: colors[metric.key],
                          width: 16 / metrics.length,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: metrics.asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[entry.key],
                    ),
                    const SizedBox(width: 4),
                    Text(entry.value.toUpperCase()),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    try {
      return Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: (_data.isNotEmpty ? _data[0] : []).map<DataColumn>((header) {
              return DataColumn(
                label: Text(
                  header?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            rows: _data.length > 1 
                ? _data.sublist(1).map<DataRow>((row) {
                    return DataRow(
                      cells: row.map<DataCell>((cell) {
                        return DataCell(Text(cell?.toString() ?? ''));
                      }).toList(),
                    );
                  }).toList()
                : [],
          ),
        ),
      );
    } catch (e) {
      print('Error building data table: $e');
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Error displaying data'),
          ),
        ),
      );
    }
  }
}

class Rotate extends StatelessWidget {
  final double angle;
  final Widget child;

  const Rotate({
    Key? key,
    required this.angle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * 3.14159 / 180,
      child: child,
    );
  }
}








