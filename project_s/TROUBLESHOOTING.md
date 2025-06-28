# Hướng dẫn khắc phục lỗi SAMON App

## ✅ Đã khắc phục thành công:
- ✅ Lỗi reCAPTCHA - Đã được giải quyết
- ✅ Firebase Authentication - Hoạt động bình thường
- ✅ Ứng dụng build và chạy thành công

## ⚠️ Các vấn đề còn lại cần khắc phục:

### 1. Lỗi UI Overflow (Đã sửa)
**Triệu chứng:** `A RenderFlex overflowed by 109 pixels on the bottom`

**Giải pháp:** Đã wrap Column trong SingleChildScrollView trong `bar_chart_page.dart`

### 2. Lỗi kết nối Firestore
**Triệu chứng:** 
```
Could not reach Cloud Firestore backend. Backend didn't respond within 10 seconds
```

**Cách khắc phục:**
1. **Kiểm tra kết nối internet:**
   - Đảm bảo thiết bị có kết nối internet ổn định
   - Thử tắt/bật WiFi hoặc chuyển sang dữ liệu di động

2. **Kiểm tra Firebase Console:**
   - Đăng nhập Firebase Console: https://console.firebase.google.com
   - Chọn project "samon-ec83b"
   - Vào Firestore Database → Rules
   - Đảm bảo rules cho phép đọc/ghi

3. **Kiểm tra Firestore Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### 3. Lỗi Google Play Services
**Triệu chứng:**
```
Failed to get service from broker
Unknown calling package name 'com.google.android.gms'
```

**Cách khắc phục:**
1. **Cập nhật Google Play Services** trên thiết bị
2. **Kiểm tra SHA-1 fingerprint** trong Firebase Console
3. **Tải lại google-services.json** từ Firebase Console

## Các bước kiểm tra cơ bản

### 1. Kiểm tra Firebase Console:
1. Vào https://console.firebase.google.com
2. Chọn project "samon-ec83b"
3. Kiểm tra:
   - Authentication → Users (có user đã đăng nhập)
   - Firestore Database → Data (có dữ liệu không)
   - Project Settings → General (cấu hình app)

### 2. Kiểm tra kết nối:
```bash
# Test kết nối internet
ping google.com

# Test kết nối Firebase
curl https://samon-ec83b.firebaseapp.com
```

### 3. Kiểm tra logs:
```bash
# Xem logs chi tiết
flutter logs

# Chạy với verbose mode
flutter run --verbose
```

## Lệnh hữu ích

```bash
# Xóa cache và build lại
flutter clean
flutter pub get
flutter run

# Kiểm tra lỗi
flutter doctor
flutter analyze

# Build cho production
flutter build apk --release
```

## Trạng thái hiện tại

✅ **Hoạt động:**
- Firebase Authentication
- Đăng nhập/đăng ký
- UI cơ bản
- Navigation

⚠️ **Cần khắc phục:**
- Kết nối Firestore
- Google Play Services
- Một số lỗi UI nhỏ

## Liên hệ hỗ trợ

Nếu vẫn gặp lỗi, vui lòng:
1. Chụp màn hình lỗi
2. Copy log lỗi đầy đủ
3. Mô tả các bước đã thực hiện
4. Gửi thông tin thiết bị và phiên bản Flutter
 