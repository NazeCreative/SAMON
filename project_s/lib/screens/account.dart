import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../presentation/pages/welcome_page.dart';
import '../core/services/cloudinary_service.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? displayName;
  String? email;
  String? photoURL;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        displayName = doc.data()?['displayName'] ?? user.displayName ?? user.email ?? 'Người dùng';
        email = user.email;
        photoURL = doc.data()?['photoURL'] ?? user.photoURL;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn hình ảnh: $e')),
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );

      // Upload lên Cloudinary
      final downloadURL = await CloudinaryService.uploadImage(imageFile);

      if (downloadURL == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi upload ảnh lên Cloudinary')),
        );
        return;
      }

      // Cập nhật URL trong Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoURL': downloadURL});
      }

      // Cập nhật UI
      setState(() {
        photoURL = downloadURL;
      });

      // Đóng loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff000000),
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Text(
          'Tài khoản',
          style: TextStyle(color: Colors.white),
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
              backgroundImage: (photoURL != null && photoURL!.isNotEmpty)
                  ? NetworkImage(photoURL!)
                  : AssetImage('assets/images/Samon_logo.png') as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback to default image if network image fails
                setState(() {
                  photoURL = null;
                });
              },
            ),
            SizedBox(height: 10),
            Text(
              displayName ?? 'Đang tải...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_a_photo, color: Colors.white, size: 20),
              ),
              title: Text('Thêm ảnh', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: _pickImage,
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
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}