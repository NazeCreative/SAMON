# SAMON - Ứng dụng Quản lý Chi tiêu

Ứng dụng quản lý chi tiêu đa nền tảng được phát triển bằng Flutter.

## Cấu trúc Dự án Hiện Tại

```
project_s/
├── android/              # [PLATFORM] Mã nguồn Android
├── web/                  # [PLATFORM] Mã nguồn Web
├── windows/              # [PLATFORM] Mã nguồn Windows
├── build/                # [BUILD] Thư mục build được tạo tự động
├── .dart_tool/           # [TOOL] Thư mục cache của Dart
│
├── lib/                  # [CORE] Mã nguồn chính của ứng dụng
│   ├── main.dart         # Điểm khởi chạy ứng dụng
│   ├── firebase_options.dart # Cấu hình Firebase
│   │
│   ├── core/             # [CHUNG] Các thành phần cốt lõi, dùng chung toàn ứng dụng
│   │   ├── services/     # Kết nối tới các dịch vụ bên ngoài
│   │   │   ├── firebase_service.dart
│   │   │   └── cloudinary_service.dart
│   │   ├── utils/        # Các hàm tiện ích (validators, formatters...)
│   │   │   └── formatter.dart
│   │   └── theme/        # Cấu hình giao diện (màu sắc, font chữ...)
│   │       └── app_theme.dart
│   │
│   ├── data/             # [DATA LAYER] Quản lý dữ liệu và logic nghiệp vụ
│   │   ├── models/       # Định nghĩa các đối tượng dữ liệu
│   │   │   ├── transaction_model.dart
│   │   │   ├── category_model.dart
│   │   │   └── wallet_model.dart
│   │   └── repositories/ # Nơi xử lý logic lấy/ghi dữ liệu từ các nguồn
│   │       ├── auth_repository.dart
│   │       ├── category_repository.dart
│   │       ├── transaction_repository.dart
│   │       └── wallet_repository.dart
│   │
│   ├── logic/            # [BUSINESS LOGIC] Quản lý logic nghiệp vụ (BLoC)
│   │   └── blocs/        # ⚠️ Cần tái cấu trúc
│   │       ├── blocs.dart
│   │       ├── category/
│   │       │   ├── category_bloc.dart
│   │       │   ├── category_event.dart
│   │       │   └── category_state.dart
│   │       └── transaction/
│   │           ├── transaction_bloc.dart
│   │           ├── transaction_event.dart
│   │           └── transaction_state.dart
│   │
│   ├── presentation/     # [PRESENTATION LAYER] Giao diện và BLoC
│   │   ├── bloc/         # ⚠️ Trùng lặp với logic/blocs
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── summary/
│   │   │   │   └── summary_bloc.dart
│   │   │   ├── transaction/
│   │   │   │   └── transaction_bloc.dart
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
│   ├── screens/          # [SCREENS] Các màn hình chức năng
│   │   ├── account.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── bar_chart_page.dart
│   │   └── home_screen.dart
│   │
│   └── wallet_screens/   # [WALLET SCREENS] Các màn hình liên quan đến ví
│       ├── add_wallet_screen.dart
│       ├── edit_wallet_screen.dart
│       └── wallet_screen.dart
│
├── assets/               # [ASSETS] Chứa các tài nguyên tĩnh
│   ├── images/
│   │   └── Samon_logo.png
│   └── fonts/
│       ├── Inter-regular.ttf
│       └── Slackey-regular.ttf
│
├── .gitignore            # Khai báo các file/thư mục mà Git sẽ bỏ qua
├── analysis_options.yaml # Cấu hình các quy tắc phân tích code (linter)
├── pubspec.yaml          # File quản lý các gói phụ thuộc và assets
├── pubspec.lock          # File khóa phiên bản dependencies
├── DATA_LAYER_SUMMARY.md # Tài liệu tóm tắt data layer
├── FIRESTORE_INDEXES.md  # Tài liệu về Firestore indexes
└── TROUBLESHOOTING.md    # Hướng dẫn xử lý sự cố
```

## 🚨 Vấn đề Hiện Tại

Cấu trúc hiện tại có một số vấn đề:

1. **Trùng lặp BLoC**: BLoCs được đặt ở hai nơi khác nhau (`logic/blocs/` và `presentation/bloc/`)
2. **Không nhất quán**: Một số BLoCs ở `logic/`, một số ở `presentation/`
3. **Khó bảo trì**: Cấu trúc không rõ ràng, khó tìm kiếm và bảo trì

## 📋 Đề xuất Cấu trúc Mới (Clean Architecture + BLoC)

