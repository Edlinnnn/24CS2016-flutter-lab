import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

// Thrown when a student with the same register number already exists
class DuplicateStudentException implements Exception {
  final String regNo;
  DuplicateStudentException(this.regNo);
}

// All Firestore operations for the "students" collection
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  // CREATE - add a new student document (document ID = register number)
  Future<void> addStudent(Student student) async {
    final docRef = _students.doc(student.regNo);

    // Check for an existing record before writing
    final existing = await docRef.get();
    if (existing.exists) {
      throw DuplicateStudentException(student.regNo);
    }
    await docRef.set(student.toFirestore());
  }

  // READ - real-time stream of all students, newest first
  Stream<List<Student>> studentsStream() {
    return _students
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
  }
}