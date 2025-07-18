import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/wallet/wallet_bloc.dart';
import '../../blocs/wallet/wallet_event.dart';
import '../../blocs/wallet/wallet_state.dart';
import '../../data/models/wallet_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/cloudinary_service.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  String? _selectedIconAsset = 'assets/images/Samon_logo.png';
  File? _selectedIconFile;

  // Danh sách icon có sẵn
  final List<String> availableIcons = [
    'assets/images/Samon_logo.png',
    // Có thể thêm nhiều icon khác
  ];

  Future<void> _pickIconImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 256, maxHeight: 256, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedIconFile = File(pickedFile.path);
        _selectedIconAsset = null;
      });
    }
  }

  Future<void> _saveWallet() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên ví'), backgroundColor: Colors.red),
      );
      return;
    }

    // Parse số dư ban đầu
    double initialBalance = 0.0;
    final balanceText = balanceController.text.trim();
    if (balanceText.isNotEmpty) {
      try {
        initialBalance = double.parse(balanceText);
        if (initialBalance < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Số dư không được âm'), backgroundColor: Colors.red),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số dư không hợp lệ'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    // Xử lý icon: nếu là file, upload lên Cloudinary, nếu không thì dùng asset mặc định
    String iconUrl = _selectedIconAsset ?? '';
    if (_selectedIconFile != null) {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
      final uploadedUrl = await CloudinaryService.uploadImage(_selectedIconFile!);
      Navigator.of(context).pop();
      if (uploadedUrl != null) {
        iconUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi upload icon ví lên Cloudinary'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    // Tạo WalletModel với số dư ban đầu do người dùng nhập
    final wallet = WalletModel(
      name: name,
      icon: iconUrl,
      balance: initialBalance, // Số dư ban đầu do người dùng nhập
      userId: '', // Sẽ được set trong repository
    );

    // Gửi event để thêm ví
    context.read<WalletBloc>().add(WalletAdded(wallet));
    
    // Đóng màn hình
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm ví thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is WalletLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
                        child: _selectedIconFile != null
                          ? Image.file(_selectedIconFile!, width: 60, height: 60, fit: BoxFit.contain)
                          : Image.asset(_selectedIconAsset!, width: 60, height: 60, fit: BoxFit.contain),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Thông báo về số dư ban đầu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Để trống nếu số dư ban đầu là 0 VND',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
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
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }
}
