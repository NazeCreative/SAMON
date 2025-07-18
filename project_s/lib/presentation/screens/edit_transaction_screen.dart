import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../data/models/transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  
  String? _selectedWalletId;
  String? _selectedTransType;
  DateTime _selectedDate = DateTime.now();

  final _transTypeOptions = ['Thu', 'Chi'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.note);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _selectedWalletId = widget.transaction.walletId;
    _selectedTransType = widget.transaction.type == TransactionType.income ? 'Thu' : 'Chi';
    _selectedDate = widget.transaction.date;
    
    context.read<WalletBloc>().add(const WalletsFetched());
  }

  void _updateTransaction() {
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

    final updatedTransaction = widget.transaction.copyWith(
      note: _titleController.text,
      amount: amount,
      type: _selectedTransType == 'Thu' ? TransactionType.income : TransactionType.expense,
      walletId: _selectedWalletId,
      date: _selectedDate,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, updatedTransaction);
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bạn có chắc chắn muốn xóa giao dịch này?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, {'action': 'delete', 'transactionId': widget.transaction.id});
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        title: const Text('Sửa giao dịch', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
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
                        return DropdownMenuItem(
                          value: e, 
                          child: Text(e, style: const TextStyle(color: Colors.black)),
                        );
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
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'dd/MM/yyyy',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.black),
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
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cập nhật'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8),
      ),
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