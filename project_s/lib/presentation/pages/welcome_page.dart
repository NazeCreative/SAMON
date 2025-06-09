import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/Samon_logo.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 32),
                  // Welcome text
                  const Text(
                    'Chào mừng tới',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 4),
                  // SAMON title
                  const Text(
                    'SAMON',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Quản lý chi tiêu đáng tin cậy của bạn',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Start text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cùng bắt đầu...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Google button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Continue with Google',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.alternate_email, color: Colors.deepPurple, size: 24),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Continue with Email',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Đã có tài khoản ? '),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng sang trang login nếu cần
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF8c09ff),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 