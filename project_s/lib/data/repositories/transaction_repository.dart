import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'wallet_repository.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final WalletRepository _walletRepository;

  TransactionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
    required WalletRepository walletRepository,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth,
        _walletRepository = walletRepository;

  // Lấy danh sách giao dịch của người dùng
  Future<List<TransactionModel>> getTransactions() async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Tạo query để lấy các giao dịch của người dùng hiện tại
      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      // Chuyển đổi các document thành TransactionModel
      final List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Sắp xếp theo date và createdAt trong Dart thay vì trong query
      transactions.sort((a, b) {
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        return b.createdAt.compareTo(a.createdAt);
      });

      return transactions;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy danh sách giao dịch: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy giao dịch theo ví
  Future<List<TransactionModel>> getTransactionsByWallet(String walletId) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUser.uid)
          .where('walletId', isEqualTo: walletId)
          .get();

      final List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Sắp xếp theo date và createdAt trong Dart
      transactions.sort((a, b) {
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        return b.createdAt.compareTo(a.createdAt);
      });

      return transactions;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy giao dịch theo ví: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy giao dịch theo khoảng thời gian
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Sắp xếp theo date và createdAt trong Dart
      transactions.sort((a, b) {
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        return b.createdAt.compareTo(a.createdAt);
      });

      return transactions;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy giao dịch theo thời gian: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Thêm giao dịch mới
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Tạo giao dịch mới với userId của người dùng hiện tại
      final TransactionModel newTransaction = transaction.copyWith(
        userId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sử dụng Firestore Transaction để đảm bảo tính toàn vẹn dữ liệu
      await _firestore.runTransaction((transaction) async {
        // Bước 1: Đọc thông tin ví trước
        final walletRef = _firestore.collection('wallets').doc(newTransaction.walletId);
        final walletDoc = await transaction.get(walletRef);

        if (!walletDoc.exists) {
          throw Exception('Ví không tồn tại');
        }

        final walletData = walletDoc.data() as Map<String, dynamic>;
        final currentBalance = (walletData['balance'] ?? 0.0).toDouble();

        // Tính toán số dư mới
        double newBalance = currentBalance;
        if (newTransaction.type == TransactionType.income) {
          newBalance += newTransaction.amount;
        } else {
          newBalance -= newTransaction.amount;
        }

        // Bước 2: Ghi dữ liệu (tạo transaction mới và cập nhật ví)
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, newTransaction.toFirestore());

        transaction.update(walletRef, {
          'balance': newBalance,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi thêm giao dịch: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Cập nhật giao dịch
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      // Kiểm tra xem giao dịch có ID không
      if (transaction.id == null) {
        throw Exception('ID giao dịch không hợp lệ');
      }

      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy giao dịch cũ để tính toán lại số dư
      final DocumentSnapshot oldDoc = await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .get();

      if (!oldDoc.exists) {
        throw Exception('Giao dịch không tồn tại');
      }

      final TransactionModel oldTransaction = TransactionModel.fromFirestore(oldDoc);

      // Kiểm tra quyền sở hữu
      if (oldTransaction.userId != currentUser.uid) {
        throw Exception('Không có quyền cập nhật giao dịch này');
      }

      // Cập nhật giao dịch với thời gian mới
      final TransactionModel updatedTransaction = transaction.copyWith(
        createdAt: DateTime.now(),
      );

      // Cập nhật trong Firestore
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(updatedTransaction.toFirestore());

      // Cập nhật số dư ví (hoàn tác giao dịch cũ và áp dụng giao dịch mới)
      await _revertWalletBalance(oldTransaction);
      await _updateWalletBalance(updatedTransaction);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền cập nhật giao dịch này');
      } else {
        throw Exception('Lỗi khi cập nhật giao dịch: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Xóa giao dịch
  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy giao dịch trước khi xóa để tính toán lại số dư
      final DocumentSnapshot doc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!doc.exists) {
        throw Exception('Giao dịch không tồn tại');
      }

      final TransactionModel transaction = TransactionModel.fromFirestore(doc);

      // Kiểm tra quyền sở hữu
      if (transaction.userId != currentUser.uid) {
        throw Exception('Không có quyền xóa giao dịch này');
      }

      // Xóa giao dịch khỏi Firestore
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .delete();

      // Hoàn tác số dư ví
      await _revertWalletBalance(transaction);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền xóa giao dịch này');
      } else {
        throw Exception('Lỗi khi xóa giao dịch: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy giao dịch theo ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy document từ Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final TransactionModel transaction = TransactionModel.fromFirestore(doc);

      // Kiểm tra quyền sở hữu
      if (transaction.userId != currentUser.uid) {
        throw Exception('Không có quyền truy cập giao dịch này');
      }

      return transaction;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy giao dịch: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Cập nhật số dư ví khi thêm giao dịch
  Future<void> _updateWalletBalance(TransactionModel transaction) async {
    try {
      // Lấy thông tin ví
      final wallet = await _walletRepository.getWalletById(transaction.walletId);
      if (wallet == null) {
        throw Exception('Ví không tồn tại');
      }

      // Tính toán số dư mới
      double newBalance = wallet.balance;
      if (transaction.type == TransactionType.income) {
        newBalance += transaction.amount;
      } else {
        newBalance -= transaction.amount;
      }

      // Cập nhật số dư ví
      final updatedWallet = wallet.copyWith(
        balance: newBalance,
      );

      await _walletRepository.updateWallet(updatedWallet);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật số dư ví: $e');
    }
  }

  // Hoàn tác số dư ví khi xóa hoặc cập nhật giao dịch
  Future<void> _revertWalletBalance(TransactionModel transaction) async {
    try {
      // Lấy thông tin ví
      final wallet = await _walletRepository.getWalletById(transaction.walletId);
      if (wallet == null) {
        throw Exception('Ví không tồn tại');
      }

      // Tính toán số dư mới (hoàn tác giao dịch)
      double newBalance = wallet.balance;
      if (transaction.type == TransactionType.income) {
        newBalance -= transaction.amount; // Hoàn tác thu nhập
      } else {
        newBalance += transaction.amount; // Hoàn tác chi tiêu
      }

      // Cập nhật số dư ví
      final updatedWallet = wallet.copyWith(
        balance: newBalance,
      );

      await _walletRepository.updateWallet(updatedWallet);
    } catch (e) {
      throw Exception('Lỗi khi hoàn tác số dư ví: $e');
    }
  }

  // Tính tổng thu nhập trong khoảng thời gian
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      double total = 0.0;
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Lỗi khi tính tổng thu nhập: $e');
    }
  }

  // Tính tổng chi tiêu trong khoảng thời gian
  Future<double> getTotalExpense(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      double total = 0.0;
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Lỗi khi tính tổng chi tiêu: $e');
    }
  }
}
