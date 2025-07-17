import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  WalletRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  Future<List<WalletModel>> getWallets() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('wallets')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final List<WalletModel> wallets = snapshot.docs
          .map((doc) => WalletModel.fromFirestore(doc))
          .toList();

      return wallets;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy danh sách ví: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> addWallet(WalletModel wallet) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final WalletModel newWallet = wallet.copyWith(
        userId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('wallets')
          .add(newWallet.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi thêm ví: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> updateWallet(WalletModel wallet) async {
    try {
      if (wallet.id == null) {
        throw Exception('ID ví không hợp lệ');
      }

      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final WalletModel updatedWallet = wallet.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('wallets')
          .doc(wallet.id)
          .update(updatedWallet.toFirestore());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền cập nhật ví này');
      } else {
        throw Exception('Lỗi khi cập nhật ví: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final DocumentSnapshot doc = await _firestore
          .collection('wallets')
          .doc(walletId)
          .get();

      if (!doc.exists) {
        throw Exception('Ví không tồn tại');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != currentUser.uid) {
        throw Exception('Không có quyền xóa ví này');
      }

      await _firestore
          .collection('wallets')
          .doc(walletId)
          .delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền xóa ví này');
      } else {
        throw Exception('Lỗi khi xóa ví: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<WalletModel?> getWalletById(String walletId) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final DocumentSnapshot doc = await _firestore
          .collection('wallets')
          .doc(walletId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != currentUser.uid) {
        throw Exception('Không có quyền truy cập ví này');
      }

      return WalletModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy thông tin ví: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> updateWalletBalance(String walletId, double newBalance) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      await _firestore
          .collection('wallets')
          .doc(walletId)
          .update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi cập nhật số dư ví: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
} 