class UserModel {
  String uid;
  String name;
  String email;
  String? phone;
  String? role;
  String? work; // Only for workers
  String? address;
  String? username;
  String cnic;

  UserModel({
    this.username,
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.work,
    this.address,
    required this.cnic,
  });

  /// 🔹 Convert Firestore Document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      work: map['work'], // Workers only
      address: map['address'] ?? '',
      cnic: map['cnic'] ?? '',
      username: map['username'],
    );
  }

  /// 🔹 Convert UserModel to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      if (work != null) "work": work, // Only include if user is a worker
      "address": address,
      "cnic": cnic,
      "username": username
    };
  }
}
