import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<ResetCategories>(_onResetCategories);
    on<LoadCategoriesByType>(_onLoadCategoriesByType);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final categories = await _categoryRepository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onResetCategories(
    ResetCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryInitial());
  }

  Future<void> _onLoadCategoriesByType(
    LoadCategoriesByType event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      final categories = await _categoryRepository.getCategoriesByType(event.type);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _categoryRepository.addCategory(event.category);
      final categories = await _categoryRepository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _categoryRepository.updateCategory(event.category);
      final categories = await _categoryRepository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _categoryRepository.deleteCategory(event.categoryId);
      final categories = await _categoryRepository.getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
} 