import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/common_widgets/app_button.dart';
import 'package:pod/features/auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F4EA), // light green
              Color(0xFFF8FBF9), // near white
              Colors.white,
            ]),
      ),
      child: Center(
        child: AppButton(
          text: "Log Out",
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            // no manual context.go needed
            // logout() sets state = unauthenticated
            // router auto-navigates to login ✅
          },
        ),
      ),
    ));
  }
}
