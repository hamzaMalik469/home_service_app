import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:home_services_app/Backend/auth/auth_checker.dart';
import 'package:home_services_app/Views/request_status_screen.dart';
import 'package:provider/provider.dart';

class WorkerHomeScreen extends StatelessWidget {
  final String workerId = FirebaseAuth.instance.currentUser!.uid;

  WorkerHomeScreen({super.key});

  //Update request status
  void updateRequestStatus(
      String requestId, String status, String userId) async {
    try {
      // Firestore reference
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update status in worker's requests
      await firestore
          .collection('worker')
          .doc(workerId)
          .collection('requests')
          .doc(requestId)
          .update({'status': status});

      // Update status in user's history (nested inside user collection)
      await firestore
          .collection('user')
          .doc(userId) // Ensure userId is passed correctly
          .collection('history')
          .doc(requestId)
          .update({'status': status});

      print("Status updated successfully!");
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          "Worker Requests",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Want to Logg out?',
                            style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  authProvider.signOut();
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AuthChecker(),
                                      ));
                                },
                                child: Text('LOG OUT'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('CANCEL'),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('worker')
            .doc(workerId)
            .collection('requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading requests"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No requests available",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              ),
            );
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              var requestId = request.id;
              var customerName = request['userName'];
              var address = request['userAddress'] ?? "N/A";
              var date = request['date'];
              var time = request['time'];
              var price = request['totalBill'];
              var contact = request['userPhone'];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 10),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: $customerName",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      Text("Booking Time: $date at $time",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                      Text("Address: $address",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      Text("Contact: $contact",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      Text("Price: $price",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => updateRequestStatus(
                                requestId, "accepted", request['userId']),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text("Accept",
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => updateRequestStatus(
                                requestId, "declined", request['userId']),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text("Decline",
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerRequestsScreen(),
              ));
        },
        child: Icon(Icons.notes),
      ),
    );
  }
}
