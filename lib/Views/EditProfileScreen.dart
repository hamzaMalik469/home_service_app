import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // User Data (Initial Values)
  String name = "Saif Ur Rehman";
  String email = "saifofficial72@gmail.com";
  String phone = "03229588272";
  String address = "Khadimabad Colony, Bahawalnagar";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", name, (val) => setState(() => name = val)),
              _buildTextField("Email", email, (val) => setState(() => email = val), isEmail: true),
              _buildTextField("Phone Number", phone, (val) => setState(() => phone = val), isPhone: true),
              _buildTextField("Address", address, (val) => setState(() => address = val)),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Text Field with Validation**
  Widget _buildTextField(String label, String value, Function(String) onChanged, {bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
        validator: (value) {
          if (value == null || value.isEmpty) return "$label is required";
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
          if (isPhone && !RegExp(r'^[0-9]{10,11}$').hasMatch(value)) return "Enter a valid phone number";
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  /// **Save & Cancel Buttons**
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Save Logic
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated Successfully")));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
          child: Text("Save", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
          child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
