import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username = "Nguyễn Văn A";
  final double tongSoDu = 1000000;
  final double tienThu = 300000;
  final double tienChi = 200000;

  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Ăn uống",
      "amount": 50000,
      "date": "18/06/2025",
      "type": "expense", // Tiền ra
    },
    {
      "title": "Lương",
      "amount": 500000,
      "date": "15/06/2025",
      "type": "income", // Tiền vào
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Text(
          'Trang chủ',
          style: TextStyle(color: Colors.white), // 👈 dòng này làm chữ trắng
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
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
                    Text(
                      'Kính chào!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                color: Color(0xff7f3dff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'TỔNG SỐ DƯ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₫${tongSoDu.toStringAsFixed(0)}',
                    style: TextStyle( fontSize: 24,fontWeight: FontWeight.bold, color: Colors.white,),
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
                      color: Color(0xff61ac17),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tiền thu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₫${tienThu.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
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
                      color: Color(0xfff43c3c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tiền chi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₫${tienChi.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('Xem thêm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white,),
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
                  trailing: Text(
                    '${tx['type'] == 'income' ? '+' : '-'}${tx['amount']}₫',
                    style: TextStyle(
                      color: tx['type'] == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
