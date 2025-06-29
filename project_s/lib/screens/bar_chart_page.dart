import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/transaction/transaction_bloc.dart';
import '../logic/blocs/transaction/transaction_event.dart';
import '../logic/blocs/transaction/transaction_state.dart';
import '../data/models/transaction_model.dart';
import '../core/utils/formatter.dart';

class MyBarChartPage extends StatefulWidget {
  const MyBarChartPage({super.key});

  @override
  _MyBarChartPageState createState() => _MyBarChartPageState();
}

class _MyBarChartPageState extends State<MyBarChartPage> {
  int _selectedTab = 0; // 0: Tuần, 1: Tháng, 2: Quý, 3: Năm

  final List<String> tabs = ['Tuần', 'Tháng', 'Quý', 'Năm'];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu giao dịch khi màn hình được khởi tạo
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  // Tính toán dữ liệu từ transactions thật
  List<List<double>> _calculateIncomeData(List<TransactionModel> transactions) {
    final now = DateTime.now();
    List<List<double>> incomeData = [
      List.filled(7, 0), // Tuần
      List.filled(6, 0), // Tháng
      List.filled(4, 0), // Quý
      List.filled(2, 0), // Năm
    ];

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        final date = transaction.date;
        
        // Tuần (7 ngày gần nhất)
        if (date.isAfter(now.subtract(Duration(days: 7)))) {
          final dayIndex = date.weekday - 1; // 0-6
          incomeData[0][dayIndex] += transaction.amount;
        }
        
        // Tháng (6 tháng gần nhất)
        if (date.isAfter(now.subtract(Duration(days: 180)))) {
          final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
          if (monthDiff < 6) {
            incomeData[1][5 - monthDiff] += transaction.amount;
          }
        }
        
        // Quý (4 quý gần nhất)
        final quarter = ((date.month - 1) ~/ 3) + 1;
        final yearDiff = now.year - date.year;
        if (yearDiff <= 1) {
          final quarterIndex = yearDiff == 0 ? 4 - quarter : 0;
          if (quarterIndex >= 0 && quarterIndex < 4) {
            incomeData[2][quarterIndex] += transaction.amount;
          }
        }
        
        // Năm (2 năm gần nhất)
        final yearIndex = now.year - date.year;
        if (yearIndex < 2) {
          incomeData[3][yearIndex] += transaction.amount;
        }
      }
    }

    return incomeData;
  }

  List<List<double>> _calculateExpenseData(List<TransactionModel> transactions) {
    final now = DateTime.now();
    List<List<double>> expenseData = [
      List.filled(7, 0), // Tuần
      List.filled(6, 0), // Tháng
      List.filled(4, 0), // Quý
      List.filled(2, 0), // Năm
    ];

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final date = transaction.date;
        
        // Tuần (7 ngày gần nhất)
        if (date.isAfter(now.subtract(Duration(days: 7)))) {
          final dayIndex = date.weekday - 1; // 0-6
          expenseData[0][dayIndex] += transaction.amount;
        }
        
        // Tháng (6 tháng gần nhất)
        if (date.isAfter(now.subtract(Duration(days: 180)))) {
          final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
          if (monthDiff < 6) {
            expenseData[1][5 - monthDiff] += transaction.amount;
          }
        }
        
        // Quý (4 quý gần nhất)
        final quarter = ((date.month - 1) ~/ 3) + 1;
        final yearDiff = now.year - date.year;
        if (yearDiff <= 1) {
          final quarterIndex = yearDiff == 0 ? 4 - quarter : 0;
          if (quarterIndex >= 0 && quarterIndex < 4) {
            expenseData[2][quarterIndex] += transaction.amount;
          }
        }
        
        // Năm (2 năm gần nhất)
        final yearIndex = now.year - date.year;
        if (yearIndex < 2) {
          expenseData[3][yearIndex] += transaction.amount;
        }
      }
    }

    return expenseData;
  }

  List<List<String>> _generateLabels() {
    final now = DateTime.now();
    List<List<String>> labels = [
      ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
      [],
      [],
      [],
    ];

    // Tháng (6 tháng gần nhất)
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      labels[1].add('${adjustedMonth.toString().padLeft(2, '0')}/${year.toString().substring(2)}');
    }

    // Quý (4 quý gần nhất)
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    for (int i = 3; i >= 0; i--) {
      final quarter = currentQuarter - i;
      final year = now.year + (quarter <= 0 ? -1 : 0);
      final adjustedQuarter = quarter <= 0 ? quarter + 4 : quarter;
      labels[2].add('Q${adjustedQuarter}/${year.toString().substring(2)}');
    }

    // Năm (2 năm gần nhất)
    labels[3] = ['${now.year - 1}', '${now.year}'];

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Thống kê', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions;
            final incomeData = _calculateIncomeData(transactions);
            final expenseData = _calculateExpenseData(transactions);
            final labels = _generateLabels();

            // Lấy 5 giao dịch gần đây nhất
            final recentTransactions = transactions
              ..sort((a, b) => b.date.compareTo(a.date))
              ..take(5).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  ToggleButtons(
                    isSelected: List.generate(tabs.length, (index) => index == _selectedTab),
                    onPressed: (index) => setState(() => _selectedTab = index),
                    color: Colors.white,
                    selectedColor: Color(0xff000000),
                    borderColor: Colors.white,
                    selectedBorderColor: Color(0xffffffff),
                    fillColor: Color(0xff978fad),
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
                  if (recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Chưa có giao dịch nào',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ...recentTransactions.map((transaction) => Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == TransactionType.income ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            transaction.type == TransactionType.income ? Icons.arrow_upward : Icons.arrow_downward,
                            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(transaction.title),
                        subtitle: Text(Formatter.formatDate(transaction.date)),
                        trailing: Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}₫${transaction.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                  SizedBox(height: 100),
                ],
              ),
            );
          } else if (state is TransactionError) {
            return Center(
              child: Text(
                'Lỗi: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}