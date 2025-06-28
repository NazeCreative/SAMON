import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarChartPage extends StatefulWidget {
  const MyBarChartPage({super.key});

  @override
  _MyBarChartPageState createState() => _MyBarChartPageState();
}

class _MyBarChartPageState extends State<MyBarChartPage> {
  int _selectedTab = 0; // 0: Tuần, 1: Tháng, 2: Quý, 3: Năm

  final List<String> tabs = ['Tuần', 'Tháng', 'Quý', 'Năm'];

  //phông bạt dữ liệu
  List<List<double>> incomeData = [
    [100000, 150000, 120000, 90000, 160000, 70000, 200000],
    [1300000, 1500000, 2000000, 1400000, 1800000, 1600000],
    [0, 9000000, 9500000, 10000000],
    [5000000, 40000000],
  ];

  List<List<double>> expenseData = [
    [20000, 100000, 90000, 60000, 120000, 50000, 90000],
    [1100000, 1300000, 1700000, 1500000, 1600000, 1400000],
    [0, 8000000, 9500000, 6000000],
    [4000000, 45000000],
  ];

  List<List<String>> labels = [
    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    ['24/01', '24/02', '24/03', '24/04', '24/05', '24/06'],
    ['Quý III/24', 'Quý IV/24', 'Quý I/25', 'Quý II/25'],
    ['2024', '2025'],
  ];

  //phông bạt giao dịch
  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Ăn uống",
      "amount": 50000,
      "date": "18/06/2025",
      "type": "expense", // Tiền ra
    },
    {
      "title": "Lương",
      "amount": 500000,
      "date": "15/06/2025",
      "type": "income", // Tiền vào
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Thống kê', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ToggleButtons(
              isSelected: List.generate(tabs.length, (index) => index == _selectedTab),
              onPressed: (index) => setState(() => _selectedTab = index),
              color: Colors.white, // màu chữ tab chưa chọn
              selectedColor: Color(0xff000000), // màu chữ tab đang chọn
              borderColor: Colors.white, // viền nút
              selectedBorderColor: Color(0xffffffff), // viền khi selected
              fillColor: Color(0xff978fad), // bỏ nền màu khi selected
              borderRadius: BorderRadius.circular(8),
              children: List.generate(tabs.length, (index) {
                final isSelected = index == _selectedTab;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    ),
                    child: Text(tabs[index]),
                  ),
                );
              }),
            ),
            AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value >= 1000000
                                  ? '${(value ~/ 1000000)}TR'
                                  : value >= 1000
                                  ? '${(value ~/ 1000)}K'
                                  : '${value.toInt()}',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < labels[_selectedTab].length) {
                              return Text(labels[_selectedTab][idx], style: const TextStyle(fontSize: 10, color: Colors.white));
                            } else {
                              return const Text('');
                            }
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(labels[_selectedTab].length, (i) {
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: incomeData[_selectedTab][i], color: Colors.green, width: 10),
                        BarChartRodData(toY: expenseData[_selectedTab][i], color: Colors.red, width: 10),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GIAO DỊCH', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xff978fad),),
                    onPressed: () {},
                    child: const Text('> Chi tiết', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            ...transactions.map(
                  (tx) => Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx['type'] == 'income' ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      Icons.attach_money,
                      color: tx['type'] == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(tx['title']),
                  subtitle: Text(tx['date']),
                  trailing: Text(
                    '${tx['type'] == 'income' ? '+' : '-'}${tx['amount']}₫',
                    style: TextStyle(
                      color: tx['type'] == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}