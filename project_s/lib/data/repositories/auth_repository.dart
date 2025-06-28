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

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy tài khoản với email này');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không đúng');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      } else if (e.code == 'user-disabled') {
        throw Exception('Tài khoản đã bị vô hiệu hóa');
      } else {
        throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }
}
