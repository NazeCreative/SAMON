import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String? id;
  final String name;
  final String icon;
  final double balance;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletModel({
    this.id,
    required this.name,
    required this.icon,
    this.balance = 0.0,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Create WalletModel from Firestore document snapshot
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }
    
    return WalletModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  // Convert WalletModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'balance': balance,
      'userId': userId,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // Create a copy of WalletModel with updated fields
  WalletModel copyWith({
    String? id,
    String? name,
    String? icon,
    double? balance,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WalletModel(id: $id, name: $name, icon: $icon, balance: $balance, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletModel &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.balance == balance &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        balance.hashCode ^
        userId.hashCode;
  }
} 