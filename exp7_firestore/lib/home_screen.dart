import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'student.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _cgpaController = TextEditingController();

  final FirestoreService _service = FirestoreService();
  final List<String> _departments = const ['CSE', 'AI & ML', 'ECE', 'EEE', 'Mechanical'];
  String? _department;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final student = Student(
      regNo: _regNoController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      department: _department!,
      cgpa: double.parse(_cgpaController.text.trim()),
    );

    try {
      await _service.addStudent(student);
      if (!mounted) return;
      _formKey.currentState!.reset();
      _nameController.clear();
      _regNoController.clear();
      _cgpaController.clear();
      setState(() => _department = null);
      _showMessage('${student.name} saved to Firestore');
    } on DuplicateStudentException catch (e) {
      _showMessage('Register number ${e.regNo} already exists', isError: true);
    } catch (e) {
      _showMessage('Could not save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Saving...';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.day)}-${two(time.month)}-${time.year} ${two(time.hour)}:${two(time.minute)}';
  }

  InputDecoration _decoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records – Cloud Firestore',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ---------- Input form ----------
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Add Student to Cloud',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: _decoration('Student Name', 'Enter full name', Icons.person),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter the name' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _regNoController,
                          decoration: _decoration('Register Number', 'e.g. URK23CS7108', Icons.badge),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter the register number';
                            }
                            if (!RegExp(r'^[A-Za-z]{3}\d{2}[A-Za-z]{2}\d{4}$').hasMatch(v.trim())) {
                              return 'Format must be like URK23CS7108';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _department,
                          decoration: _decoration('Department', 'Select department', Icons.school),
                          items: _departments
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setState(() => _department = v),
                          validator: (v) => v == null ? 'Please select a department' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _cgpaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _decoration('CGPA', 'Between 0 and 10', Icons.grade),
                          validator: (v) {
                            final cgpa = double.tryParse(v?.trim() ?? '');
                            if (cgpa == null || cgpa < 0 || cgpa > 10) {
                              return 'Enter a valid CGPA between 0 and 10';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.cloud_done),
                          label: Text(_saving ? 'Saving...' : 'Save to Firestore'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---------- Real-time records ----------
              StreamBuilder<List<Student>>(
                stream: _service.studentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading records: ${snapshot.error}'),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final students = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text('Cloud Records (${students.length})',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          const Chip(
                            avatar: Icon(Icons.circle, size: 12, color: Colors.green),
                            label: Text('Live'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (students.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_off, size: 48, color: Colors.orange.shade300),
                                const SizedBox(height: 8),
                                const Text('No records in Firestore yet. Add a student above.'),
                              ],
                            ),
                          ),
                        )
                      else
                        ...students.map(
                          (s) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase()),
                              ),
                              title: Text(s.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${s.regNo}  •  ${s.department}\nAdded: ${_formatTime(s.createdAt)}'),
                              isThreeLine: true,
                              trailing: Chip(
                                label: Text('CGPA ${s.cgpa.toStringAsFixed(2)}'),
                                backgroundColor: Colors.orange.shade50,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}