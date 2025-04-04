import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_services_app/JASON/user.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    fetchUserData();
  }

  /// 🔹 Fetch User Data from Firestore
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (!userDoc.exists) {
          userDoc = await _firestore
              .collection('workers')
              .doc(firebaseUser.uid)
              .get();
        }

        if (userDoc.exists) {
          _user = UserModel.fromMap(
              userDoc.data() as Map<String, dynamic>, userDoc.id);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
