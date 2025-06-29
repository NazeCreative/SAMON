# Firestore Indexes Guide

## Vấn đề đã gặp phải

Ứng dụng SAMON đã gặp lỗi composite index khi thực hiện các query phức tạp với nhiều điều kiện `where` và `orderBy`.

## Giải pháp đã áp dụng

### 1. Sắp xếp trong Dart thay vì Firestore
Thay vì sử dụng `orderBy` trong Firestore query, chúng ta sắp xếp dữ liệu trong Dart code:

```dart
// Trước (gây lỗi index)
final QuerySnapshot snapshot = await _firestore
    .collection('wallets')
    .where('userId', isEqualTo: currentUser.uid)
    .orderBy('createdAt', descending: true)  // Cần composite index
    .get();

// Sau (không cần index)
final QuerySnapshot snapshot = await _firestore
    .collection('wallets')
    .where('userId', isEqualTo: currentUser.uid)
    .get();

// Sắp xếp trong Dart
wallets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
```

### 2. Các repository đã được sửa
- ✅ `WalletRepository.getWallets()`
- ✅ `TransactionRepository.getTransactions()`
- ✅ `TransactionRepository.getTransactionsByWallet()`
- ✅ `TransactionRepository.getTransactionsByDateRange()`

## Khi nào cần tạo Composite Index

Nếu trong tương lai bạn muốn sử dụng query phức tạp hơn, bạn có thể tạo composite index:

### 1. Tạo index cho Wallets
```javascript
// Collection: wallets
// Fields: userId (Ascending), createdAt (Descending)
```

### 2. Tạo index cho Transactions
```javascript
// Collection: transactions
// Fields: userId (Ascending), date (Descending), createdAt (Descending)
```

### 3. Tạo index cho Transactions by Wallet
```javascript
// Collection: transactions
// Fields: userId (Ascending), walletId (Ascending), date (Descending), createdAt (Descending)
```

### 4. Tạo index cho Transactions by Date Range
```javascript
// Collection: transactions
// Fields: userId (Ascending), date (Ascending), createdAt (Descending)
```

## Cách tạo index trong Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Firestore Database** > **Indexes**
4. Click **Create Index**
5. Chọn collection và thêm các fields cần thiết
6. Click **Create**

## Lưu ý quan trọng

- **Performance**: Sắp xếp trong Dart có thể chậm hơn với dataset lớn
- **Cost**: Composite index tăng chi phí Firestore
- **Maintenance**: Index cần thời gian để build và có thể fail
- **Flexibility**: Sắp xếp trong Dart cho phép logic phức tạp hơn

## Khuyến nghị

Với ứng dụng hiện tại:
- ✅ Sử dụng sắp xếp trong Dart (đã implement)
- ⚠️ Chỉ tạo index khi thực sự cần thiết
- 📊 Monitor performance và cost
- 🔄 Revisit khi dataset lớn hơn 1000 documents 