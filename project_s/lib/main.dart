import 'package:flutter/material.dart';
import 'package:project_s/screens/home_screen.dart';
import 'presentation/widgets/bot_nav_bar.dart';
import 'presentation/pages/welcome_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMON Demo',
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}
