import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  AuthenticationProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;

      if (_user != null) {
        // ✅ Ensure _user is not null before accessing uid
        _fetchUserRole(_user!.uid);
      }

      notifyListeners();
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(uid).get();

      if (!userDoc.exists) {
        userDoc = await _firestore.collection('worker').doc(uid).get();
      }

      if (userDoc.exists) {
        _role = userDoc['role'];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching role: $e");
    }
  }

  /// 🔹 Sign Up and Save User Data in Firestore
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    required String cnic,
    String? address,
    String? work,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Common user data
      Map<String, dynamic> userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role, // "customer" or "worker"
        'phone': phone,
        'cnic': cnic,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
        'password': password
      };
      _role = role;

      if (role == "worker" && work != null) {
        userData['work'] = work;

        // Store in "workers" collection
        await _firestore.collection('worker').doc(uid).set(userData);
      } else {
        // Store in "users" collection
        await _firestore.collection('user').doc(uid).set(userData);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  /// 🔹 Sign In User
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_user != null) {
        await _fetchUserRole(_user!.uid);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  /// 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
