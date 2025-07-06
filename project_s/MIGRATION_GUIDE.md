# 🔄 Migration Guide: BLoC Library Architecture

Hướng dẫn chi tiết để migration từ cấu trúc hiện tại sang BLoC library architecture với 3 layers chính.

## 🏗️ BLoC Library Architecture Overview

The BLoC library architecture separates the application into **3 distinct layers**:

```
┌─────────────────────────────────────────────────────────────┐
│                    BLoC Library Architecture                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │                View Layer                           │   │
│  │  • main.dart                                       │   │
│  │  • Pages                                           │   │
│  │  • Widgets                                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              BLoC Layer                             │   │
│  │  • Business Logic Components                        │   │
│  │  • State Management                                 │   │
│  │  • Event Handling                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Data Layer                             │   │
│  │  • Repository Pattern                               │   │
│  │  • Data Provider                                    │   │
│  │  • Models                                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities:

#### 1. **View Layer** (Presentation)
- **main.dart**: Application entry point
- **Pages**: Complete screens of the application
- **Widgets**: Reusable UI components

#### 2. **BLoC Layer** (Business Logic)
- **Business Logic Components**: Handle application logic
- **State Management**: Manage application state
- **Event Handling**: Process user interactions and data events

#### 3. **Data Layer**
- **Repository**: Abstract data access layer
- **Data Provider**: Concrete data source implementations
- **Models**: Data structures and transformations

### Benefits of This Architecture:
- ✅ **Clear Separation**: Each layer has a specific responsibility
- ✅ **Testability**: Easy to mock and test each layer independently
- ✅ **Maintainability**: Changes in one layer don't affect others
- ✅ **Scalability**: Easy to add new features following the same pattern
- ✅ **BLoC Best Practices**: Follows official BLoC library recommendations

## 📋 Checklist Migration

### Phase 1: Tái cấu trúc theo BLoC Library Architecture ✅
- [ ] Tạo folder structure mới với 3 layers: bloc, data, view
- [ ] Di chuyển AuthBloc từ `presentation/bloc/auth/` → `lib/bloc/auth/`
- [ ] Di chuyển WalletBloc từ `presentation/bloc/wallet/` → `lib/bloc/wallet/`
- [ ] Di chuyển TransactionBloc từ `logic/blocs/transaction/` → `lib/bloc/transaction/`
- [ ] Di chuyển CategoryBloc từ `logic/blocs/category/` → `lib/bloc/category/`
- [ ] Tạo DashboardBloc mới từ `presentation/bloc/summary/` → `lib/bloc/dashboard/`
- [ ] Cập nhật imports trong main.dart
- [ ] Xóa các folder cũ sau khi migration xong

### Phase 2: Tái cấu trúc Data Layer ✅
- [ ] Tạo repository layer cho mỗi feature
- [ ] Tạo data provider layer cho mỗi feature
- [ ] Refactor repositories để implement data providers
- [ ] Cập nhật BLoCs để sử dụng repositories

### Phase 3: Tái cấu trúc View Layer ✅
- [ ] Di chuyển screens vào view layer
- [ ] Tái cấu trúc widgets theo features
- [ ] Cập nhật routing và navigation

### Phase 4: Testing và Documentation ✅
- [ ] Thêm unit tests cho từng layer
- [ ] Cập nhật documentation
- [ ] Code review

## 🚀 Bước 1: Tạo Folder Structure theo BLoC Library

```bash
# Tạo 3 layers chính theo BLoC library architecture
mkdir -p lib/bloc/{auth,wallet,transaction,category,dashboard}
mkdir -p lib/data/{repositories,providers,models}
mkdir -p lib/view/{pages,widgets,shared}

# Tạo subdirectories cho từng layer
for feature in auth wallet transaction category dashboard; do
    mkdir -p lib/bloc/$feature
    mkdir -p lib/data/repositories/$feature
    mkdir -p lib/data/providers/$feature
    mkdir -p lib/data/models/$feature
    mkdir -p lib/view/pages/$feature
    mkdir -p lib/view/widgets/$feature
done

# Tạo shared directories
mkdir -p lib/view/shared/{widgets,pages}
mkdir -p lib/data/models/shared

# Tạo test directories
mkdir -p test/bloc/{auth,wallet,transaction,category,dashboard}
mkdir -p test/data/{repositories,providers}
mkdir -p test/view/{pages,widgets}
mkdir -p test/helpers
```

## 🎯 Bước 2: Migration theo BLoC Library Architecture

### 2.1 Auth Feature

#### 2.1.1 Tạo Data Models
```dart
// lib/data/models/auth/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImage: data['profileImage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

#### 2.1.2 Tạo Data Provider
```dart
// lib/data/providers/auth/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/auth/user_model.dart';

class AuthProvider {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthProvider({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      return UserModel.fromFirestore(doc);
    }
    
    throw Exception('Sign in failed');
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(
        userModel.toFirestore(),
      );

      return userModel;
    }

    throw Exception('Sign up failed');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
```

