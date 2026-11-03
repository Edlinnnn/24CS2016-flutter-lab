import 'package:flutter/material.dart';
import 'student.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const String routeName = '/result';

  @override
  Widget build(BuildContext context) {
    // Retrieve the data passed through the named route
    final student = ModalRoute.of(context)!.settings.arguments as Student;
    final bool passed = student.hasPassedAll;
    final Color statusColor = passed ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Result', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Student info
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      child: Text(student.name[0].toUpperCase()),
                    ),
                    title: Text(student.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('${student.regNo}  •  ${student.department}'),
                  ),
                ),
                const SizedBox(height: 12),

                // Subject-wise marks
                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('Subject-wise Marks',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      ...student.marks.entries.map((entry) {
                        final ok = entry.value >= Student.passMark;
                        return ListTile(
                          leading: Icon(ok ? Icons.check_circle : Icons.cancel,
                              color: ok ? Colors.green : Colors.red),
                          title: Text(entry.key),
                          trailing: Text(entry.value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Summary
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _row(Icons.calculate, 'Total Marks',
                            '${student.total.toStringAsFixed(0)} / ${student.maxTotal.toStringAsFixed(0)}'),
                        _row(Icons.analytics, 'Average', student.average.toStringAsFixed(2)),
                        _row(Icons.percent, 'Percentage', '${student.percentage.toStringAsFixed(2)}%'),
                        _row(Icons.workspace_premium, 'Grade', student.grade),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Pass / fail banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    passed ? 'PASSED in all subjects' : 'Not cleared in one or more subjects',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Go back and send data to the previous screen
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      'Returned from Result screen – ${student.name}: '
                      '${student.percentage.toStringAsFixed(2)}%, Grade ${student.grade}',
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}