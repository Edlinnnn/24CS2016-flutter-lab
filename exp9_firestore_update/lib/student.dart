import 'package:cloud_firestore/cloud_firestore.dart';

// Model class representing one document in the "students" collection
class Student {
  final String regNo; // document ID
  final String name;
  final String department;
  final double cgpa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.regNo,
    required this.name,
    required this.department,
    required this.cgpa,
    this.createdAt,
    this.updatedAt,
  });

  // Build a Student object from a Firestore document
  factory Student.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Student(
      regNo: doc.id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      cgpa: (data['cgpa'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}