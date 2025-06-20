import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';


class HomeScreen extends StatelessWidget {
  final String username = "Nguyễn Văn A";
  final double tongSoDu = 1000000;
  final double tienThu = 300000;
  final double tienChi = 200000;

  final List<Map<String, dynamic>> transactions = [
    {"title": "Ăn uống", "amount": 50000, "date": "18/06/2025"},
    {"title": "Mua sắm", "amount": 150000, "date": "17/06/2025"},
    {"title": "Lương", "amount": 500000, "date": "15/06/2025"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang chủ'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person, size: 30),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kính chào!', style: TextStyle(fontSize: 16)),
                    Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Tổng số dư', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    '₫${tongSoDu.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Tiền thu', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text(
                          '₫${tienThu.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Tiền chi', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text(
                          '₫${tienChi.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('Xem thêm'),
                      Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            ...transactions.map(
              (tx) => Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.image)),
                  title: Text(tx['title']),
                  subtitle: Text(tx['date']),
                  trailing: Text('₫${tx['amount']}'),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
