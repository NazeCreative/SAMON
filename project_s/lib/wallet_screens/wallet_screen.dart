import 'package:flutter/material.dart';
import 'edit_wallet_screen.dart';
import 'add_wallet_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showBalances = false;
  final List<Map<String, dynamic>> _wallets = [
    {
      'icon': 'device.png',
      'name': 'Ví chính',
      'balance': 200000
    },
    {
      'icon': 'device.png',
      'name': 'Ví tiết kiệm',
      'balance': 1000000
    },
  ];

  void _toggleVisibility() {
    setState(() {
      _showBalances = !_showBalances;
    });
  }

  void _addNewWallet(Map<String, dynamic> newWallet) {
    setState(() {
      _wallets.add(newWallet);
    });
  }

  void _updateWallet(int index, Map<String, dynamic> updatedWallet) {
    setState(() {
      _wallets[index] = updatedWallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalBalance = _wallets.fold(0, (sum, wallet) => sum + (wallet['balance'] as int));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Ví',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showBalances ? '${totalBalance.toString()} VND' : '****** VND',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_showBalances ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                  onPressed: _toggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ví của tôi',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddWalletScreen(),
                                ),
                              );
                              if (result != null) {
                                _addNewWallet(result);
                              }
                            },
                            child: const CircleAvatar(
                              backgroundColor: Color(0xffffbf0f),
                              child: Icon(Icons.add_circle_outline_outlined, color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                    ..._wallets.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> wallet = entry.value;
                      return WalletItem(
                        image: wallet['icon'],
                        title: wallet['name'],
                        balance: wallet['balance'],
                        showBalance: _showBalances,
                        onTap: () async {
                          final result = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditWalletScreen(wallet: wallet),
                            ),
                          );
                          if (result != null) {
                            _updateWallet(index, result);
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  final String image;
  final String title;
  final int balance;
  final bool showBalance;
  final VoidCallback onTap;

  const WalletItem({
    super.key,
    required this.image,
    required this.title,
    required this.balance,
    required this.showBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(image, width: 20, height: 20, fit: BoxFit.cover),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              showBalance ? '$balance VND' : '****** VND',
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            showBalance ? Icons.visibility : Icons.visibility_off,
            size: 16,
            color: Colors.white70,
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
    );
  }
}
