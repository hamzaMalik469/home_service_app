import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:provider/provider.dart';

import '../Views/WorkerHomeScreen.dart';
import 'LoginScreen.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorkerSignupScreenState createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedDomain;
  bool _isLoading = false;

  final List<String> _domains = [
    'Carpenter',
    'Plumber',
    'Electrician',
    'Painter',
    'Mechanic',
    'Welder',
    'Mason',
    'Technician',
    'Blacksmith',
    'Tile Fitter'
  ];

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return FadeIn(
      duration: Duration(milliseconds: 800),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurpleAccent]),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BounceInDown(
                      child:
                          Icon(Icons.handyman, size: 100, color: Colors.white)),
                  SizedBox(height: 20),
                  Text("Worker Signup",
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.person),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _cnicController,
                      label: "CNIC",
                      icon: Icons.credit_card),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _phoneController,
                      label: "Phone",
                      icon: Icons.phone),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _addressController,
                      label: "Address",
                      icon: Icons.home),
                  SizedBox(height: 10),
                  FadeIn(
                    duration: Duration(milliseconds: 800),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDomain,
                      dropdownColor: Colors.black87,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Select Work Domain",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _domains.map((domain) {
                        return DropdownMenuItem(
                          value: domain,
                          child: Text(domain,
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDomain = value);
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await Future.delayed(Duration(milliseconds: 500));
                            try {
                              await authProvider.signUp(
                                  cnic: _cnicController.text,
                                  email: _emailController.text,
                                  name: _nameController.text,
                                  password: _passwordController.text,
                                  role: 'worker',
                                  address: _addressController.text,
                                  phone: _phoneController.text,
                                  work: _selectedDomain);
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => WorkerHomeScreen()),
                                (route) => false,
                              );
                            } catch (e) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
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
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3)
                            : Text("Sign Up",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen())),
                    child: Text("Already have an account? Login",
                        style: TextStyle(color: Colors.white70)),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
