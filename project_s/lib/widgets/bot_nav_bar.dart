import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_s/presentation/screens/add_transaction_screen.dart';
import 'package:project_s/presentation/screens/home_screen.dart';
import 'package:project_s/presentation/wallet/wallet_screen.dart';
import 'package:project_s/presentation/screens/bar_chart_page.dart';
import 'package:project_s/presentation/screens/account.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  DateTime? _lastBackPressed;
  List Screen = [HomeScreen(), MyBarChartPage(), WalletScreen(), AccountScreen()]; //note đổi đường dẫn ở đây

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    
    if (_lastBackPressed != null && 
        now.difference(_lastBackPressed!) <= maxDuration) {
      SystemNavigator.pop();
      return false;
    }
    
    _lastBackPressed = now;
    
    return await _showExitDialog() ?? false;
  }

  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Thoát ứng dụng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Bạn có muốn thoát ứng dụng không?',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Không',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffffbf0f),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Có',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xff000000),
        body: Screen[index_color],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddTransactionScreen()));
          },
          child: Icon(Icons.add_circle_outline_outlined, size:40,),
          backgroundColor: Color(0xffffbf0f),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Color(0xff2d2d2d),
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 0;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 35,
                    color: index_color == 0 ? Color(0xffffbf0f) : Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 1;
                    });
                  },
                  child: Icon(
                    Icons.bar_chart_outlined,
                    size: 30,
                    color: index_color == 1 ? Color(0xffffbf0f) : Colors.grey,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 2;
                    });
                  },
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 30,
                    color: index_color == 2 ? Color(0xffffbf0f) : Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 3;
                    });
                  },
                  child: Icon(
                    Icons.person_outlined,
                    size: 30,
                    color: index_color == 3 ? Color(0xffffbf0f) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
