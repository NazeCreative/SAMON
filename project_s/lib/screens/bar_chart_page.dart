import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/transaction/transaction_bloc.dart';
import '../logic/blocs/transaction/transaction_event.dart';
import '../logic/blocs/transaction/transaction_state.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_state.dart';
import '../logic/blocs/category/category_event.dart';
import '../data/models/transaction_model.dart';
import '../data/models/category_model.dart';
import '../core/utils/formatter.dart';

class MyBarChartPage extends StatefulWidget {
  const MyBarChartPage({super.key});

  @override
  _MyBarChartPageState createState() => _MyBarChartPageState();
}

class _MyBarChartPageState extends State<MyBarChartPage> {
  int _selectedTab = 0; // 0: Tuần, 1: Tháng, 2: Quý, 3: Năm
  final List<String> tabs = ['Tuần', 'Tháng', 'Quý', 'Năm'];

  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  String getCategoryName(String categoryId) {
    try {
      final cat = _categories.firstWhere((c) => c.id == categoryId);
      return cat.name;
    } catch (e) {
      return '';
    }
  }

  IconData getCategoryIcon(String categoryId) {
    // Có thể mở rộng để trả về icon phù hợp
    return Icons.category;
  }

  Color getCategoryColor(String categoryId) {
    // Có thể mở rộng để trả về màu phù hợp
    return Colors.grey[800]!;
  }

  Map<String, dynamic> _calculateData(List<TransactionModel> transactions) {
    final now = DateTime.now();
    List<List<double>> incomeData = [
      List.filled(7, 0), // Tuần
      List.filled(6, 0), // Tháng
      List.filled(4, 0), // Quý (Q1/25, Q2/25, Q3/25, Q4/25)
      [], // Năm
    ];
    List<List<double>> expenseData = [
      List.filled(7, 0), // Tuần
      List.filled(6, 0), // Tháng
      List.filled(4, 0), // Quý
      [], // Năm
    ];

    // Tìm các năm có trong giao dịch
    final years = transactions.map((t) => t.date.year).toSet().toList()..sort();
    final yearCount = years.length > 2 ? 2 : years.length;
    incomeData[3] = List.filled(yearCount, 0.0);
    expenseData[3] = List.filled(yearCount, 0.0);

    // Kiểm tra xem có giao dịch trong năm sau (2026) không
    bool hasFutureYear = transactions.any((t) => t.date.year == now.year + 1);

    // Nếu có giao dịch trong năm sau, mở rộng mảng quý để thêm Q1/2026
    if (hasFutureYear) {
      incomeData[2] = List.filled(5, 0.0); // Thêm Q1/2026
      expenseData[2] = List.filled(5, 0.0);
    }

    for (var transaction in transactions) {
      if (transaction.date == null || transaction.amount == null) {
        print('Giao dịch không hợp lệ: ${transaction.toString()}');
        continue;
      }
      final date = transaction.date;
      final amount = transaction.amount;

      // Tuần
      if (date.isAfter(now.subtract(Duration(days: 7)))) {
        final dayIndex = date.weekday - 1; // 0=T2, ..., 6=CN
        if (transaction.type == TransactionType.income) {
          incomeData[0][dayIndex] += amount;
        } else {
          expenseData[0][dayIndex] += amount;
        }
      }

      // Tháng
      if (date.isAfter(now.subtract(Duration(days: 180)))) {
        final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
        if (monthDiff >= 0 && monthDiff < 6) {
          if (transaction.type == TransactionType.income) {
            incomeData[1][5 - monthDiff] += amount;
          } else {
            expenseData[1][5 - monthDiff] += amount;
          }
        }
      }

      // Quý
      final quarter = ((date.month - 1) ~/ 3) + 1;
      final yearDiff = now.year - date.year;
      if (yearDiff >= -1 && yearDiff <= 1) { // Xem xét năm trước, hiện tại, và năm sau
        int quarterIndex;
        if (yearDiff == 0) {
          // Năm hiện tại (2025): Q1=0, Q2=1, Q3=2, Q4=3
          quarterIndex = quarter - 1;
        } else if (yearDiff == 1) {
          // Năm trước (2024): Không hiển thị trong biểu đồ
          continue;
        } else if (yearDiff == -1 && quarter == 1) {
          // Năm sau (2026): Chỉ Q1/2026 ở index 4
          quarterIndex = 4;
        } else {
          continue; // Bỏ qua các quý khác của năm sau
        }
        if (quarterIndex >= 0 && quarterIndex < incomeData[2].length) {
          if (transaction.type == TransactionType.income) {
            incomeData[2][quarterIndex] += amount;
          } else {
            expenseData[2][quarterIndex] += amount;
          }
        }
      }

      // Năm
      final yearIndex = years.indexOf(date.year);
      if (yearIndex >= 0 && yearIndex < yearCount) {
        if (transaction.type == TransactionType.income) {
          incomeData[3][yearIndex] += amount;
        } else {
          expenseData[3][yearIndex] += amount;
        }
      }
    }

    return {
      'income': incomeData,
      'expense': expenseData,
      'years': years.take(yearCount).toList(),
      'hasFutureYear': hasFutureYear,
    };
  }

