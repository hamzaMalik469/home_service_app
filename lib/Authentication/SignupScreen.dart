import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:home_services_app/Backend/auth/auth_checker.dart';
import 'package:provider/provider.dart';

import '../Components/button.dart';
import '../Components/colors.dart';
import '../Components/textfield.dart';
import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //Controllers
  final fullName = TextEditingController();
  final cnic = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();

  final contact = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final address = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BounceInDown(
                    child:
                        Icon(Icons.handyman, size: 100, color: Colors.white)),
                SizedBox(height: 20),
                Text("Customer Signup",
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 20),
                InputField(
                    hint: "Full name",
                    icon: Icons.person,
                    controller: fullName),
                InputField(
                    hint: "CNIC",
                    icon: Icons.credit_card_rounded,
                    controller: cnic),
                InputField(hint: "Email", icon: Icons.email, controller: email),
                InputField(
                    hint: "Username",
                    icon: Icons.account_circle,
                    controller: usrName),
                InputField(
                    hint: "Address",
                    icon: Icons.location_city,
                    controller: address),
                InputField(
                    hint: "Contact", icon: Icons.phone, controller: contact),
                InputField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: password,
                    passwordInvisible: true),
                InputField(
                    hint: "Re-enter password",
                    icon: Icons.lock,
                    controller: confirmPassword,
                    passwordInvisible: true),
                const SizedBox(height: 10),
                Button(
                  label: isLoading ? "Please wait..." : "SIGN UP",
                  press: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await Future.delayed(Duration(microseconds: 500));
                    try {
                      await authProvider.signUp(
                          cnic: cnic.text,
                          email: email.text,
                          name: usrName.text,
                          password: password.text,
                          role: 'user',
                          address: address.text,
                          phone: contact.text);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AuthChecker()),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
