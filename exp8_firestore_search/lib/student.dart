import 'package:cloud_firestore/cloud_firestore.dart';

// Model class representing one document in the "students" collection
class Student {
  final String regNo; // also used as the document ID
  final String name;
  final String department;
  final double cgpa;
  final DateTime? createdAt;

  Student({
    required this.regNo,
    required this.name,
    required this.department,
    required this.cgpa,
    this.createdAt,
  });

  // Convert the object into a Map to store in Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'regNo': regNo,
      'name': name,
      'department': department,
      'cgpa': cgpa,
      'createdAt': FieldValue.serverTimestamp(), // time set by the server
    };
  }

  // Build a Student object from a Firestore document
  factory Student.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return Student(
      regNo: doc.id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      cgpa: (data['cgpa'] as num?)?.toDouble() ?? 0,
      createdAt: ts?.toDate(),
    );
  }
}