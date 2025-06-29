import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/transaction/transaction_bloc.dart';
import '../logic/blocs/transaction/transaction_event.dart';
import '../logic/blocs/transaction/transaction_state.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_event.dart';
import '../logic/blocs/category/category_state.dart';
import '../presentation/bloc/wallet/wallet_bloc.dart';
import '../presentation/bloc/wallet/wallet_event.dart';
import '../presentation/bloc/wallet/wallet_state.dart';
import '../data/models/transaction_model.dart';
import '../data/models/category_model.dart';
import '../data/models/wallet_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Controllers cho TextField
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // State cho Dropdown
  CategoryModel? _selectedCategory;
  WalletModel? _selectedWallet;
  String? _selectedTransType;
  DateTime _selectedDate = DateTime.now();

  // Các options mẫu
  final _transTypeOptions = ['Thu', 'Chi'];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu danh mục và ví
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<WalletBloc>().add(const WalletsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2D2D2D),
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: const Text('Thêm giao dịch', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF2D2D2D),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            children: [
              // Tiêu đề (sẽ lưu vào notes)
              _buildField(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề giao dịch',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown Danh mục
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return _buildField(
                      child: DropdownButtonFormField<CategoryModel>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(border: InputBorder.none),
                        hint: const Text('Danh mục', style: TextStyle(color: Colors.grey)),
                        items: state.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name, style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                    );
                  }
                  // Không hiển thị gì khi chưa load xong danh mục
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),

              // Dropdown Ví
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoadSuccess) {
                    return _buildField(
                      child: DropdownButtonFormField<WalletModel>(
                        value: _selectedWallet,
                        decoration: const InputDecoration(border: InputBorder.none),
                        hint: const Text('Ví', style: TextStyle(color: Colors.grey)),
                        items: state.wallets.map((wallet) {
                          return DropdownMenuItem(
                            value: wallet,
                            child: Text(wallet.name, style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedWallet = val),
                      ),
                    );
                  }
                  return _buildField(
                    child: const Text('Đang tải ví...', style: TextStyle(color: Colors.grey)),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Dropdown Loại giao dịch
              _buildField(
                child: DropdownButtonFormField<String>(
                  value: _selectedTransType,
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: const Text('Loại giao dịch', style: TextStyle(color: Colors.grey)),
                  items: _transTypeOptions.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTransType = val),
                ),
              ),
              const SizedBox(height: 20),

              // Ngày (cho phép nhập tay hoặc chọn lịch)
              _buildField(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        ),
                        readOnly: false,
                        decoration: const InputDecoration(
                          hintText: 'dd/MM/yyyy',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (val) {
                          final parts = val.split('/');
                          if (parts.length == 3) {
                            final day = int.tryParse(parts[0]);
                            final month = int.tryParse(parts[1]);
                            final year = int.tryParse(parts[2]);
                            if (day != null && month != null && year != null) {
                              setState(() {
                                _selectedDate = DateTime(year, month, day);
                              });
                            }
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Số tiền giao dịch (đưa xuống dưới cùng)
              _buildField(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Số tiền giao dịch',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Thêm
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is TransactionLoading ? null : _addTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF80FF00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: state is TransactionLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Thêm',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTransaction() {
    // Validate form
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedTransType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại giao dịch'), backgroundColor: Colors.red),
      );
      return;
    }

    // Parse amount
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền không hợp lệ'), backgroundColor: Colors.red),
      );
      return;
    }

    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập'), backgroundColor: Colors.red),
      );
      return;
    }

    // Create transaction: Lưu tiêu đề vào note, để title là chuỗi rỗng
    final transaction = TransactionModel(
      id: '', // Sẽ được tạo bởi Firestore
      title: '',
      note: _titleController.text,
      amount: amount,
      type: _selectedTransType == 'Thu' ? TransactionType.income : TransactionType.expense,
      categoryId: _selectedCategory!.id ?? '',
      walletId: _selectedWallet!.id ?? '',
      userId: user.uid,
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Dispatch event
    context.read<TransactionBloc>().add(AddTransaction(transaction));
  }

  Widget _buildField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
