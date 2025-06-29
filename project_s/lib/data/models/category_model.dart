import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String? id;
  final String name;
  final String type; // 'income' hoặc 'expense'
  final String icon;
  final String color;
  final bool isDefault;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create CategoryModel from Firestore document snapshot
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'expense', // Mặc định là expense
      icon: data['icon'] ?? '',
      color: data['color'] ?? '#000000',
      isDefault: data['isDefault'] ?? false,
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert CategoryModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy of CategoryModel with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    bool? isDefault,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: $type, icon: $icon, color: $color, isDefault: $isDefault, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.icon == icon &&
        other.color == color &&
        other.isDefault == isDefault &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        isDefault.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 