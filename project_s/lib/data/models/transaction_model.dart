import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String? id;
  final String title;
  final String note;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String walletId;
  final String userId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    this.id,
    required this.title,
    required this.note,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.userId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      note: data['notes'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: data['categoryId'] ?? '',
      walletId: data['walletId'] ?? '',
      userId: data['userId'] ?? '',
      date: parseTimestamp(data['date']),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'notes': note,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'walletId': walletId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? note,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? walletId,
    String? userId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, type: $type, categoryId: $categoryId, walletId: $walletId, userId: $userId, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.title == title &&
        other.note == note &&
        other.amount == amount &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.walletId == walletId &&
        other.userId == userId &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        note.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        categoryId.hashCode ^
        walletId.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