```
project_s/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── core/                    # [CORE] Shared utilities và services
│   │   ├── constants/           # Hằng số toàn cục
│   │   │   ├── app_constants.dart
│   │   │   └── api_constants.dart
│   │   ├── errors/              # Error handling
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── services/            # External services
│   │   │   ├── firebase_service.dart
│   │   │   └── cloudinary_service.dart
│   │   ├── theme/               # App theming
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   ├── utils/               # Utility functions
│   │   │   ├── formatter.dart
│   │   │   ├── validators.dart
│   │   │   └── extensions.dart
│   │   └── network/             # Network utilities
│   │       ├── network_info.dart
│   │       └── api_client.dart
│   │
│   ├── features/                # [FEATURES] Organized by business features
│   │   ├── auth/                # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── register_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── signup_page.dart
│   │   │       │   └── welcome_page.dart
│   │   │       └── widgets/
│   │   │           ├── auth_form.dart
│   │   │           └── auth_button.dart
│   │   │
│   │   ├── wallet/              # Wallet management feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── wallet_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── wallet_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── wallet_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── wallet.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── wallet_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_wallet_usecase.dart
│   │   │   │       ├── get_wallets_usecase.dart
│   │   │   │       └── update_wallet_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── wallet_bloc.dart
│   │   │       │   ├── wallet_event.dart
│   │   │       │   └── wallet_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── wallet_screen.dart
│   │   │       │   ├── add_wallet_screen.dart
│   │   │       │   └── edit_wallet_screen.dart
│   │   │       └── widgets/
│   │   │           ├── wallet_card.dart
│   │   │           └── wallet_form.dart
│   │   │
│   │   ├── transaction/         # Transaction management feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── transaction_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── transaction_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── transaction_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── transaction.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── transaction_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── add_transaction_usecase.dart
│   │   │   │       ├── get_transactions_usecase.dart
│   │   │   │       └── delete_transaction_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── transaction_bloc.dart
│   │   │       │   ├── transaction_event.dart
│   │   │       │   └── transaction_state.dart
│   │   │       ├── pages/
│   │   │       │   └── add_transaction_screen.dart
│   │   │       └── widgets/
│   │   │           ├── transaction_list_item.dart
│   │   │           └── transaction_form.dart
│   │   │
│   │   ├── category/            # Category management feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── category_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── category_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── category_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── category.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── category_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_categories_usecase.dart
│   │   │   │       ├── add_category_usecase.dart
│   │   │   │       └── delete_category_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── category_bloc.dart
│   │   │       │   ├── category_event.dart
│   │   │       │   └── category_state.dart
│   │   │       ├── pages/
│   │   │       │   └── category_screen.dart
│   │   │       └── widgets/
│   │   │           └── category_item.dart
│   │   │
│   │   ├── dashboard/           # Dashboard/Home feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── dashboard_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── dashboard_summary_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── dashboard_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── dashboard_summary.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── dashboard_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       └── get_dashboard_summary_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── dashboard_bloc.dart
│   │   │       │   ├── dashboard_event.dart
│   │   │       │   └── dashboard_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── home_screen.dart
│   │   │       │   ├── account.dart
│   │   │       │   └── bar_chart_page.dart
│   │   │       └── widgets/
│   │   │           ├── summary_card.dart
│   │   │           └── chart_widget.dart
│   │   │
│   │   └── shared/              # Shared UI components
│   │       ├── widgets/
│   │       │   ├── custom_button.dart
│   │       │   ├── bot_nav_bar.dart
│   │       │   └── loading_indicator.dart
│   │       └── pages/
│   │           └── splash_page.dart
│   │
│   └── injection_container.dart # Dependency injection setup
│
├── assets/                      # Static assets
│   ├── images/
│   │   └── Samon_logo.png
│   └── fonts/
│       ├── Inter-regular.ttf
│       └── Slackey-regular.ttf
│
├── test/                        # Unit và integration tests
│   ├── features/
│   │   ├── auth/
│   │   ├── wallet/
│   │   └── transaction/
│   └── helpers/
│       └── test_helper.dart
│
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── DATA_LAYER_SUMMARY.md
├── FIRESTORE_INDEXES.md
└── TROUBLESHOOTING.md
```

## 🎯 Lợi ích của Cấu trúc Mới

### 1. **Clean Architecture**
- **Separation of Concerns**: Tách biệt rõ ràng data, domain, và presentation layers
- **Dependency Inversion**: Dependencies chảy từ ngoài vào trong, domain layer không phụ thuộc vào implementation details
- **Testability**: Dễ dàng unit test từng layer độc lập

### 2. **Feature-Based Organization**
- **Modularity**: Mỗi feature tự chứa với data, domain, và presentation
- **Scalability**: Dễ dàng thêm features mới mà không ảnh hưởng đến code hiện tại
- **Team Collaboration**: Nhiều developer có thể làm việc trên các features khác nhau

### 3. **BLoC Pattern Best Practices**
- **Centralized State Management**: Tất cả BLoCs được tổ chức theo feature
- **Clear Event-State Flow**: Mỗi BLoC có events và states rõ ràng
- **Testable Business Logic**: BLoCs có thể được test độc lập

### 4. **Improved Code Organization**
- **Consistent Structure**: Tất cả features follow cùng một pattern
- **Easy Navigation**: Developers dễ dàng tìm thấy code cần thiết
- **Reduced Coupling**: Features ít phụ thuộc vào nhau

## 🔧 Kế hoạch Migration

### Phase 1: Tái cấu trúc BLoCs
1. Tạo folder structure mới theo features
2. Di chuyển các BLoCs từ `logic/blocs/` và `presentation/bloc/` vào structure mới
3. Cập nhật imports trong main.dart và các files liên quan

### Phase 2: Tách Domain Layer
1. Tạo entities và repositories interfaces
2. Tạo use cases cho mỗi business operation
3. Refactor repositories để implement interfaces

### Phase 3: Tái cấu trúc Presentation
1. Di chuyển screens vào các features tương ứng
2. Tái cấu trúc widgets theo features
3. Cập nhật routing và navigation

### Phase 4: Testing và Documentation
1. Thêm unit tests cho mỗi layer
2. Cập nhật documentation
3. Code review và optimization

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
