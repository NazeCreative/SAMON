# SAMON - Ứng dụng Quản lý Chi tiêu

Ứng dụng quản lý chi tiêu đa nền tảng được phát triển bằng Flutter.

## Cấu trúc Dự án

```
project_s/
├── android/              # [PLATFORM] Mã nguồn Android
├── web/                  # [PLATFORM] Mã nguồn Web
├── build/                # [BUILD] Thư mục build được tạo tự động
├── .dart_tool/           # [TOOL] Thư mục cache của Dart
│
├── lib/                  # [CORE] Mã nguồn chính của ứng dụng
│   ├── main.dart         # Điểm khởi chạy ứng dụng
│   ├── firebase_options.dart # Cấu hình Firebase
│   │
│   ├── core/             # [CHUNG] Các thành phần cốt lõi, dùng chung toàn ứng dụng
│   │   ├── services/     # Kết nối tới các dịch vụ bên ngoài (Firebase, API...)
│   │   │   └── firebase_service.dart
│   │   ├── utils/        # Các hàm tiện ích (validators, formatters...)
│   │   │   └── formatter.dart
│   │   └── theme/        # Cấu hình giao diện (màu sắc, font chữ...)
│   │       └── app_theme.dart
│   │
│   ├── data/             # [BE & FE LOGIC] Quản lý dữ liệu và logic nghiệp vụ
│   │   ├── models/       # Định nghĩa các đối tượng dữ liệu
│   │   │   ├── transaction_model.dart
│   │   │   ├── category_model.dart
│   │   │   └── wallet_model.dart
│   │   └── repositories/ # Nơi xử lý logic lấy/ghi dữ liệu từ các nguồn (API, DB)
│   │       ├── auth_repository.dart
│   │       ├── category_repository.dart
│   │       ├── transaction_repository.dart
│   │       └── wallet_repository.dart
│   │
│   ├── presentation/     # [FE UI & FE LOGIC] Quản lý giao diện và trạng thái
│   │   ├── bloc/         # Quản lý state (Business Logic Component)
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── transaction/
│   │   │   │   └── transaction_bloc.dart
│   │   │   ├── summary/
│   │   │   │   └── summary_bloc.dart
│   │   │   └── wallet/
│   │   │       ├── wallet_bloc.dart
│   │   │       ├── wallet_event.dart
│   │   │       └── wallet_state.dart
│   │   ├── pages/        # Các màn hình hoàn chỉnh của ứng dụng
│   │   │   ├── login_page.dart
│   │   │   ├── signup_page.dart
│   │   │   └── welcome_page.dart
│   │   └── widgets/      # Các thành phần giao diện nhỏ, có thể tái sử dụng
│   │       ├── bot_nav_bar.dart
│   │       ├── custom_button.dart
│   │       └── transaction_list_item.dart
│   │
│   ├── screens/          # Các màn hình chức năng
│   │   ├── account.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── bar_chart_page.dart
│   │   └── home_screen.dart
│   │
│   └── wallet_screens/   # Các màn hình liên quan đến ví
│       ├── add_wallet_screen.dart
│       ├── edit_wallet_screen.dart
│       └── wallet_screen.dart
│
├── assets/               # [DESIGNER] Chứa các tài nguyên tĩnh
│   ├── images/
│   │   └── Samon_logo.png
│   └── fonts/
│       ├── Inter-regular.ttf
│       └── Slackey-regular.ttf
│
├── .gitignore            # Khai báo các file/thư mục mà Git sẽ bỏ qua
├── analysis_options.yaml # Cấu hình các quy tắc phân tích code (linter)
├── firestore.rules       # Quy tắc bảo mật Firestore
├── pubspec.yaml          # File quản lý các gói phụ thuộc (dependencies) và assets
├── pubspec.lock          # File khóa phiên bản dependencies
├── .flutter-plugins-dependencies # Cấu hình plugin Flutter
├── .metadata             # Metadata của dự án Flutter
└── TROUBLESHOOTING.md    # Hướng dẫn xử lý sự cố
```

## Yêu cầu Hệ thống

- Flutter SDK (phiên bản mới nhất)
- Dart SDK (phiên bản mới nhất)
- Android Studio / VS Code với Flutter plugin
- Git

## Cài đặt và Chạy

1. Clone repository:
```bash
git clone https://github.com/your-username/SAMON.git
cd SAMON
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc và Quy ước

- **Clean Architecture**: Dự án tuân theo nguyên tắc Clean Architecture
- **BLoC Pattern**: Sử dụng BLoC để quản lý state
- **Repository Pattern**: Tách biệt logic truy cập dữ liệu
- **Widget Reusability**: Tối ưu việc tái sử dụng các widget

## Đóng góp

1. Fork dự án
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## Giấy phép

Dự án này được cấp phép theo MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.
