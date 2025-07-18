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

  Future<List<CategoryModel>> getCategories() async {
    try {
      final QuerySnapshot defaultCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('isDefault', isEqualTo: true)
          .orderBy('name')
          .get();

      final List<CategoryModel> defaultCategories = defaultCategoriesSnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

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

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final QuerySnapshot defaultCategoriesSnapshot = await _firestore
          .collection('categories')
          .where('isDefault', isEqualTo: true)
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

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

  Future<void> addCategory(CategoryModel category) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final CategoryModel newCategory = category.copyWith(
        userId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('categories')
          .add(newCategory.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi thêm danh mục: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      if (category.id == null) {
        throw Exception('ID danh mục không hợp lệ');
      }

      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

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

      final CategoryModel updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
      );

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

  Future<void> deleteCategory(String categoryId) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

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

  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      
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
