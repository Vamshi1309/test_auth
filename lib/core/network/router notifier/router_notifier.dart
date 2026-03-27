import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/features/auth/providers/auth_provider.dart';
import 'package:pod/core/network/dio_provider.dart';

part 'router_notifier.g.dart';

@riverpod
class RouterNotifier extends _$RouterNotifier with ChangeNotifier {
  @override
  RouterNotifier build() {
    // listen to auth state changes
    ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });

    // listen to force logout (401 case)
    ref.listen(forceLogoutProvider, (_, __) {
      notifyListeners();
    });

    return this;
  }
}
