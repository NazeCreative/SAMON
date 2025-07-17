abstract class AuthEvent {
  const AuthEvent();
}

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

class SignOutRequested extends AuthEvent {
  const SignOutRequested();

  @override
  String toString() => 'SignOutRequested()';
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();

  @override
  String toString() => 'AuthStatusChecked()';
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  String toString() => 'ForgotPasswordRequested(email: $email)';
} 