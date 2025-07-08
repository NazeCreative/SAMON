# SAMON - Ứng dụng Quản lý Chi tiêu

**SAMON** là một ứng dụng quản lý chi tiêu đa nền tảng, được xây dựng bằng Flutter, giúp bạn theo dõi tình hình tài chính một cách dễ dàng và hiệu quả.

## ✨ Tính năng nổi bật

*   **Xác thực người dùng:** Đăng nhập và đăng ký an toàn.
*   **Quản lý Ví:** Tạo và quản lý nhiều ví tiền khác nhau.
*   **Theo dõi Giao dịch:** Thêm, sửa, và xem lại các khoản thu chi.
*   **Phân loại Giao dịch:** Sắp xếp các giao dịch vào những danh mục tùy chỉnh.
*   **Trực quan hóa Dữ liệu:** Phân tích chi tiêu qua các biểu đồ báo cáo.
*   **Đa nền tảng:** Hoạt động trên Android, Web, và Windows từ một mã nguồn duy nhất.

## 🛠️ Công nghệ và Kiến trúc

Dự án được xây dựng với các công nghệ hiện đại và tuân thủ theo nguyên tắc Clean Architecture để đảm bảo khả năng mở rộng và bảo trì.

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Quản lý Trạng thái (State Management):** [BLoC (Business Logic Component)](https://bloclibrary.dev/)
*   **Backend & Cơ sở dữ liệu:** [Firebase (Authentication, Firestore)](https://firebase.google.com/)
*   **Kiến trúc:** Clean Architecture, Repository Pattern.

## 📂 Cấu trúc Dự án

Cấu trúc thư mục được tổ chức theo các lớp của Clean Architecture, tách biệt rõ ràng các mối quan tâm (separation of concerns).

```
project_s/
├── lib/
│   ├── main.dart                 # Điểm khởi chạy ứng dụng
│   ├── firebase_options.dart     # Cấu hình Firebase
│   │
│   ├── blocs/                    # BLoC - Quản lý trạng thái
│   │   ├── auth/
│   │   ├── category/
│   │   ├── transaction/
│   │   └── wallet/
│   │
│   ├── core/                     # Các tiện ích, dịch vụ và theme cốt lõi
│   │   ├── services/
│   │   └── utils/
│   │
│   ├── data/                     # Lớp Dữ liệu (Models & Repositories)
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── presentation/             # Lớp Giao diện (Màn hình & Widgets)
│   │   ├── auth/                 # Các màn hình xác thực (Đăng nhập, Đăng ký)
│   │   ├── screens/              # Các màn hình tính năng chính
│   │   └── wallet/               # Các màn hình liên quan đến ví
│   │
│   └── widgets/                  # Các thành phần UI có thể tái sử dụng
│
├── assets/                       # Chứa các tài nguyên tĩnh (ảnh, font)
│
├── android/                      # Mã nguồn cho nền tảng Android
├── web/                          # Mã nguồn cho nền tảng Web
├── windows/                      # Mã nguồn cho nền tảng Windows
│
├── pubspec.yaml                  # Quản lý dependencies và assets của dự án
└── README.md                     # Tệp README này
```

## 🚀 Bắt đầu

### Yêu cầu hệ thống

*   Flutter SDK (Phiên bản ổn định mới nhất)
*   Dart SDK (Phiên bản ổn định mới nhất)
*   Một IDE như Android Studio hoặc VS Code đã cài đặt plugin Flutter.
*   Git

### Cài đặt

1.  **Clone repository về máy:**
    ```sh
    git clone https://github.com/your-username/SAMON.git
    cd SAMON/project_s
    ```

2.  **Cài đặt các dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Chạy ứng dụng:**
    ```sh
    flutter run
    ```

## 🤝 Đóng góp

Chúng tôi luôn chào đón các đóng góp! Nếu bạn muốn đóng góp cho dự án, vui lòng làm theo các bước sau:

1.  Fork dự án này.
2.  Tạo một branch mới cho tính năng của bạn (`git checkout -b feature/NewFeature`).
3.  Commit các thay đổi của bạn (`git commit -m 'Add some NewFeature'`).
4.  Push branch của bạn lên (`git push origin feature/NewFeature`).
5.  Mở một Pull Request.

## 📄 Giấy phép

Dự án này được cấp phép theo Giấy phép MIT.