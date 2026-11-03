// Data model passed from the Details screen to the Result screen
class Student {
  final String name;
  final String regNo;
  final String department;
  final Map<String, double> marks; // subject name -> mark

  Student({
    required this.name,
    required this.regNo,
    required this.department,
    required this.marks,
  });

  static const double passMark = 40;

  double get total => marks.values.fold(0.0, (sum, m) => sum + m);
  double get maxTotal => marks.length * 100;
  double get average => total / marks.length;
  double get percentage => (total / maxTotal) * 100;
  bool get hasPassedAll => marks.values.every((m) => m >= passMark);

  String get grade {
    if (!hasPassedAll) return 'RA (Re-appear)';
    if (percentage >= 90) return 'O (Outstanding)';
    if (percentage >= 80) return 'A+ (Excellent)';
    if (percentage >= 70) return 'A (Very Good)';
    if (percentage >= 60) return 'B+ (Good)';
    if (percentage >= 50) return 'B (Average)';
    return 'C (Satisfactory)';
  }
}