import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../core/utils/formatter.dart';
import 'edit_transaction_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List<CategoryModel> _categories = [];
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả'; // Tất cả, Thu, Chi
  
  final List<String> _filterOptions = ['Tất cả', 'Thu', 'Chi'];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<WalletBloc>().add(const WalletsFetched());
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Filter by search query
        final matchesSearch = _searchQuery.isEmpty ||
            transaction.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            transaction.title.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filter by type
        final matchesFilter = _selectedFilter == 'Tất cả' ||
            (_selectedFilter == 'Thu' && transaction.type == TransactionType.income) ||
            (_selectedFilter == 'Chi' && transaction.type == TransactionType.expense);

        return matchesSearch && matchesFilter;
      }).toList();
    });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Tất cả giao dịch', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, catState) {
          if (catState is CategoryLoaded) {
            setState(() {
              _categories = catState.categories;
            });
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (state is TransactionLoaded) {
              _allTransactions = state.transactions;
              if (_filteredTransactions.isEmpty && _searchQuery.isEmpty && _selectedFilter == 'Tất cả') {
                _filteredTransactions = _allTransactions;
              }

              return Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm giao dịch...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xff2d2d2d),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _filterTransactions();
                          },
                        ),
                        const SizedBox(height: 12),
                        // Filter Row
                        Row(
                          children: [
                            const Text(
                              'Lọc: ',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _filterOptions.map((filter) {
                                    final isSelected = _selectedFilter == filter;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        selected: isSelected,
                                        label: Text(filter),
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: const Color(0xff2d2d2d),
                                        selectedColor: const Color(0xff978fad),
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedFilter = filter;
                                          });
                                          _filterTransactions();
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Transaction Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredTransactions.length} giao dịch',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'Tổng: ${Formatter.formatCurrency(_filteredTransactions.fold<double>(0, (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount)))}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Transactions List
                  Expanded(
                    child: _filteredTransactions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: Colors.white70),
                                SizedBox(height: 16),
                                Text(
                                  'Không có giao dịch nào',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _filteredTransactions[index];
                              final isIncome = transaction.type == TransactionType.income;
                              final icon = getCategoryIcon(transaction.categoryId);
                              final color = getCategoryColor(transaction.categoryId);

                              return Card(
                                color: const Color(0xff181829),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                    child: Icon(icon, color: Colors.white, size: 20),
                                  ),
                                  title: Text(
                                    transaction.note.isNotEmpty ? transaction.note : transaction.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        getWalletName(transaction.walletId),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Formatter.formatDate(transaction.date),
                                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        (isIncome ? '+' : '-') + Formatter.formatCurrency(transaction.amount),
                                        style: TextStyle(
                                          color: isIncome ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            } else if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${state.message}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 