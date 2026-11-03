import 'package:flutter/material.dart';
import 'student.dart';
import 'result_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  static const String routeName = '/';

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _deptController = TextEditingController();

  final List<String> _subjects = const [
    'Building Applications using Flutter',
    'Machine Learning',
    'Database Management Systems',
  ];
  late final List<TextEditingController> _markControllers =
      List.generate(_subjects.length, (_) => TextEditingController());

  String _returnMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _deptController.dispose();
    for (final c in _markControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _viewResult() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      name: _nameController.text.trim(),
      regNo: _regNoController.text.trim().toUpperCase(),
      department: _deptController.text.trim(),
      marks: {
        for (int i = 0; i < _subjects.length; i++)
          _subjects[i]: double.parse(_markControllers[i].text),
      },
    );

    // Navigate to the Result screen with the student object as an argument
    final reply = await Navigator.pushNamed(
      context,
      ResultScreen.routeName,
      arguments: student,
    );

    // Data returned from the Result screen through Navigator.pop()
    setState(() {
      _returnMessage = reply == null ? '' : reply.toString();
    });
  }

  Widget _textField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _markField(TextEditingController controller, String subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: subject,
          hintText: 'Mark out of 100',
          prefixIcon: const Icon(Icons.edit_note),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter the mark';
          }
          final mark = double.tryParse(value);
          if (mark == null || mark < 0 || mark > 100) {
            return 'Enter a mark between 0 and 100';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter Student Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _textField(_nameController, 'Student Name', Icons.person),
                  _textField(_regNoController, 'Register Number', Icons.badge),
                  _textField(_deptController, 'Department', Icons.school),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('Subject Marks',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  for (int i = 0; i < _subjects.length; i++)
                    _markField(_markControllers[i], _subjects[i]),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    onPressed: _viewResult,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View Result', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  if (_returnMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.keyboard_return, color: Colors.blueGrey),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_returnMessage)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}