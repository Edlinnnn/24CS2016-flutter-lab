import 'package:flutter/material.dart';
import 'student.dart';
import 'update_service.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final UpdateService _service = UpdateService();
  final _formKey = GlobalKey<FormState>();

  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _cgpaController = TextEditingController();
  final List<String> _departments = const ['CSE', 'AI & ML', 'ECE', 'EEE', 'Mechanical'];
  String? _department;

  Student? _original; // record as loaded from Firestore
  bool _loading = false;
  bool _updating = false;
  String _status = 'Enter a register number and press Load to fetch the record.';
  List<String> _changeLog = []; // "Field: old → new" lines after an update

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  // Step 1: load the existing record into editable fields
  Future<void> _load() async {
    final regNo = _searchController.text.trim().toUpperCase();
    if (regNo.isEmpty) {
      setState(() => _status = 'Please enter a register number.');
      return;
    }

    setState(() {
      _loading = true;
      _original = null;
      _changeLog = [];
    });

    try {
      final student = await _service.fetchStudent(regNo);
      if (!mounted) return;
      setState(() {
        _original = student;
        if (student == null) {
          _status = 'No record found for $regNo.';
        } else {
          _nameController.text = student.name;
          _cgpaController.text = student.cgpa.toString();
          _department = _departments.contains(student.department) ? student.department : null;
          _status = 'Record loaded. Edit the fields and press Update.';
        }
      });
    } catch (e) {
      setState(() => _status = 'Could not load the record: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Step 2: send only the changed fields to Firestore
  Future<void> _update() async {
    if (_original == null || !_formKey.currentState!.validate()) return;

    final old = _original!;
    final newName = _nameController.text.trim();
    final newCgpa = double.parse(_cgpaController.text.trim());
    final newDept = _department!;

    final Map<String, dynamic> changes = {};
    final List<String> log = [];
    if (newName != old.name) {
      changes['name'] = newName;
      log.add('Name: ${old.name} → $newName');
    }
    if (newDept != old.department) {
      changes['department'] = newDept;
      log.add('Department: ${old.department} → $newDept');
    }
    if (newCgpa != old.cgpa) {
      changes['cgpa'] = newCgpa;
      log.add('CGPA: ${old.cgpa.toStringAsFixed(2)} → ${newCgpa.toStringAsFixed(2)}');
    }

    if (changes.isEmpty) {
      _showMessage('No changes to update', isError: true);
      return;
    }

    setState(() => _updating = true);
    try {
      await _service.updateStudent(old.regNo, changes);
      final refreshed = await _service.fetchStudent(old.regNo);
      if (!mounted) return;
      setState(() {
        _original = refreshed;
        _changeLog = log;
        _status = '${changes.length} field(s) updated in Firestore.';
      });
      _showMessage('Record ${old.regNo} updated successfully');
    } catch (e) {
      _showMessage('Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  void _reset() {
    _searchController.clear();
    _nameController.clear();
    _cgpaController.clear();
    setState(() {
      _original = null;
      _department = null;
      _changeLog = [];
      _status = 'Enter a register number and press Load to fetch the record.';
    });
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
    if (time == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.day)}-${two(time.month)}-${time.year} '
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Student – Firestore',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ---------- Find record ----------
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _load(),
                          decoration: const InputDecoration(
                            labelText: 'Register Number',
                            hintText: 'e.g. URK23CS7108',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _load,
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Load'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_status, style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 14),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // ---------- Edit form ----------
              if (_original != null) ...[
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Edit Student Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _original!.regNo,
                            key: ValueKey(_original!.regNo),
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Register Number (cannot be changed)',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Student Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            key: ValueKey('dept-${_original!.regNo}'),
                            initialValue: _department,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              prefixIcon: Icon(Icons.school),
                              border: OutlineInputBorder(),
                            ),
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
                            decoration: const InputDecoration(
                              labelText: 'CGPA',
                              prefixIcon: Icon(Icons.grade),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final cgpa = double.tryParse(v?.trim() ?? '');
                              if (cgpa == null || cgpa < 0 || cgpa > 10) {
                                return 'Enter a valid CGPA between 0 and 10';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _updating ? null : _update,
                                  icon: _updating
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.cloud_sync),
                                  label: Text(_updating ? 'Updating...' : 'Update in Firestore'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _reset,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- What changed ----------
                if (_changeLog.isNotEmpty)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Changes Saved',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._changeLog.map((line) => Padding(
                                padding: const EdgeInsets.only(top: 4, left: 32),
                                child: Text(line, style: const TextStyle(fontSize: 15)),
                              )),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ---------- Live values from Firestore ----------
                StreamBuilder<Student?>(
                  stream: _service.watchStudent(_original!.regNo),
                  builder: (context, snapshot) {
                    final s = snapshot.data;
                    if (s == null) return const SizedBox.shrink();
                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.cloud_done, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text('Current Record in Firestore (live)',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            _row('Register No', s.regNo),
                            _row('Name', s.name),
                            _row('Department', s.department),
                            _row('CGPA', s.cgpa.toStringAsFixed(2)),
                            _row('Created', _formatTime(s.createdAt)),
                            _row('Last Updated', _formatTime(s.updatedAt)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}