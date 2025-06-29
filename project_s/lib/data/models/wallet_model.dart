import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String? id;
  final String name;
  final String icon;
  final double balance;
  final String userId;

  WalletModel({
    this.id,
    required this.name,
    required this.icon,
    this.balance = 0.0,
    required this.userId,
  });

  // Create WalletModel from Firestore document snapshot
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
    );
  }

  // Convert WalletModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'balance': balance,
      'userId': userId,
    };
  }

  // Create a copy of WalletModel with updated fields
  WalletModel copyWith({
    String? id,
    String? name,
    String? icon,
    double? balance,
    String? userId,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
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