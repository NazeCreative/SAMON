
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

class AuthLoadInProgress extends AuthState {
  const AuthLoadInProgress();

  @override
  String toString() => 'AuthLoadInProgress()';
}

class AuthSuccess extends AuthState {
  const AuthSuccess();

  @override
  String toString() => 'AuthSuccess()';
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();

  @override
  String toString() => 'PasswordResetEmailSent()';
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  
  const AuthAuthenticated({
    required this.userId,
    required this.email,
  });

  @override
  String toString() => 'AuthAuthenticated(userId: $userId, email: $email)';
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({
    required this.error,
  });

  @override
  String toString() => 'AuthFailure(error: $error)';
} 