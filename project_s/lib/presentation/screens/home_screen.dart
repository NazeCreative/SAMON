import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../core/utils/formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../blocs/wallet/wallet_event.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'edit_transaction_screen.dart';
import 'all_transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  String? photoURL;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<WalletBloc>().add(const WalletsFetched());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = doc.data()?['displayName'] ?? user.email ?? 'Người dùng';
        photoURL = doc.data()?['photoURL'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        title: const Text(
          'Trang chủ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryLoaded) {
                setState(() {
                  _categories = state.categories;
                });
              }
            },
          ),
          BlocListener<WalletBloc, WalletState>(
            listener: (context, state) {  
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                    child: (photoURL != null && photoURL!.isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photoURL!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30),
                      ),
                    )
                        : const Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kính chào!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        username ?? 'Đang tải...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  double totalBalance = 0;
                  if (walletState is WalletLoadSuccess) {
                    final wallets = walletState.wallets;
                    totalBalance = wallets.fold<double>(0, (total, wallet) => total + wallet.balance);
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
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xff22212e),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Tổng số dư', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 8),
                                AutoSizeText(
                                  Formatter.formatCurrency(totalBalance),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 16,
                                  maxFontSize: 32,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                                            const SizedBox(width: 4),
                                            const Text('Tiền thu', style: TextStyle(color: Colors.white70)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Formatter.formatCurrency(totalIncome),
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                                            const SizedBox(width: 4),
                                            const Text('Tiền chi', style: TextStyle(color: Colors.white70)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Formatter.formatCurrency(totalExpense),
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Giao dịch gần đây',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff978fad),
                                  minimumSize: const Size(100, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AllTransactionsScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Xem tất cả',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (transactions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.white70)),
                            )
                          else
                            ...transactions.take(5).map((transaction) {
                              final isIncome = transaction.type == TransactionType.income;
                              final icon = getCategoryIcon(transaction.categoryId);
                              final color = getCategoryColor(transaction.categoryId);
                              return Card(
                                color: const Color(0xff181829),
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                    backgroundColor: color,
                                    child: Icon(icon, color: Colors.white),
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              getWalletName(transaction.walletId),
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            (isIncome ? '+' : '-') + Formatter.formatCurrency(transaction.amount),
                                            style: TextStyle(
                                              color: isIncome ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
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
                              );
                            }).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}