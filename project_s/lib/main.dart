import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'presentation/auth/welcome_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/signup_page.dart';
import 'widgets/bot_nav_bar.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/category/category_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseAuth>(
          create: (context) => FirebaseAuth.instance,
        ),
        RepositoryProvider<FirebaseFirestore>(
          create: (context) => FirebaseFirestore.instance,
        ),
        
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseAuth: context.read<FirebaseAuth>(),
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),
        RepositoryProvider<WalletRepository>(
          create: (context) => WalletRepository(
            firestore: context.read<FirebaseFirestore>(),
            firebaseAuth: context.read<FirebaseAuth>(),
          ),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(
            firestore: context.read<FirebaseFirestore>(),
            firebaseAuth: context.read<FirebaseAuth>(),
          ),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepository(
            firestore: context.read<FirebaseFirestore>(),
            firebaseAuth: context.read<FirebaseAuth>(),
            walletRepository: context.read<WalletRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<WalletBloc>(
            create: (context) => WalletBloc(
              walletRepository: context.read<WalletRepository>(),
            ),
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => TransactionBloc(
              transactionRepository: context.read<TransactionRepository>(),
            ),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'SAMON',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => Bottom(),
          },
        ),
      ),
    );
  }
}
