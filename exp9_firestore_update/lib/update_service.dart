import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

class UpdateService {
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  // READ - fetch one student by register number (document ID)
  Future<Student?> fetchStudent(String regNo) async {
    final doc = await _students.doc(regNo).get();
    return doc.exists ? Student.fromFirestore(doc) : null;
  }

  // UPDATE - change only the given fields of an existing document.
  // update() fails if the document does not exist, unlike set().
  Future<void> updateStudent(String regNo, Map<String, dynamic> changes) async {
    await _students.doc(regNo).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Real-time view of a single document, used to show the latest cloud values
  Stream<Student?> watchStudent(String regNo) {
    return _students.doc(regNo).snapshots().map(
          (doc) => doc.exists ? Student.fromFirestore(doc) : null,
        );
  }
}