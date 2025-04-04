import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_services_app/Authentication/RoleSelectionScreen.dart';
import 'package:home_services_app/Backend/auth/auth.dart';
import 'package:home_services_app/Views/HomeScreen.dart';
import 'package:home_services_app/Views/WorkerHomeScreen.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  /// **Function to determine user role from separate collections**
  Future<String?> getUserRole(String uid) async {
    try {
      // Check if the user exists in the 'workers' collection
      DocumentSnapshot workerDoc =
          await FirebaseFirestore.instance.collection('worker').doc(uid).get();

      if (workerDoc.exists) {
        return 'worker';
      }

      // Check if the user exists in the 'users' collection
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (userDoc.exists) {
        return 'user';
      }

      return null; // User not found in either collection
    } catch (e) {
      print("Error fetching role: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, child) {
        final user = authenticationProvider.user;

        if (user == null) {
          return RoleSelectionScreen(); // Navigate to role selection if no user is logged in
        }

        return FutureBuilder<String?>(
          future: getUserRole(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Scaffold(
                body: ScaffoldMessenger(
                    child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Connection Failed!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text("Make sure your internet connection"),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthChecker(),
                                ));
                          },
                          child: Text("Refresh"))
                    ],
                  ),
                )),
              );
            }

            final role = snapshot.data!;
            return role == 'worker' ? WorkerHomeScreen() : const HomeScreen();
          },
        );
      },
    );
  }
}