#### 2.1.3 Tạo Repository
```dart
// lib/data/repositories/auth/auth_repository.dart
import '../../models/auth/user_model.dart';
import '../../providers/auth/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;

  AuthRepository({required AuthProvider authProvider})
      : _authProvider = authProvider;

  Future<UserModel?> getCurrentUser() {
    return _authProvider.getCurrentUser();
  }

  Future<UserModel> signIn({required String email, required String password}) {
    return _authProvider.signIn(email: email, password: password);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _authProvider.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<void> signOut() {
    return _authProvider.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authProvider.sendPasswordResetEmail(email: email);
  }
}
```

#### 2.1.4 Di chuyển BLoC
```bash
# Di chuyển auth bloc
mv lib/presentation/bloc/auth/* lib/bloc/auth/
```

#### 2.1.5 Di chuyển View Pages
```bash
# Di chuyển auth pages
mv lib/presentation/pages/login_page.dart lib/view/pages/auth/
mv lib/presentation/pages/signup_page.dart lib/view/pages/auth/
mv lib/presentation/pages/welcome_page.dart lib/view/pages/auth/
```

### 2.2 Wallet Feature

#### 2.2.1 Tạo Data Models
```dart
// lib/data/models/wallet/wallet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'VND',
      icon: data['icon'],
      color: data['color'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

#### 2.2.2 Tạo Data Provider
```dart
// lib/data/providers/wallet/wallet_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/wallet/wallet_model.dart';

class WalletProvider {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  WalletProvider({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  Future<List<WalletModel>> getWallets() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .get();

    return querySnapshot.docs
        .map((doc) => WalletModel.fromFirestore(doc))
        .toList();
  }

  Future<WalletModel> createWallet(WalletModel wallet) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .add(wallet.toFirestore());

    return WalletModel(
      id: docRef.id,
      name: wallet.name,
      balance: wallet.balance,
      currency: wallet.currency,
      icon: wallet.icon,
      color: wallet.color,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(wallet.id)
        .update(wallet.toFirestore());
  }

  Future<void> deleteWallet(String walletId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(walletId)
        .delete();
  }
}
```

#### 2.2.3 Tạo Repository
```dart
// lib/data/repositories/wallet/wallet_repository.dart
import '../../models/wallet/wallet_model.dart';
import '../../providers/wallet/wallet_provider.dart';

class WalletRepository {
  final WalletProvider _walletProvider;

  WalletRepository({required WalletProvider walletProvider})
      : _walletProvider = walletProvider;

  Future<List<WalletModel>> getWallets() {
    return _walletProvider.getWallets();
  }

  Future<WalletModel> createWallet(WalletModel wallet) {
    return _walletProvider.createWallet(wallet);
  }

  Future<void> updateWallet(WalletModel wallet) {
    return _walletProvider.updateWallet(wallet);
  }

