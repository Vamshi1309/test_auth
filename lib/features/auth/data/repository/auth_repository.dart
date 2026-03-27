import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/network/api_service_provider.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/data/models/auth_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(api: ref.read(apiServiceProvider.notifier), ref: ref);
}

class AuthRepository {
  final ApiService _api;
  final Ref _ref;

  const AuthRepository({required ApiService api, required Ref ref})
      : _api = api,
        _ref = ref;

  Future<String> login(LoginRequest req) async {
    await _api.post(
      AppConfig.login,
      data: req.toJson(),
      fromJsonT: (_) => true,
    );

    final prefs = await _ref.read(sharedPrefsProvider.future);
    await prefs.setLoggedIn(true);

    return 'Welcome back!';
  }

  Future<String> register(RegisterRequest req) async {
    await _api.post(
      AppConfig.register,
      data: req.toJson(),
      fromJsonT: (_) => true,
    );

    final prefs = await _ref.read(sharedPrefsProvider.future);
    await prefs.setLoggedIn(true);

    return 'Account created successfully!';
  }

  Future<void> forgotPassword(String email) async {
    await _api.post(
      AppConfig.forgotPassword,
      data: {'email': email},
      fromJsonT: (_) => true,
    );
  }

  Future<void> logout() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    await prefs.clearAuth();
    await prefs.setLoggedIn(false);
    try {
      await _api.post(
        AppConfig.logout,
        fromJsonT: (_) {},
      );
    } catch (_) {
      // Intentionally ignored — server logout failure is non-critical
    }
  }
}
