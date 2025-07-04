import 'package:flutter/material.dart';
import 'package:project_s/screens/add_transaction_screen.dart';
import 'package:project_s/screens/home_screen.dart';
import 'package:project_s/wallet_screens/wallet_screen.dart';
import 'package:project_s/screens/bar_chart_page.dart';
import 'package:project_s/screens/account.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  List Screen = [HomeScreen(), MyBarChartPage(), WalletScreen(), AccountScreen()]; //note đổi đường dẫn ở đây
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
