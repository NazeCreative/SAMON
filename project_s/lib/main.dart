import 'package:flutter/material.dart';
import 'presentation/pages/welcome_page.dart';
import 'package:project_s/presentation/widgets/bot_nav_bar.dart';

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
      home: const Bottom(),
    );
  }
}
