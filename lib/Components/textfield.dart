//Our custom textfield

import 'package:flutter/material.dart';


class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool passwordInvisible;
  final TextEditingController controller;
  const InputField({super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.passwordInvisible = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: size.width *.9,
      height: 55,
      decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(8)
      ),

      child: Center(child: TextFormField(
        controller: controller,
        obscureText: passwordInvisible,
        style: TextStyle(color: Colors.white),

        decoration: InputDecoration(
hintStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          hintText: hint,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
            
          ),

        ),
      ),

      ),
    );
  }
}
