// Abstract base class for all authentication events
abstract class AuthEvent {
  const AuthEvent();
}

// Event for user sign up request
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  String toString() => 'SignUpRequested(email: $email, displayName: $displayName)';
}

// Event for user sign in request
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  String toString() => 'SignInRequested(email: $email)';
}

// Event for user sign out request
class SignOutRequested extends AuthEvent {
  const SignOutRequested();

  @override
  String toString() => 'SignOutRequested()';
}

// Event to check current authentication status
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();

  @override
  String toString() => 'AuthStatusChecked()';
}

// Event for forgot password (send reset email)
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  String toString() => 'ForgotPasswordRequested(email: $email)';
} 