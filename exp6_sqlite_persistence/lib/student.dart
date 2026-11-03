// Model class representing one row of the "students" table
class Student {
  final int? id;
  final String name;
  final String regNo;
  final String department;
  final double cgpa;
  final String createdAt;

  Student({
    this.id,
    required this.name,
    required this.regNo,
    required this.department,
    required this.cgpa,
    required this.createdAt,
  });

  // Convert a Student object into a Map to insert into SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'regNo': regNo,
      'department': department,
      'cgpa': cgpa,
      'createdAt': createdAt,
    };
  }

  // Create a Student object from a Map read from SQLite
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int,
      name: map['name'] as String,
      regNo: map['regNo'] as String,
      department: map['department'] as String,
      cgpa: (map['cgpa'] as num).toDouble(),
      createdAt: map['createdAt'] as String,
    );
  }
}