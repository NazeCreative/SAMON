import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Controllers cho TextField
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  // State cho Dropdown
  String? _selectedType;
  String? _selectedWallet;
  String? _selectedTransType;

  // Các options mẫu
  final _typeOptions = ['Lựa chọn 1', 'Lựa chọn 2', 'Lựa chọn 3'];
  final _walletOptions = ['Lựa chọn 1', 'Lựa chọn 2', 'Lựa chọn 3'];
  final _transTypeOptions = ['Thu', 'Chi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Dropdown Loại
            _buildField(
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('Loại', style: TextStyle(color: Colors.grey)),
                items: _typeOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown Ví
            _buildField(
              child: DropdownButtonFormField<String>(
                value: _selectedWallet,
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('Ví', style: TextStyle(color: Colors.grey)),
                items: _walletOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedWallet = val),
              ),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            // Ngày
            _buildField(
              child: TextField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yy',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Số lượng
            _buildField(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Ghi chú
            _buildField(
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú thêm',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // Nút Thêm
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: xử lý thêm giao dịch
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80FF00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Thêm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    _quantityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
