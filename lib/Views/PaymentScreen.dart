import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _authenticatePayment() {
    if (_pinController.text.length == 4) {
      Navigator.pop(context);
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid 4-digit PIN")),
      );
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(

          title: Text("Enter 4-Digit PIN", style: GoogleFonts.poppins(),),
          content: TextField(

            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: InputDecoration(hintText: "****"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(

              onPressed: _authenticatePayment,
              child: Text("Confirm",style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/success.json', width: 120, height: 120),
              SizedBox(height: 10),
              Text("Congratulations!", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Your payment was successful!", style: GoogleFonts.poppins(fontSize: 16)),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card, 'color': Colors.blueAccent},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance, 'color': Colors.purple},
    {'name': 'JazzCash', 'icon': Icons.mobile_friendly, 'color': Colors.orange},
    {'name': 'EasyPaisa', 'icon': Icons.attach_money, 'color': Colors.green},
    {'name': 'Cash on Delivery', 'icon': Icons.money, 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Payment",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 80),
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 20),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Icon(paymentMethods[index]['icon'], color: paymentMethods[index]['color']),
                                title: Text(paymentMethods[index]['name'], style: GoogleFonts.poppins()),
                                onTap: _showPinDialog,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}