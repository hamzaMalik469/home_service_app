import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services_app/Authentication/RoleSelectionScreen.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:home_services_app/Views/HomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Components/colors.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
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
          "Profile",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300, fontSize: 22, color: Colors.white),
        ),
        leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              try {
                authProvider.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(authProvider.user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(gradient: primaryGradient),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: userData?["profileImage"] != null
                          ? NetworkImage(userData!["profileImage"])
                          : AssetImage("assets/no_user.jpg") as ImageProvider,
                    ),
                    SizedBox(height: 15),
                    Text(userData?["name"] ?? "User Name",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text(
                      userData?["email"] ?? "user@example.com",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    _buildProfileTile(
                        Icons.person, "Full Name", userData?["name"] ?? "N/A"),
                    _buildProfileTile(
                        Icons.email, "Email", userData?["email"] ?? "N/A"),
                    _buildProfileTile(Icons.account_circle, "Username",
                        userData?["username"] ?? "admin"),
                    _buildProfileOption(
                        Icons.history,
                        "Booking History",
                        BookingHistoryScreen(uid: authProvider.user?.uid),
                        context),
                    _buildProfileOption(Icons.support_agent, "Customer Support",
                        CustomerSupportScreen(), context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  /// **Profile Option Tile with InkWell**
  Widget _buildProfileOption(
      IconData icon, String title, Widget screen, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      splashColor: Colors.blue.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 70,
        width: 340,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          // boxShadow: [
          //   BoxShadow(color: Colors.grey.shade300, blurRadius: 6, spreadRadius: 2),
          // ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: primaryColor,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class BookingHistoryScreen extends StatelessWidget {
  final String? uid;
  const BookingHistoryScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .doc(authProvider.user!.uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var bookings = snapshot.data!.docs;
          return bookings.isEmpty
              ? Center(
                  child: Text("No Booking History"),
                )
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var data = bookings[index].data() as Map<String, dynamic>;
                    return _buildBookingCard(data);
                  },
                );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.event, "Booking Time",
                "${booking['date']} at ${booking['time']} "),
            _infoRow(Icons.confirmation_num, "Worker Name",
                booking["workerName"] ?? ""),
            _infoRow(Icons.confirmation_num, "Work", booking["domain"] ?? ""),
            _infoRow(Icons.phone, "Contact", booking["contact"] ?? ""),
            _infoRow(
              Icons.check_circle,
              "Status",
              booking["status"] ?? "",
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    Color statusColor;

    // Set icon color based on booking status
    switch (value.toLowerCase()) {
      case "pending":
        statusColor = Colors.orange; // 🟠 Pending Status
        break;
      case "declined":
        statusColor = Colors.red;
        break;
      case "accepted":
        statusColor = Colors.lightGreen;
        break;
      case "completed":
        statusColor = Colors.green; // 🟢 Completed Status
        break;
      default:
        statusColor = Colors.black; // ⚪ Default (Unknown) Status
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: statusColor), // Dynamic Color Applied
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: GoogleFonts.poppins(fontSize: 14, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          "Customer Support",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSupportOption(
                Icons.call, "Call Us", "03229588272", "tel:03229588272"),
            _buildSupportOption(Icons.email, "Email Us",
                "support@galaxydev.com", "mailto:support@galaxydev.com"),
            _buildSupportOption(Icons.chat, "Live Chat", "Chat with our agent",
                "https://wa.me/923229588272"),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
      IconData icon, String title, String subtitle, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () => _launchURL(url),
    );
  }
}