  List<List<String>> _generateLabels(List<int> years, bool hasFutureYear) {
    final now = DateTime.now();
    List<List<String>> labels = [
      ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'], // Khớp với weekday: 1=T2, ..., 7=CN
      [], // Tháng
      [], // Quý
      [], // Năm
    ];

    // Tháng
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      labels[1].add('${adjustedMonth.toString().padLeft(2, '0')}/${year.toString().substring(2)}');
    }

    // Quý: Q1/25, Q2/25, Q3/25, Q4/25, và thêm Q1/26 nếu có
    labels[2] = ['Q1/25', 'Q2/25', 'Q3/25', 'Q4/25'];
    if (hasFutureYear) {
      labels[2].add('Q1/26');
    }

    // Năm
    labels[3] = years.map((year) => year.toString()).toList();
    if (labels[3].isEmpty) {
      labels[3] = [now.year.toString()];
    }

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
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, catState) {
          if (catState is CategoryLoaded) {
            _categories = catState.categories;
          }
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (state is TransactionLoaded) {
                final transactions = state.transactions;
                final data = _calculateData(transactions);
                final incomeData = data['income'] as List<List<double>>;
                final expenseData = data['expense'] as List<List<double>>;
                final years = data['years'] as List<int>;
                final hasFutureYear = data['hasFutureYear'] as bool;
                final labels = _generateLabels(years, hasFutureYear);

                // Debug
                if (_selectedTab == 2) {
                  print('Labels quý: ${labels[2]}');
                  print('Income quý: ${incomeData[2]}');
                  print('Expense quý: ${expenseData[2]}');
                }

                final recentTransactions = List<TransactionModel>.from(transactions)
                  ..sort((a, b) => b.date.compareTo(a.date));

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ToggleButtons(
                        isSelected: List.generate(tabs.length, (index) => index == _selectedTab),
                        onPressed: state is TransactionLoading
                            ? null
                            : (index) => setState(() => _selectedTab = index),
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
                                            ? '${(value / 1000000).toStringAsFixed(1)}TR'
                                            : value >= 1000
                                            ? '${(value / 1000).toStringAsFixed(1)}K'
                                            : Formatter.formatNumber(value),
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
                                        return Text(
                                          labels[_selectedTab][idx],
                                          style: const TextStyle(fontSize: 10, color: Colors.white),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(labels[_selectedTab].length, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(toY: incomeData[_selectedTab][i], color: Colors.green, width: 10),
                                    BarChartRodData(toY: expenseData[_selectedTab][i], color: Colors.red, width: 10),
                                  ],
                                );
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
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xff978fad)),
                              onPressed: () {
                                Navigator.pushNamed(context, '/transaction-detail');
                              },
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
                        ...recentTransactions.take(5).map((transaction) => Card(
                          color: Color(0xff181829),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: getCategoryColor(transaction.categoryId),
                              child: Icon(getCategoryIcon(transaction.categoryId), color: Colors.white),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transaction.note.isNotEmpty ? transaction.note : transaction.title,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (transaction.type == TransactionType.income ? '+' : '-') +
                                      Formatter.formatCurrency(transaction.amount),
                                  style: TextStyle(
                                    color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(getCategoryName(transaction.categoryId), style: TextStyle(color: Colors.white70)),
                            trailing: Text(
                              Formatter.formatDate(transaction.date),
                              style: TextStyle(color: Colors.white38, fontSize: 12),
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
          );
        },
      ),
    );
  }
}