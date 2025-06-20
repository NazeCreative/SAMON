import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedTab = 0;
  final tabs = ['Tuần', 'Tháng', 'Quý', 'Năm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                isSelected: List.generate(tabs.length, (index) => index == selectedTab),
                onPressed: (index) {
                  setState(() => selectedTab = index);
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.black,
                color: Colors.white,
                fillColor: Colors.grey[300],
                children: tabs.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(e),
                )).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Sun', 'Sat', 'Fri', 'Thu', 'Wed', 'Tue', 'Mon'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(days[value.toInt() % 7],
                                  style: const TextStyle(color: Colors.white)),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: _buildBarGroups(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GIAO DỊCH', style: TextStyle(color: Colors.white, fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Chi tiết'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              _buildTransactionItem('Ăn uống', '- 28.000', '01/06/25', Icons.restaurant, Colors.yellow),
              _buildTransactionItem('Sức khỏe', '- 30.000', '31/05/25', Icons.favorite, Colors.green),
              _buildTransactionItem('Tiền', '+ 100.000', '', Icons.trending_up, Colors.lightGreenAccent),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final data = [
      [100.0, 20.0],
      [90.0, 150.0],
      [120.0, 100.0],
      [100.0, 60.0],
      [160.0, 100.0],
      [70.0, 90.0],
      [200.0, 0.0],
    ];
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: data[i][0], width: 8, color: Colors.green),
          BarChartRodData(toY: data[i][1], width: 8, color: Colors.red),
        ],
      );
    });
  }

  Widget _buildTransactionItem(String title, String amount, String date, IconData icon, Color color) {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('+') ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
