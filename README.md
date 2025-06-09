# SAMON
App quản lí chi tiêu 

project_s/
├── android/              
├── ios/                   
├── web/                   
├── macos/
├── windows/   
├── linux/                
│
├── lib/                  
│   ├── main.dart         # Điểm khởi chạy ứng dụng
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
│   │   ├── models/       # Định nghĩa các đối tượng dữ liệu (Transaction, User...)
│   │   │   └── transaction_model.dart
│   │   └── repositories/ # Nơi xử lý logic lấy/ghi dữ liệu từ các nguồn (API, DB)
│   │       └── transaction_repository.dart
│   │
│   └── presentation/     # [FE UI & FE LOGIC] Quản lý giao diện và trạng thái
│       ├── bloc/         # Quản lý state (Business Logic Component)
│       │   ├── transaction/
│       │   │   └── transaction_bloc.dart
│       │   └── summary/
│       │       └── summary_bloc.dart
│       │
│       ├── pages/        # Các màn hình hoàn chỉnh của ứng dụng
│       │   ├── home_page.dart
│       │   ├── add_transaction_page.dart
│       │   └── report_page.dart
│       │
│       └── widgets/      # Các thành phần giao diện nhỏ, có thể tái sử dụng
│           ├── custom_button.dart
│           └── transaction_list_item.dart
│
├── assets/               # [DESIGNER] Chứa các tài nguyên tĩnh
│   ├── images/
│   │   └── logo.png
│   └── fonts/
│
├── test/                 # [TESTER] Chứa code cho việc kiểm thử tự động
│   ├── bloc_test/
│   └── widget_test/
│
├── .gitignore            # Khai báo các file/thư mục mà Git sẽ bỏ qua
├── analysis_options.yaml # Cấu hình các quy tắc phân tích code (linter)
├── pubspec.yaml          # File quản lý các gói phụ thuộc (dependencies) và assets
└── README.md             # File giới thiệu và tài liệu về dự án
