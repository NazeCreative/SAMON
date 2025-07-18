import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/category/category_event.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../core/utils/formatter.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../blocs/wallet/wallet_event.dart';
import 'edit_transaction_screen.dart';
import 'all_transactions_screen.dart';

class MyBarChartPage extends StatefulWidget {
  const MyBarChartPage({super.key});

  @override
  MyBarChartPageState createState() => MyBarChartPageState();
}

class MyBarChartPageState extends State<MyBarChartPage> {
  int _selectedTab = 0; 
  final List<String> tabs = ['Tuần', 'Tháng', 'Quý', 'Năm'];
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<WalletBloc>().add(const WalletsFetched());
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
    return Icons.category;
  }

  Color getCategoryColor(String categoryId) {
    return Colors.grey[800]!;
  }

  String getWalletName(String walletId) {
    try {
      final walletState = context.read<WalletBloc>().state;
      if (walletState is WalletLoadSuccess) {
        final wallet = walletState.wallets.firstWhere((w) => w.id == walletId);
        return wallet.name;
      }
    } catch (e) {
      return '';
    }
    return '';
  }

  Map<String, dynamic> _calculateData(List<TransactionModel> transactions) {
    final now = DateTime.now(); // 30/06/2025
    List<List<double>> incomeData = [
      List.filled(7, 0.0), 
      List.filled(6, 0.0), 
      List.filled(4, 0.0), 
      [], 
    ];
    List<List<double>> expenseData = [
      List.filled(7, 0.0), 
      List.filled(6, 0.0), 
      List.filled(4, 0.0), 
      [], 
    ];
    List<List<String>> dynamicLabels = [
      [], 
      [], 
      [], 
      [], 
    ];

    DateTime? latestDate;
    if (transactions.isNotEmpty) {
      latestDate = transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    } else {
      latestDate = now;
    }

    final weekDays = List.generate(7, (i) => latestDate!.subtract(Duration(days: 6 - i)));
    dynamicLabels[0] = weekDays
        .map((date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}')
        .toList();

    final latestMonth = DateTime(latestDate.year, latestDate.month, 1);
    dynamicLabels[1] = List.generate(6, (i) {
      final date = latestMonth.subtract(Duration(days: 30 * i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    })..sort();

    final latestQuarter = ((latestDate.month - 1) ~/ 3) + 1;
    final latestQuarterYear = latestDate.year;
    dynamicLabels[2] = List.generate(4, (i) {
      final q = latestQuarter - i;
      final year = latestQuarterYear - (q <= 0 ? 1 : 0);
      final adjustedQ = q <= 0 ? q + 4 : q;
      return '$year-Q$adjustedQ';
    })..sort();

    final years = transactions.map((t) => t.date.year).toSet().toList()..sort();
    final yearCount = years.length > 2 ? 2 : years.length;
    incomeData[3] = List.filled(yearCount, 0.0);
    expenseData[3] = List.filled(yearCount, 0.0);
    dynamicLabels[3] = years.take(yearCount).map((y) => y.toString()).toList();
    if (dynamicLabels[3].isEmpty) {
      dynamicLabels[3] = [now.year.toString()];
      incomeData[3] = [0.0];
      expenseData[3] = [0.0];
    }

    for (var transaction in transactions) {
      final date = transaction.date;
      final amount = transaction.amount;

      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayIndex = dynamicLabels[0].indexOf(dayKey);
      if (dayIndex >= 0) {
        if (transaction.type == TransactionType.income) {
          incomeData[0][dayIndex] += amount;
        } else {
          expenseData[0][dayIndex] += amount;
        }
      }

      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final monthIndex = dynamicLabels[1].indexOf(monthKey);
      if (monthIndex >= 0) {
        if (transaction.type == TransactionType.income) {
          incomeData[1][monthIndex] += amount;
        } else {
          expenseData[1][monthIndex] += amount;
        }
      }

      final quarter = ((date.month - 1) ~/ 3) + 1;
      final quarterKey = '${date.year}-Q$quarter';
      final quarterIndex = dynamicLabels[2].indexOf(quarterKey);
      if (quarterIndex >= 0) {
        if (transaction.type == TransactionType.income) {
          incomeData[2][quarterIndex] += amount;
        } else {
          expenseData[2][quarterIndex] += amount;
        }
      }

      final yearIndex = dynamicLabels[3].indexOf(date.year.toString());
      if (yearIndex >= 0) {
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
      'labels': dynamicLabels,
    };
  }

  List<List<String>> _generateLabels(List<List<String>> dynamicLabels) {
    final now = DateTime.now();
    List<List<String>> labels = [
      [], 
      [], 
      [], 
      [], 
    ];

    labels[0] = dynamicLabels[0].map((dayKey) {
      final parts = dayKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final weekday = date.weekday;
      final weekdayStr = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][weekday - 1];
      return '$weekdayStr\n${parts[2]}/${parts[1]}';
    }).toList();

    labels[1] = dynamicLabels[1].map((monthKey) {
      final parts = monthKey.split('-');
      return '${parts[1]}/${parts[0].substring(2)}';
    }).toList();

    labels[2] = dynamicLabels[2].map((quarterKey) {
      final parts = quarterKey.split('-Q');
      return 'Q${parts[1]}/${parts[0].substring(2)}';
    }).toList();

    labels[3] = dynamicLabels[3];

    if (labels[0].isEmpty) {
      final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
      labels[0] = weekDays.map((date) {
        final weekdayStr = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][date.weekday - 1];
        return '$weekdayStr\n${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }).toList();
    }
    if (labels[1].isEmpty) {
      labels[1] = List.generate(6, (i) {
        final date = now.subtract(Duration(days: 30 * i));
        return '${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
      })..sort();
    }
    if (labels[2].isEmpty) {
      final currentQuarter = ((now.month - 1) ~/ 3) + 1;
      labels[2] = List.generate(4, (i) {
        final q = currentQuarter - i;
        final year = now.year - (q <= 0 ? 1 : 0);
        final adjustedQ = q <= 0 ? q + 4 : q;
        return 'Q$adjustedQ/${year.toString().substring(2)}';
      })..sort();
    }
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
                final dynamicLabels = data['labels'] as List<List<String>>;
                final labels = _generateLabels(dynamicLabels);
                

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
                        selectedColor: const Color(0xff000000),
                        borderColor: Colors.white,
                        selectedBorderColor: const Color(0xffffffff),
                        fillColor: const Color(0xff978fad),
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
                      SizedBox(
                        height: 350,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: BarChart(
                            BarChartData(
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 80,
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
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) {
                                      int idx = value.toInt();
                                      if (idx >= 0 && idx < labels[_selectedTab].length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            labels[_selectedTab][idx],
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
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
                                  barsSpace: 4,
                                );
                              }),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
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
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff978fad)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AllTransactionsScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text('Xem tất cả', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                                ],
                              ),
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
                          color: const Color(0xff181829),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionScreen(transaction: transaction),
                                ),
                              );
                              
                              if (result != null && context.mounted) {
                                if (result is TransactionModel) {
                                  context.read<TransactionBloc>().add(UpdateTransaction(result));
                                } else if (result is Map<String, dynamic> && result['action'] == 'delete') {
                                  context.read<TransactionBloc>().add(DeleteTransaction(result['transactionId']));
                                }
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: getCategoryColor(transaction.categoryId),
                              child: Icon(getCategoryIcon(transaction.categoryId), color: Colors.white),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.note.isNotEmpty ? transaction.note : transaction.title,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        getWalletName(transaction.walletId),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      (transaction.type == TransactionType.income ? '+' : '-') +
                                          Formatter.formatCurrency(transaction.amount),
                                      style: TextStyle(
                                        color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      Formatter.formatDate(transaction.date),
                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                          ),
                        )),
                      const SizedBox(height: 100),
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