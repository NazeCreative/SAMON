import 'package:flutter/material.dart';
import '../data/models/wallet_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/services/cloudinary_service.dart';

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
  File? _iconFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet.name);
    balanceController = TextEditingController(text: widget.wallet.balance.toString());
    _icon = widget.wallet.icon;
    // Chỉ tạo File object nếu icon là đường dẫn local và không phải URL
    if (_icon != null && _icon!.isNotEmpty && !_icon!.startsWith('http') && _icon!.startsWith('/')) {
      _iconFile = File(_icon!);
    }
  }

  Future<void> _pickIconImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 256, maxHeight: 256, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _iconFile = File(pickedFile.path);
        _icon = null;
      });
    }
  }

  void _updateWallet() async {
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
    
    String iconPath = _icon ?? '';
    
    // Nếu có file ảnh mới được chọn, upload lên Cloudinary
    if (_iconFile != null) {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
      
      final uploadedUrl = await CloudinaryService.uploadImage(_iconFile!);
      Navigator.of(context).pop(); // Đóng loading dialog
      
      if (uploadedUrl != null) {
        iconPath = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi upload icon ví lên Cloudinary'), backgroundColor: Colors.red),
        );
        return;
      }
    }
    
    final updatedWallet = widget.wallet.copyWith(
      name: name,
      balance: balance,
      icon: iconPath,
    );
    Navigator.pop(context, updatedWallet);
  }

  void _deleteWallet() {
    Navigator.pop(context, {'action': 'delete', 'walletId': widget.wallet.id});
  }

  void _removeImage() {
    setState(() {
      _icon = null;
      _iconFile = null;
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
              onTap: _pickIconImage,
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
                      child: _iconFile != null
                          ? Image.file(_iconFile!, width: 60, height: 60, fit: BoxFit.contain)
                          : (_icon != null && _icon!.isNotEmpty
                              ? (_icon!.startsWith('http')
                                  ? Image.network(_icon!, width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, size: 40, color: Colors.grey);
                                    })
                                  : Image.asset(_icon!, width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image, size: 40, color: Colors.grey);
                                    }))
                              : const Icon(Icons.image, size: 40, color: Colors.grey)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    if (_iconFile != null || _icon != null)
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
