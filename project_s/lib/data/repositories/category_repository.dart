import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CategoryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  // Lấy danh sách tất cả danh mục (chỉ mặc định cho app)
  Future<List<CategoryModel>> getCategories() async {
    try {
      // Lấy danh mục mặc định (isDefault = true)
      final QuerySnapshot defaultCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('isDefault', isEqualTo: true)
          .orderBy('name')
          .get();

      final List<CategoryModel> defaultCategories = defaultCategoriesSnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      // Thêm log để debug
      print('Số lượng danh mục lấy được: [${defaultCategories.length}]');
      for (var cat in defaultCategories) {
        print('Category: [${cat.name}] - id: [${cat.id}]');
      }

      return defaultCategories;
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy danh sách danh mục: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy danh mục theo loại (thu/chi)
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy danh mục mặc định theo loại
      final QuerySnapshot defaultCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('isDefault', isEqualTo: true)
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

      // Lấy danh mục của người dùng theo loại
      final QuerySnapshot userCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

      final List<CategoryModel> defaultCategories = defaultCategoriesSnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      final List<CategoryModel> userCategories = userCategoriesSnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      return [...defaultCategories, ...userCategories];
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy danh mục theo loại: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Thêm danh mục mới
  Future<void> addCategory(CategoryModel category) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Tạo danh mục mới với userId của người dùng hiện tại
      final CategoryModel newCategory = category.copyWith(
        userId: currentUser.uid,
        isDefault: false, // Danh mục do người dùng tạo không phải mặc định
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Thêm vào Firestore
      await _firestore
          .collection('categories')
          .add(newCategory.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi thêm danh mục: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Cập nhật danh mục
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // Kiểm tra xem danh mục có ID không
      if (category.id == null) {
        throw Exception('ID danh mục không hợp lệ');
      }

      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Kiểm tra xem danh mục có thuộc về người dùng hiện tại không
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(category.id)
          .get();

      if (!doc.exists) {
        throw Exception('Danh mục không tồn tại');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['isDefault'] == true) {
        throw Exception('Không thể cập nhật danh mục mặc định');
      }

      if (data['userId'] != currentUser.uid) {
        throw Exception('Không có quyền cập nhật danh mục này');
      }

      // Cập nhật danh mục với thời gian mới
      final CategoryModel updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
      );

      // Cập nhật trong Firestore
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(updatedCategory.toFirestore());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền cập nhật danh mục này');
      } else {
        throw Exception('Lỗi khi cập nhật danh mục: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Kiểm tra xem danh mục có thuộc về người dùng hiện tại không
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (!doc.exists) {
        throw Exception('Danh mục không tồn tại');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['isDefault'] == true) {
        throw Exception('Không thể xóa danh mục mặc định');
      }

      if (data['userId'] != currentUser.uid) {
        throw Exception('Không có quyền xóa danh mục này');
      }

      // Xóa danh mục khỏi Firestore
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Không có quyền xóa danh mục này');
      } else {
        throw Exception('Lỗi khi xóa danh mục: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy danh mục theo ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      // Lấy User hiện tại từ FirebaseAuth
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy document từ Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      
      // Kiểm tra quyền truy cập (chỉ cho phép truy cập danh mục mặc định hoặc danh mục của người dùng)
      if (data['isDefault'] != true && data['userId'] != currentUser.uid) {
        throw Exception('Không có quyền truy cập danh mục này');
      }

      return CategoryModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi lấy danh mục: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
