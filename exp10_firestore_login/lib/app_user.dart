import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a document in the "users" collection.
// The password is not kept in this object after login.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
    );
  }
}