import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/core/common_widgets/app_button.dart';
import 'package:pod/core/common_widgets/app_text_field.dart';
import 'package:pod/features/auth/providers/auth_provider.dart';
import 'package:pod/features/auth/providers/auth_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        passwordResetSent: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reset link sent successfully")),
          );
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              /// Logo + Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.account_balance, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "FinVault",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const Spacer(),

              /// Title
              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              const Text(
                "Enter the email address associated with your account to receive a reset link.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// Email Label
              const Text(
                "Email Address",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              /// Email Field
              AppTextField(
                controller: emailController,
                hintText: "alex@example.com",
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: _validateEmail,
                enabled: !isLoading,
              ),

              const SizedBox(height: 30),

              /// Button
              AppButton(
                text: "Send Reset Link",
                isLoading: isLoading,
                isEnabled: !isLoading,
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final email = emailController.text.trim();
                  await ref
                      .read(authNotifierProvider.notifier)
                      .forgotPassword(email: email);
                },
              ),

              const Spacer(flex: 2),

              /// Bottom Text
              Center(
                child: GestureDetector(
                  onTap: isLoading ? null : () => context.go('/login'),
                  child: RichText(
                    text: const TextSpan(
                      text: "Remember your password? ",
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
