import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Text(
          'Tài khoản',
          style: TextStyle(color: Colors.white), // 👈 dòng này làm chữ trắng
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Thay bằng URL ảnh thật
            ),
            SizedBox(height: 10),
            Text(
              '[USERNAME]',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'username@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey, // Màu nền icon
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_a_photo, color: Colors.white, size: 20),
              ),
              title: Text('Thêm ảnh', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {},
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, color: Colors.white, size: 20),
              ),
              title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}