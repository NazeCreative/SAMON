import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = 
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user object
      final User? user = userCredential.user;
      
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email đã được sử dụng');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      } else {
        throw Exception('Đăng ký thất bại: ${e.message}');
      }
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthRepository: Attempting to sign in with email: $email');
      
      // Kiểm tra email và password trước khi gọi Firebase
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email và mật khẩu không được để trống');
      }
      
      if (!email.contains('@')) {
        throw Exception('Email không hợp lệ');
      }
      
      // Kiểm tra kết nối Firebase trước
      print('AuthRepository: Checking Firebase connection...');
      
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        print('AuthRepository: Sign in successful for user: \\${user.uid}');
        return user;
      } else {
        throw Exception('Đăng nhập thất bại: Không nhận được thông tin người dùng');
      }
    } on FirebaseAuthException catch (e) {
      print('AuthRepository: Firebase Auth Exception - \\${e.code}: \\${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Không tìm thấy tài khoản với email này');
        case 'wrong-password':
          throw Exception('Mật khẩu không đúng');
        case 'invalid-email':
          throw Exception('Email không hợp lệ');
        case 'user-disabled':
          throw Exception('Tài khoản đã bị vô hiệu hóa');
        case 'too-many-requests':
          throw Exception('Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet');
        default:
          throw Exception('Đăng nhập thất bại: \\${e.message}');
      }
    } catch (e) {
      print('AuthRepository: General Exception - \\${e}');
      if (e.toString().contains('network')) {
        throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet');
      }
      throw Exception('Đăng nhập thất bại: \\${e}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }

  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Kiểm tra xem có người dùng đang đăng nhập không
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Stream để lắng nghe thay đổi trạng thái đăng nhập
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  // Method để tạo tài khoản test
  Future<void> createTestAccount() async {
    try {
      print('AuthRepository: Creating test account...');
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: '123456',
      );
      
      if (userCredential.user != null) {
        print('AuthRepository: Test account created successfully: ${userCredential.user!.uid}');
        
        // Tạo user document trong Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': 'Test User',
          'email': 'test@example.com',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('AuthRepository: Test user document created in Firestore');
      }
    } catch (e) {
      print('AuthRepository: Error creating test account: $e');
      throw Exception('Không thể tạo tài khoản test: $e');
    }
  }
}
