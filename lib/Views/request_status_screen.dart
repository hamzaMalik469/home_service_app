import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerRequestsScreen extends StatelessWidget {
  final String workerId = FirebaseAuth.instance.currentUser!.uid;

  WorkerRequestsScreen({super.key});

  /// Fetch accepted requests
  Stream<QuerySnapshot> getAcceptedRequests() {
    return FirebaseFirestore.instance
        .collection('worker')
        .doc(workerId)
        .collection('requests')
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  /// Fetch declined requests
  Stream<QuerySnapshot> getDeclinedRequests() {
    return FirebaseFirestore.instance
        .collection('worker')
        .doc(workerId)
        .collection('requests')
        .where('status', isEqualTo: 'declined')
        .snapshots();
  }

  /// Fetch completed requests
  Stream<QuerySnapshot> getCompletedRequests() {
    return FirebaseFirestore.instance
        .collection('worker')
        .doc(workerId)
        .collection('requests')
        .where('status', isEqualTo: 'completed')
        .snapshots();
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
        title: Text(
          "My Requests",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300, fontSize: 22, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Accepted Requests",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getAcceptedRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No accepted requests"));
                  }

                  var requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      var request = requests[index];
                      return RequestCard(
                        request,
                        workerId,
                        isAccepted: true,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Declined Requests",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getDeclinedRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No declined requests"));
                  }

                  var requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      var request = requests[index];
                      return RequestCard(
                        request,
                        workerId,
                        isAccepted: false,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Completed Requests",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getCompletedRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No completed requests"));
                  }

                  var requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      var request = requests[index];
                      return RequestCard(
                        request,
                        workerId,
                        isAccepted: false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class RequestCard extends StatelessWidget {
  final QueryDocumentSnapshot request;

  RequestCard(this.request, this.workerId, {this.isAccepted, super.key});

  bool? isAccepted = false;
  String? workerId;

  void markAsCompleted(String requestId, String userId) async {
    try {
      // Firestore reference
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the update data
      Map<String, dynamic> updateData = {
        'status': 'completed',
        'completedDate': Timestamp.now(),
      };

      // Update status in worker's requests
      await firestore
          .collection('worker')
          .doc(workerId)
          .collection('requests')
          .doc(requestId)
          .update(updateData);

      // Update status in user's history (nested inside user collection)
      await firestore
          .collection('user')
          .doc(userId) // Ensure userId is passed correctly
          .collection('history')
          .doc(requestId)
          .update(updateData);

      print("Request marked as completed successfully!");
    } catch (e) {
      print("Error marking request as completed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 15),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${request['userName']}",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text("Booking Time: ${request['date']} at ${request['time']}",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w400)),
            Text("Address: ${request['userAddress']}",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w400)),
            Text("Contact: ${request['userPhone']}",
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w400)),
            Text("Price: ${request['totalBill']}",
                style: GoogleFonts.poppins(fontSize: 14)),
            isAccepted!
                ? ElevatedButton(
                    onPressed: () =>
                        markAsCompleted(request.id, request['userId']),
                    child: Center(child: Text("Mark as Completed")))
                : Text('')
          ],
        ),
      ),
    );
  }
}
