// Abstract base class for all authentication states
abstract class AuthState {
  const AuthState();
}

// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

// State when authentication is in progress (loading)
class AuthLoadInProgress extends AuthState {
  const AuthLoadInProgress();

  @override
  String toString() => 'AuthLoadInProgress()';
}

// State when authentication is successful
class AuthSuccess extends AuthState {
  const AuthSuccess();

  @override
  String toString() => 'AuthSuccess()';
}

// State when authentication fails
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({
    required this.error,
  });

  @override
  String toString() => 'AuthFailure(error: $error)';
} 