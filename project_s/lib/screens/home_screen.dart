import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/transaction/transaction_bloc.dart';
import '../logic/blocs/transaction/transaction_event.dart';
import '../logic/blocs/transaction/transaction_state.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_event.dart';
import '../logic/blocs/category/category_state.dart';
import '../data/models/transaction_model.dart';
import '../data/models/category_model.dart';
import '../core/utils/formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/bloc/wallet/wallet_bloc.dart';
import '../presentation/bloc/wallet/wallet_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = doc.data()?['displayName'] ?? user.email ?? 'Người dùng';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Text(
          'Trang chủ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded) {
            setState(() {
              _categories = state.categories;
            });
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kính chào!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        username ?? 'Đang tải...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  double totalBalance = 0;
                  if (walletState is WalletLoadSuccess) {
                    final wallets = walletState.wallets;
                    totalBalance = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
                  }
                  return BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      double totalIncome = 0;
                      double totalExpense = 0;
                      List<TransactionModel> transactions = [];
                      if (state is TransactionLoaded) {
                        transactions = state.transactions;
                        for (var transaction in transactions) {
                          if (transaction.type == TransactionType.income) {
                            totalIncome += transaction.amount;
                          } else {
                            totalExpense += transaction.amount;
                          }
                        }
                      }
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Color(0xff22212e),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Tổng số dư', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 8),
                                Text(
                                  Formatter.formatCurrency(totalBalance),
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                                            SizedBox(width: 4),
                                            Text('Tiền thu', style: TextStyle(color: Colors.white70)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          Formatter.formatCurrency(totalIncome),
                                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                                            SizedBox(width: 4),
                                            Text('Tiền chi', style: TextStyle(color: Colors.white70)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          Formatter.formatCurrency(totalExpense),
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giao dịch gần đây',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff978fad)),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/transaction-detail');
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
                          if (transactions.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.white70)),
                            )
                          else
                            ...transactions.take(5).map((transaction) {
                              final isIncome = transaction.type == TransactionType.income;
                              final icon = getCategoryIcon(transaction.categoryId);
                              final color = getCategoryColor(transaction.categoryId);
                              return Card(
                                color: Color(0xff181829),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: Icon(icon, color: Colors.white),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        transaction.note.isNotEmpty ? transaction.note : transaction.title,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        (isIncome ? '+' : '-') + Formatter.formatCurrency(transaction.amount),
                                        style: TextStyle(
                                          color: isIncome ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          Formatter.formatDate(transaction.date),
                                          style: TextStyle(color: Colors.white38, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
