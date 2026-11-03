import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

// The different ways a user can search the "students" collection
enum SearchType { regNo, name, department, minCgpa }

class SearchService {
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  Future<List<Student>> search(SearchType type, String input) async {
    switch (type) {
      case SearchType.regNo:
        return _byRegisterNumber(input);
      case SearchType.name:
        return _byNamePrefix(input);
      case SearchType.department:
        return _byDepartment(input);
      case SearchType.minCgpa:
        return _byMinimumCgpa(double.parse(input));
    }
  }

  // 1. Exact match: the register number is the document ID,
  //    so the document is fetched directly with doc().get()
  Future<List<Student>> _byRegisterNumber(String regNo) async {
    final doc = await _students.doc(regNo.toUpperCase()).get();
    return doc.exists ? [Student.fromFirestore(doc)] : [];
  }

  // 2. Prefix match on name using a range query:
  //    name >= "Ed" AND name < "Ed"  -> all names starting with "Ed"
  Future<List<Student>> _byNamePrefix(String text) async {
    final prefix = _titleCase(text);
    final snapshot = await _students
        .where('name', isGreaterThanOrEqualTo: prefix)
        .where('name', isLessThan: '$prefix')
        .get();
    return snapshot.docs.map(Student.fromFirestore).toList();
  }

  // 3. Equality filter on department
  Future<List<Student>> _byDepartment(String department) async {
    final snapshot =
        await _students.where('department', isEqualTo: department).get();
    final list = snapshot.docs.map(Student.fromFirestore).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  // 4. Range filter: students with CGPA greater than or equal to a value
  Future<List<Student>> _byMinimumCgpa(double minCgpa) async {
    final snapshot = await _students
        .where('cgpa', isGreaterThanOrEqualTo: minCgpa)
        .orderBy('cgpa', descending: true)
        .get();
    return snapshot.docs.map(Student.fromFirestore).toList();
  }

  // "edlin g" -> "Edlin G" so the search matches the stored capitalisation
  String _titleCase(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}