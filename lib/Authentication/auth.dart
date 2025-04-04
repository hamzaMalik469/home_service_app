import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../Components/button.dart';
import '../Components/colors.dart';
import 'LoginScreen.dart';
import 'SignupScreen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: primaryGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Authentication",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  "Authenticate to access your vital information",
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(child: Icon(CupertinoIcons.lock_circle,size: 150,color: Colors.white,)),
                Button(label: "LOGIN", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
                }),
                Button(label: "SIGN UP", press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignupScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
