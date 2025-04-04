import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    fetchCustomers(); // Fetch customers when provider is initialized
  }

  /// 🔹 Fetch Customers from Firestore
  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .snapshots()
          .listen((snapshot) {
        _customers = snapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("Error fetching customers: $e");
      _isLoading = false;
    }
  }
}
