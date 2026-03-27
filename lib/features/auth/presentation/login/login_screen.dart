import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/core/common_widgets/app_button.dart';
import 'package:pod/core/common_widgets/app_text_field.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:pod/features/auth/providers/auth_provider.dart';
import 'package:pod/features/auth/providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final Map<String, String?> _fieldErrors = {'email': null, 'password': null};

  int selectedIndex = 0;

  void _handleBackendError(String msg) {
    setState(() {
      _fieldErrors['email'] = null;
      _fieldErrors['password'] = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Enter a valid name';
    return null;
  }

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(msg),
        ],
      ),
      backgroundColor: Colors.green[700],
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#\$&*~%^]'))) {
      return 'Must contain at least one special character';
    }
    return null;
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (message) {
          if (selectedIndex == 1) {
            _showSuccessSnackbar(message ?? 'Account created successfully!');
            nameController.clear();
            emailController.clear();
            passwordController.clear();
            setState(() => selectedIndex = 0);
          } else {
            _showSuccessSnackbar(message ?? 'Welcome back!');
            context.go(Routes.home);
          }
        },
        error: (message) => _handleBackendError(message),
      );
    });

    isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/logo.png',
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 15),
                  Text(
                    "FinVault",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 37,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 194, 231, 203),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      segmentedController(),
                      SizedBox(height: 30),
                      if (selectedIndex == 0) ...[
                        _buildLoginForm()
                      ] else ...[
                        _buildRegisterForm()
                      ]
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Start managing your wealth today",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            AppTextField(
              labelText: "Full Name",
              hintText: "your name",
              controller: nameController,
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            SizedBox(height: 20),
            AppTextField(
              labelText: "Email",
              hintText: "e.g. example@gmail.com",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              errorText: _fieldErrors['email'],
              onChanged: (_) => setState(() => _fieldErrors['email'] = null),
            ),
            SizedBox(height: 20),
            AppTextField(
              labelText: "Password",
              hintText: "Enter your password",
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              errorText: _fieldErrors['password'],
              onChanged: (_) => setState(() => _fieldErrors['password'] = null),
            ),
            SizedBox(height: 30),
            AppButton(
              text: "Create Account",
              isLoading: isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                await ref.read(authNotifierProvider.notifier).register(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Securely access your financial portfolio",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            AppTextField(
              labelText: "Email",
              hintText: "e.g. example@gmail.com",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              errorText: _fieldErrors['email'],
              onChanged: (_) => setState(() => _fieldErrors['email'] = null),
            ),
            SizedBox(height: 20),
            AppTextField(
              labelText: "Password",
              hintText: "Enter your password",
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              errorText: _fieldErrors['password'],
              onChanged: (_) => setState(() => _fieldErrors['password'] = null),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    context.go(Routes.forgotPassword);
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green),
                  )),
            ),
            SizedBox(height: 30),
            AppButton(
              text: "Login",
              isLoading: isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                await ref.read(authNotifierProvider.notifier).login(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget segmentedController() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          buildItem("Sign In", 0),
          buildItem("Register", 1),
        ],
      ),
    );
  }

  Widget buildItem(String title, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
        child: GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    ));
  }
}
