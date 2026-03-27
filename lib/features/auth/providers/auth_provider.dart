import 'package:pod/core/error/failures.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/data/models/auth_request.dart';
import 'package:pod/features/auth/data/repository/auth_repository.dart';
import 'package:pod/features/auth/providers/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  AuthState build() => const AuthState.initial();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> checkAuth() async {
    state = const AuthState.loading();

    // Read SharedPrefs directly — no need to go through repo
    final prefs = await ref.read(sharedPrefsProvider.future);
    final loggedIn = await prefs.isLoggedIn();

    state = loggedIn
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final message =
          await _repo.login(LoginRequest(email: email, password: password));
      state = AuthState.authenticated(message: message);
    } on Failure catch (f) {
      state = AuthState.error(_toMessage(f));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final message = await _repo.register(
        RegisterRequest(name: name, email: email, password: password),
      );
      state = AuthState.authenticated(message: message); // ← was missing!
    } on Failure catch (f) {
      state = AuthState.error(_toMessage(f));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = const AuthState.loading();

    try {
      await _repo.forgotPassword(email);
      state = const AuthState.passwordResetSent();
    } on Failure catch (f) {
      state = AuthState.error(_toMessage(f));
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _repo.logout();
    state = const AuthState.unauthenticated();
    // GoRouter redirect sees unauthenticated → sends to login
  }

  String _toMessage(Failure f) => switch (f) {
        // Prefer backend message (e.g. "Invalid credentials") for 401s.
        // UI can still map it to a specific field if desired.
        UnauthorizedFailure() => f.message,
        ValidationFailure() => f.message,
        NetworkFailure() => 'No internet connection',
        ServerFailure() => f.message,
        NotFoundFailure() => f.message,
        UnknownFailure() => 'Something went wrong',
      };
}
