// ignore: file_names
// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:home_services_app/Backend/auth/auth_checker.dart';
import 'package:provider/provider.dart';

import '../Components/button.dart';
import '../Components/colors.dart';
import '../Components/textfield.dart';
import 'SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;
  bool isLoading = false; // Add loading state

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BounceInDown(
                    child: Icon(Icons.person_rounded,
                        size: 100, color: Colors.white),
                  ),
                  SizedBox(height: 20),

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
                  InputField(
                      hint: "Email",
                      icon: Icons.account_circle,
                      controller: email),
                  InputField(
                      hint: "Password",
                      icon: Icons.lock,
                      controller: password,
                      passwordInvisible: true),

                  ListTile(
                    horizontalTitleGap: 2,
                    title: const Text("Remember me"),
                    leading: Checkbox(
                      activeColor: primaryColor,
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                    ),
                  ),

                  // Login Button with Loading Indicator
                  Button(
                    label: isLoading ? "Please wait..." : "LOGIN",
                    press: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await authProvider.signIn(email.text, password.text);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AuthChecker()),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                  ),

                  // Loading Indicator
                  isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : SizedBox(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  isLoginTrue
                      ? Text(
                          "Username or password is incorrect",
                          style: TextStyle(color: Colors.red.shade900),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