  Future<void> deleteWallet(String walletId) {
    return _walletProvider.deleteWallet(walletId);
  }
}
```

#### 2.2.4 Di chuyển files
```bash
# Di chuyển wallet bloc
mv lib/presentation/bloc/wallet/* lib/bloc/wallet/

# Di chuyển wallet screens
mv lib/wallet_screens/* lib/view/pages/wallet/
```

### 2.3 Transaction Feature

#### 2.3.1 Di chuyển files
```bash
# Di chuyển transaction bloc
mv lib/logic/blocs/transaction/* lib/bloc/transaction/

# Di chuyển transaction screens
mv lib/screens/add_transaction_screen.dart lib/view/pages/transaction/
```

### 2.4 Category Feature

#### 2.4.1 Di chuyển files
```bash
# Di chuyển category bloc
mv lib/logic/blocs/category/* lib/bloc/category/
```

### 2.5 Dashboard Feature

#### 2.5.1 Di chuyển files
```bash
# Di chuyển dashboard/home screens
mv lib/screens/home_screen.dart lib/view/pages/dashboard/
mv lib/screens/account.dart lib/view/pages/dashboard/
mv lib/screens/bar_chart_page.dart lib/view/pages/dashboard/

# Di chuyển summary bloc
mv lib/presentation/bloc/summary/* lib/bloc/dashboard/
```

### 2.6 Shared Components

#### 2.6.1 Di chuyển shared widgets
```bash
# Di chuyển shared widgets
mv lib/presentation/widgets/* lib/view/shared/widgets/
```

## 🔧 Bước 3: Cập nhật Imports

### 3.1 Cập nhật main.dart
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

// View Layer
import 'view/pages/auth/welcome_page.dart';
import 'view/pages/auth/login_page.dart';
import 'view/pages/auth/signup_page.dart';
import 'view/shared/widgets/bot_nav_bar.dart';

// BLoC Layer
import 'bloc/auth/auth_bloc.dart';
import 'bloc/wallet/wallet_bloc.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/category/category_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<WalletBloc>(create: (context) => di.sl<WalletBloc>()),
        BlocProvider<TransactionBloc>(create: (context) => di.sl<TransactionBloc>()),
        BlocProvider<CategoryBloc>(create: (context) => di.sl<CategoryBloc>()),
        BlocProvider<DashboardBloc>(create: (context) => di.sl<DashboardBloc>()),
      ],
      child: MaterialApp(
        title: 'SAMON',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const Bottom(),
        },
      ),
    );
  }
}
```

### 3.2 Tạo Dependency Injection
```dart
// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Layer
import 'data/providers/auth/auth_provider.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'data/providers/wallet/wallet_provider.dart';
import 'data/repositories/wallet/wallet_repository.dart';

// BLoC Layer
import 'bloc/auth/auth_bloc.dart';
import 'bloc/wallet/wallet_bloc.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/category/category_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data Layer - Providers
  sl.registerLazySingleton(() => AuthProvider(
    firebaseAuth: sl(),
    firestore: sl(),
  ));
  sl.registerLazySingleton(() => WalletProvider(
    firestore: sl(),
    firebaseAuth: sl(),
  ));

  // Data Layer - Repositories
  sl.registerLazySingleton(() => AuthRepository(
    authProvider: sl(),
  ));
  sl.registerLazySingleton(() => WalletRepository(
    walletProvider: sl(),
  ));

  // BLoC Layer
  sl.registerFactory(() => AuthBloc(
    authRepository: sl(),
  ));
  sl.registerFactory(() => WalletBloc(
    walletRepository: sl(),
  ));
  sl.registerFactory(() => TransactionBloc(
    transactionRepository: sl(),
  ));
  sl.registerFactory(() => CategoryBloc(
    categoryRepository: sl(),
  ));
  sl.registerFactory(() => DashboardBloc(
    dashboardRepository: sl(),
  ));
}
```

## 🧪 Bước 4: Thêm Testing

### 4.1 Test Helper
```dart
// test/helpers/test_helper.dart
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
])
void main() {}
```

### 4.2 BLoC Tests
```dart
// test/bloc/auth/auth_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import '../../../../lib/bloc/auth/auth_bloc.dart';
import '../../../../lib/bloc/auth/auth_event.dart';
import '../../../../lib/bloc/auth/auth_state.dart';
import '../../../../lib/data/repositories/auth/auth_repository.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoadInProgress, AuthAuthenticated] when login is successful',
      build: () => authBloc,
      act: (bloc) => bloc.add(const SignInRequested(
        email: 'test@test.com',
        password: 'password',
      )),
      expect: () => [
        const AuthLoadInProgress(),
        const AuthAuthenticated(userId: '1', email: 'test@test.com'),
      ],
    );
  });
}
```

## 🔍 Bước 5: Validation và Testing

### 5.1 Chạy build để kiểm tra lỗi
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
flutter analyze
```

### 5.2 Chạy tests
```bash
flutter test
```

### 5.3 Test trên thiết bị
```bash
flutter run
```

## 📝 Checklist Hoàn thành

### Phase 1: BLoC Library Architecture Migration ✅
- [ ] Tất cả BLoCs đã được di chuyển vào `lib/bloc/`
- [ ] Data layer đã được tổ chức với repositories và providers
- [ ] View layer đã được tổ chức với pages và widgets
- [ ] Imports đã được cập nhật
- [ ] App build thành công
- [ ] Folders cũ đã được xóa

### Phase 2: Data Layer Restructuring ✅
- [ ] Data models đã được tạo trong `lib/data/models/`
- [ ] Data providers đã được tạo trong `lib/data/providers/`
- [ ] Repositories đã được tạo trong `lib/data/repositories/`
- [ ] BLoCs đã được cập nhật để sử dụng repositories

### Phase 3: View Layer Restructuring ✅
- [ ] Pages đã được di chuyển vào `lib/view/pages/`
- [ ] Widgets đã được tổ chức trong `lib/view/widgets/`
- [ ] Shared components đã được di chuyển vào `lib/view/shared/`
- [ ] Routing và navigation hoạt động bình thường

### Phase 4: Testing & Documentation ✅
- [ ] Unit tests đã được thêm cho từng layer
- [ ] BLoC tests đã được tạo
- [ ] Repository tests đã được tạo
- [ ] Documentation đã được cập nhật
- [ ] Code review hoàn thành

## 🎉 Kết quả

Sau khi hoàn thành migration, bạn sẽ có:

1. **BLoC Library Architecture** với 3 layers rõ ràng:
   - **BLoC Layer**: Business Logic Layer
   - **Data Layer**: Repository + Data Provider
   - **View Layer**: Presentation Layer + main.dart

2. **Clear separation of concerns** với mỗi layer có trách nhiệm riêng biệt
3. **Testable code** với dependency injection và mocking
4. **Consistent structure** theo BLoC library best practices
5. **Better maintainability** với cấu trúc đơn giản và dễ hiểu

## 🔄 Rollback Plan

Nếu có vấn đề trong quá trình migration:

1. **Backup**: Tạo git branch trước khi migration
2. **Incremental**: Migration từng feature một
3. **Testing**: Test kỹ lưỡng sau mỗi bước
4. **Documentation**: Ghi chú lại mọi thay đổi

```bash
# Tạo backup branch
git checkout -b backup-before-migration
git checkout -b feature/clean-architecture-migration

# Sau khi migration xong
git add .
git commit -m "feat: migrate to clean architecture with feature-based BLoC structure"
git push origin feature/clean-architecture-migration
``` 