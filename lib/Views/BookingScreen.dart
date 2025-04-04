import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'BookingReceiptScreen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.workerCatagory});

  final String workerCatagory;

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedWorker;
  String? selectedDomain;
  String? selectedWorkerContact;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> workers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  /// 🔹 Fetch workers from Firestore
  Future<void> fetchWorkers() async {
    try {
      QuerySnapshot workerSnapshot = await FirebaseFirestore.instance
          .collection('worker')
          .where('work', isEqualTo: widget.workerCatagory.toString())
          .get();

      List<Map<String, dynamic>> fetchedWorkers =
          workerSnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"],
          "domain": doc["work"],
          "contact": doc["phone"],
        };
      }).toList();

      setState(() {
        workers = fetchedWorkers;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching workers: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _confirmBooking() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    if (selectedWorker != null &&
        selectedDomain != null &&
        selectedDate != null &&
        selectedTime != null) {
      // Get formatted date & time
      String formattedDate = DateFormat.yMMMd().format(selectedDate!);
      String formattedTime = selectedTime!.format(context);

      // Get User ID from FirebaseAuth
      String userId = authProvider.user!.uid;

      // Example Worker ID (Fetch from Firestore)
      String workerId = workers
          .firstWhere((worker) => worker['name'] == selectedWorker)['id'];

      try {
        // 🔹 Fetch User Details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User not found")));
          return;
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userName = userData['name'] ?? "Unknown";
        String userPhone = userData['phone'] ?? "N/A";
        String userAddress = userData['address'] ?? "N/A";

        // Generate a unique booking ID
        String bookingId = FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('history')
            .doc()
            .id;

        // 🔹 Save Booking to User History
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('history')
            .doc(bookingId)
            .set({
          'bookingId': bookingId,
          'workerId': workerId,
          'contact': selectedWorkerContact,
          'workerName': selectedWorker,
          'domain': selectedDomain,
          'date': formattedDate,
          'time': formattedTime,
          'totalBill': "2000",
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 🔹 Send Booking Request to Worker with User Details
        await FirebaseFirestore.instance
            .collection('worker')
            .doc(workerId)
            .collection('requests')
            .doc(bookingId)
            .set({
          'requestId': bookingId,
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'userAddress': userAddress,
          'domain': selectedDomain,
          'date': formattedDate,
          'time': formattedTime,
          'totalBill': "2000",
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Navigate to Receipt Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingReceiptScreen(
              workerName: selectedWorker!,
              domain: selectedDomain!,
              date: formattedDate,
              time: formattedTime,
              totalBill: "2000",
            ),
          ),
        );
      } catch (e) {
        print("Error saving booking: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error confirming booking")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select all fields")),
      );
    }
  }

  Widget _buildDropdown(String title, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(title,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          dropdownColor: Colors.blueGrey.shade800,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child:
                  Text(value, style: GoogleFonts.poppins(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGlassButton(
      {required VoidCallback onTap, required String text}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Text(text,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.blueAccent.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    "Book a Worker",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// 🔹 Show loading indicator while fetching workers
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildDropdown(
                        workers.isEmpty
                            ? "No Worker Available"
                            : "Select Worker",
                        workers.map((e) => e['name'].toString()).toList(),
                        selectedWorker,
                        (val) {
                          setState(() {
                            selectedWorker = val;
                            selectedDomain = workers.firstWhere(
                                (worker) => worker['name'] == val)['domain'];
                            selectedWorkerContact = workers.firstWhere(
                                (worker) => worker['name'] == val)['contact'];
                          });
                        },
                      ),

                SizedBox(height: 16),

                _buildGlassButton(
                  onTap: _selectDate,
                  text: selectedDate == null
                      ? "Pick Date"
                      : DateFormat.yMMMd().format(selectedDate!),
                ),
                SizedBox(height: 10),

                _buildGlassButton(
                  onTap: _selectTime,
                  text: selectedTime == null
                      ? "Pick Time"
                      : selectedTime!.format(context),
                ),

                Spacer(),

                Center(
                  child: ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      "Confirm Booking",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
