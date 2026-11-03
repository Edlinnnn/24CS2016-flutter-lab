import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

// Thrown when the email or password does not match any user
class InvalidCredentialsException implements Exception {}

// Manual login using the Firestore "users" collection
// (without Firebase Authentication)
class AuthService {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<AppUser> login(String email, String password) async {
    // 1. Fetch the user document whose email matches
    final snapshot = await _users
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw InvalidCredentialsException();
    }

    // 2. Match the entered password manually
    final doc = snapshot.docs.first;
    final storedPassword = (doc.data()['password'] ?? '').toString();
    if (storedPassword != password) {
      throw InvalidCredentialsException();
    }

    // 3. Valid login - return the user's details
    return AppUser.fromFirestore(doc);
  }
}