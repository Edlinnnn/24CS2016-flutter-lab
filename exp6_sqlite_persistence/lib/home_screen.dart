import 'package:flutter/material.dart';
import 'database_helper.dart';
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

  final List<String> _departments = const ['CSE', 'AI & ML', 'ECE', 'EEE', 'Mechanical'];
  String? _department;

  List<Student> _students = [];
  int _count = 0;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents(); // READ records when the app starts
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    try {
      final students = await DatabaseHelper.instance.getAllStudents();
      final count = await DatabaseHelper.instance.countStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
        _count = count;
      });
    } catch (e) {
      _showMessage('Could not load records: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final student = Student(
      name: _nameController.text.trim(),
      regNo: _regNoController.text.trim().toUpperCase(),
      department: _department!,
      cgpa: double.parse(_cgpaController.text.trim()),
      createdAt: DateTime.now().toString().substring(0, 16),
    );

    try {
      final id = await DatabaseHelper.instance.insertStudent(student); // CREATE
      if (!mounted) return;
      _formKey.currentState!.reset();
      _nameController.clear();
      _regNoController.clear();
      _cgpaController.clear();
      setState(() => _department = null);
      _showMessage('Record saved with ID $id');
      await _loadStudents();
    } catch (e) {
      _showMessage('Register number ${student.regNo} already exists', isError: true);
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
        title: const Text('Student Records – SQLite',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.brown,
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
                        const Text('Add New Student',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          onPressed: _saving ? null : _saveStudent,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save),
                          label: Text(_saving ? 'Saving...' : 'Save to Database'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
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

              // ---------- Stored records ----------
              Row(
                children: [
                  Expanded(
                    child: Text('Stored Records ($_count)',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    tooltip: 'Reload from database',
                    onPressed: _loadStudents,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_students.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.storage, size: 48, color: Colors.brown.shade300),
                        const SizedBox(height: 8),
                        const Text('No records in the database yet. Add a student above.'),
                      ],
                    ),
                  ),
                )
              else
                ..._students.map(
                  (s) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        child: Text('${s.id}'),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${s.regNo}  •  ${s.department}\nAdded: ${s.createdAt}'),
                      isThreeLine: true,
                      trailing: Chip(
                        label: Text('CGPA ${s.cgpa.toStringAsFixed(2)}'),
                        backgroundColor: Colors.brown.shade50,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}