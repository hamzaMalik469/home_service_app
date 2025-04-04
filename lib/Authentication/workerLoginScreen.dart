import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:home_services_app/Backend/auth/auth.dart';

import '../Views/WorkerHomeScreen.dart';
import 'WorkerSignupScreen.dart';

class Workerloginscreen extends StatefulWidget {
  const Workerloginscreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<Workerloginscreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ✅ Hardcoded credentials for validation

  // 🔍 Email Validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  // 🔒 Password Validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  // 🛠 Function to build TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔥 Beautiful Login Button
  Widget _buildLoginButton(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return ZoomIn(
      duration: Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Future.delayed(Duration(milliseconds: 500));
                try {
                  await authProvider.signIn(
                      _emailController.text, _passwordController.text);

                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WorkerHomeScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent]),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: Center(
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                : Text("Login",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // 🏷 Login Button Click Handler with Specific Credentials Check

  @override
  Widget build(BuildContext context) {
    final hight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: hight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.deepPurpleAccent]),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey, // 🔥 Form for Validation
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🏆 Animated Icon
                    BounceInDown(
                        child: Icon(Icons.person_rounded,
                            size: 100, color: Colors.white)),
                    SizedBox(height: 20),

                    // 📢 Animated Title
                    FadeIn(
                      duration: Duration(milliseconds: 900),
                      child: Text(
                        "Welcome Back!",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // 📌 TextFields with Validation
                    _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email,
                        validator: _validateEmail),
                    SizedBox(height: 10),
                    _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: _validatePassword),
                    SizedBox(height: 20),

                    // 🔥 Beautiful Login Button with Loader
                    _buildLoginButton(context),
                    SizedBox(height: 10),

                    // 🌟 Signup Navigation
                    FadeIn(
                      duration: Duration(milliseconds: 1000),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerSignupScreen(),
                              ));
                        },
                        child: Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
