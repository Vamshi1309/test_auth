import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: () => context.go(Routes.home),
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        },
      );
    });

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          if (isLoading)
            Positioned.fill(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              ),
            )),
        ],
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
          _buildTextField("Full Name", "e.g. Vamshi Dasari", nameController),
          SizedBox(height: 20),
          _buildTextField("Email", "e.g. example@gmail.com", emailController),
          SizedBox(height: 20),
          _buildTextField(
              "Password", "Enter your password", passwordController),
          SizedBox(height: 30),
          _buildButton("Create Account")
        ],
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
          _buildTextField("Email", "e.g. example@gmail.com", emailController),
          SizedBox(height: 20),
          _buildTextField(
              "Password", "Enter your password", passwordController),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green),
            ),
          ),
          SizedBox(height: 30),
          _buildButton("Sign In")
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () async {
        if (text == "Sign In") {
          await ref.read(authNotifierProvider.notifier).login(
              email: emailController.text, password: passwordController.text);
        } else {
          await ref.read(authNotifierProvider.notifier).register(
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
              );
          if (mounted) {
            setState(() {
              selectedIndex = 0;
              nameController.clear();
              passwordController.clear();
              emailController.clear();
            });
          }
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
      String title, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            fillColor: const Color.fromARGB(255, 205, 221, 206),
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(
                    width: 2, color: const Color.fromARGB(255, 58, 139, 62))),
            border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                borderSide:
                    BorderSide(color: const Color.fromARGB(255, 58, 139, 62))),
            enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                borderSide:
                    BorderSide(color: const Color.fromARGB(255, 58, 139, 62))),
            hintText: hint,
          ),
        ),
      ],
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
