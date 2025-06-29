import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_event.dart';
import '../logic/blocs/category/category_state.dart';
import '../data/models/category_model.dart';
import '../data/models/wallet_model.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final TextEditingController balanceController = TextEditingController();
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  void _saveWallet() {
    final balanceText = balanceController.text.trim();
    if (_selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tên ví'), backgroundColor: Colors.red),
      );
      return;
    }
    double balance = 0.0;
    if (balanceText.isNotEmpty) {
      try {
        balance = double.parse(balanceText);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số dư không hợp lệ'), backgroundColor: Colors.red),
        );
        return;
      }
    }
    Navigator.pop(context, {
      'name': _selectedCategoryName!,
      'balance': balance,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Thêm Ví'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chọn tên ví từ categories
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Tên ví', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  final names = state.categories.map((c) => c.name).toSet().toList();
                  if (names.isEmpty) {
                    return const Text('Không có tên ví nào', style: TextStyle(color: Colors.red));
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryName,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.black,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Chọn tên ví', style: TextStyle(color: Colors.grey)),
                    items: names.map((name) {
                      return DropdownMenuItem(
                        value: name,
                        child: Text(name, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryName = val),
                  );
                } else if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Text('Không thể tải danh sách tên ví', style: TextStyle(color: Colors.red));
                }
              },
            ),
            const SizedBox(height: 20),
            // Số dư ban đầu
            TextField(
              controller: balanceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư ban đầu (VND)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Thêm'),
            )
          ],
        ),
      ),
    );
  }
}
