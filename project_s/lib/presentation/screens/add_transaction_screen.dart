import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../data/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedTransType;
  DateTime _selectedDate = DateTime.now();

  final _transTypeOptions = ['Thu', 'Chi'];

  @override
  void initState() {
    super.initState();
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
          context.read<WalletBloc>().add(const WalletsFetched());
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
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoadSuccess) {
                    return _buildField(
                      child: DropdownButtonFormField<String>(
                        value: _selectedWalletId,
                        decoration: const InputDecoration(border: InputBorder.none),
                        hint: const Text('Ví', style: TextStyle(color: Colors.grey)),
                        items: state.wallets.map((wallet) {
                          return DropdownMenuItem(
                            value: wallet.id,
                            child: Text(wallet.name, style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedWalletId = val),
                      ),
                    );
                  }
                  return _buildField(
                    child: const Text('Đang tải ví...', style: TextStyle(color: Colors.grey)),
                  );
                },
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 32),
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
    if (_selectedWalletId == null) {
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
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền không hợp lệ'), backgroundColor: Colors.red),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập'), backgroundColor: Colors.red),
      );
      return;
    }
    final transaction = TransactionModel(
      id: '', 
      title: '',
      note: _titleController.text,
      amount: amount,
      type: _selectedTransType == 'Thu' ? TransactionType.income : TransactionType.expense,
      categoryId: _titleController.text, 
      walletId: _selectedWalletId ?? '',
      userId: user.uid,
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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
