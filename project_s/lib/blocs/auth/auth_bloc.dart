import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    try {
      print('AuthBloc: Starting sign in process for email: ${event.email}');
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      print('AuthBloc: Sign in successful, emitting AuthSuccess');
      if (user != null) {
        print('AuthBloc: User is not null, emitting AuthAuthenticated with userId: ${user.uid}');
        emit(AuthAuthenticated(userId: user.uid, email: user.email ?? ''));
      } else {
        print('AuthBloc: User is null, emitting AuthSuccess');
        emit(const AuthSuccess());
      }
    } catch (e) {
      print('AuthBloc: Sign in failed with error: $e');
      String errorMessage = 'Đăng nhập thất bại';
      
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e.toString().contains('FirebaseAuthException')) {
        errorMessage = 'Lỗi xác thực Firebase';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng';
      }
      
      emit(AuthFailure(error: errorMessage));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    try {
      await _authRepository.signOut();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(AuthAuthenticated(
        userId: currentUser.uid,
        email: currentUser.email ?? '',
      ));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadInProgress());
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(const PasswordResetEmailSent());
    } catch (e) {
      String errorMessage = 'Gửi email đặt lại mật khẩu thất bại';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      emit(AuthFailure(error: errorMessage));
    }
  }
}