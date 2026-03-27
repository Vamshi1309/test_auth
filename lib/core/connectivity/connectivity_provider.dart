// lib/core/connectivity/connectivity_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
class ConnectivityStatus extends _$ConnectivityStatus {
  @override
  Stream<bool> build() {
    return Connectivity().onConnectivityChanged.map(
          // ignore: unrelated_type_equality_checks
          (result) => result != ConnectivityResult.none,
        );
  }

  // Sync check (optional, but useful)
  Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return result != ConnectivityResult.none;
  }
}
