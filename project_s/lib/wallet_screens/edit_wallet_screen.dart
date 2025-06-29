import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_event.dart';
import '../logic/blocs/category/category_state.dart';
import '../data/models/category_model.dart';
import '../data/models/wallet_model.dart';

class EditWalletScreen extends StatefulWidget {
  final WalletModel wallet;

  const EditWalletScreen({super.key, required this.wallet});

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  late TextEditingController nameController;
  late TextEditingController balanceController;
  String? _icon;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet.name);
    balanceController = TextEditingController(text: widget.wallet.balance.toString());
    _icon = widget.wallet.icon;
  }

  void _updateWallet() {
    final name = nameController.text.trim();
    final balanceText = balanceController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên ví'), backgroundColor: Colors.red),
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
    final updatedWallet = widget.wallet.copyWith(
      name: name,
      balance: balance,
      icon: _icon ?? widget.wallet.icon,
    );
    Navigator.pop(context, updatedWallet);
  }

  void _deleteWallet() {
    Navigator.pop(context, {'action': 'delete', 'walletId': widget.wallet.id});
  }

  void _removeImage() {
    setState(() {
      _icon = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sửa Ví'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            // Tên ví
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên ví',
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
            const SizedBox(height: 20),
            // Số dư
            TextField(
              controller: balanceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư (VND)',
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
            const SizedBox(height: 20),
            // Icon ví
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Icon ví', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _icon = 'assets/images/Samon_logo.png';
                });
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _icon != null
                          ? Image.asset(_icon!, width: 60, height: 60, fit: BoxFit.contain)
                          : const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                    if (_icon != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(), 
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}
