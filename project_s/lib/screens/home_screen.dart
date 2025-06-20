import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final String username = "Nguyễn Văn A";
  final double tongSoDu = 1000000;
  final double tienThu = 300000;
  final double tienChi = 200000;

  final List<Map<String, dynamic>> transactions = [
    {"title": "Ăn uống", "amount": 50000, "date": "18/06/2025"},
    {"title": "Mua sắm", "amount": 150000, "date": "17/06/2025"},
    {"title": "Lương", "amount": 500000, "date": "15/06/2025"},
  ];

  List<Widget> get screens => [
    _buildMainContent(),
    const Center(child: Text('Thống kê', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Ghi chú', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Tài khoản', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Khác', style: TextStyle(fontSize: 24))),
  ];

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                child: const Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kính chào!', style: TextStyle(fontSize: 16)),
                  Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Tổng số dư', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('₫${tongSoDu.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Tiền thu', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('₫${tienThu.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Tiền chi', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('₫${tienChi.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Giao dịch gần đây', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [Text('Xem thêm'), Icon(Icons.arrow_forward_ios, size: 12)],
                ),
              )
            ],
          ),
          ...transactions.map((tx) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.image),
              ),
              title: Text(tx['title']),
              subtitle: Text(tx['date']),
              trailing: Text('₫${tx['amount']}'),
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAMON Demo'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: screens[index],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: index,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.bar_chart, size: 30),
          Icon(Icons.receipt_long, size: 30),
          Icon(Icons.person, size: 30),
          Icon(Icons.more_horiz, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
