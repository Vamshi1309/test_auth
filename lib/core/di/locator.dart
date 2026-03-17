// lib/core/di/locator.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locator.g.dart';

// Global Navigator Key – used by go_router
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Global ScaffoldMessenger Key – OFFICIAL WAY (2025+)
final scaffoldMessengerKeyProvider =
    Provider((ref) => GlobalKey<ScaffoldMessengerState>());

@riverpod
void registerCoreProviders(RegisterCoreProvidersRef ref) {
  // Optional: ensures providers are initialized
}
