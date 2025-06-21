import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Thêm giao dịch'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown('Loại'),
            SizedBox(height: 12),
            _buildDropdown('Ví'),
            SizedBox(height: 12),
            _buildDropdown('Loại giao dịch'),
            SizedBox(height: 12),
            _buildDateField(),
            SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Ghi chú thêm',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: ['Tùy chọn 1', 'Tùy chọn 2']
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: 'Ngày (dd/mm/yyyy)',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.edit_calendar),
      ),
      keyboardType: TextInputType.datetime,
    );
  }
}
