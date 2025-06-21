import 'package:flutter/material.dart';

class EditWalletScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const EditWalletScreen({super.key, required this.wallet});

  @override
  State<EditWalletScreen> createState() => _EditWalletScreenState();
}

class _EditWalletScreenState extends State<EditWalletScreen> {
  late TextEditingController nameController;
  String? _icon;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet['name']);
    _icon = widget.wallet['icon'];
  }

  void _updateWallet() {
    final updatedWallet = {
      'name': nameController.text,
      'icon': _icon!,
    };
    Navigator.pop(context, updatedWallet);
  }

  void _removeImage() {
    setState(() {
      _icon = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên ví',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Icon ví', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _icon = 'assets/user_icon.png';
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
                          ? Image.asset(_icon!)
                          : const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                    if (_icon != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(), // Đẩy phần dưới xuống đáy
            Row(
              children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // tạo khoảng cách với đáy
          ],
        ),
      ),
    );
  }
}
