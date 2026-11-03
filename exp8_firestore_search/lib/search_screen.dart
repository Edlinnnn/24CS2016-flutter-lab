import 'package:flutter/material.dart';
import 'search_service.dart';
import 'student.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final SearchService _service = SearchService();
  final List<String> _departments = const ['CSE', 'AI & ML', 'ECE', 'EEE', 'Mechanical'];

  SearchType _type = SearchType.name;
  String? _department;
  List<Student> _results = [];
  bool _loading = false;
  String _message = 'Choose a search type and enter a value to search Firestore.';
  IconData _messageIcon = Icons.manage_search;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _hint {
    switch (_type) {
      case SearchType.regNo:
        return 'Exact register number, e.g. URK23CS7108';
      case SearchType.name:
        return 'Start of a name, e.g. Ed';
      case SearchType.department:
        return '';
      case SearchType.minCgpa:
        return 'Minimum CGPA, e.g. 8';
    }
  }

  // Validate the input before querying
  String? _validate(String input) {
    if (_type == SearchType.department) {
      return _department == null ? 'Please select a department.' : null;
    }
    if (input.isEmpty) return 'Please enter a search value.';
    if (_type == SearchType.minCgpa) {
      final v = double.tryParse(input);
      if (v == null || v < 0 || v > 10) return 'Enter a CGPA between 0 and 10.';
    }
    return null;
  }

  Future<void> _search() async {
    final input = _type == SearchType.department
        ? (_department ?? '')
        : _searchController.text.trim();

    final error = _validate(input);
    if (error != null) {
      setState(() {
        _results = [];
        _message = error;
        _messageIcon = Icons.info_outline;
      });
      return;
    }

    setState(() {
      _loading = true;
      _results = [];
    });

    try {
      final results = await _service.search(_type, input);
      if (!mounted) return;
      setState(() {
        _results = results;
        _message = results.isEmpty
            ? 'No matching student found for "$input".'
            : '${results.length} record(s) found for "$input".';
        _messageIcon = results.isEmpty ? Icons.search_off : Icons.check_circle;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Search failed: $e';
        _messageIcon = Icons.error_outline;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clear() {
    _searchController.clear();
    setState(() {
      _department = null;
      _results = [];
      _message = 'Choose a search type and enter a value to search Firestore.';
      _messageIcon = Icons.manage_search;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Student Search',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.cyan.shade800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ---------- Search panel ----------
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Search by',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      SegmentedButton<SearchType>(
                        segments: const [
                          ButtonSegment(
                              value: SearchType.name, label: Text('Name'), icon: Icon(Icons.person)),
                          ButtonSegment(
                              value: SearchType.regNo, label: Text('Reg. No'), icon: Icon(Icons.badge)),
                          ButtonSegment(
                              value: SearchType.department,
                              label: Text('Department'),
                              icon: Icon(Icons.school)),
                          ButtonSegment(
                              value: SearchType.minCgpa, label: Text('Min CGPA'), icon: Icon(Icons.grade)),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _type = selection.first;
                            _searchController.clear();
                            _results = [];
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Department uses a dropdown; the others use a text field
                      if (_type == SearchType.department)
                        DropdownButtonFormField<String>(
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
                        )
                      else
                        TextField(
                          controller: _searchController,
                          keyboardType: _type == SearchType.minCgpa
                              ? const TextInputType.numberWithOptions(decimal: true)
                              : TextInputType.text,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            labelText: 'Search value',
                            hintText: _hint,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _search,
                              icon: const Icon(Icons.search),
                              label: const Text('Search Firestore'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _clear,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------- Status message ----------
              Row(
                children: [
                  Icon(_messageIcon, color: Colors.cyan.shade800),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_message, style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- Results ----------
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ..._results.map(_resultCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCard(Student s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.cyan.shade800,
              foregroundColor: Colors.white,
              child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _detail('Register No', s.regNo),
                  _detail('Department', s.department),
                  _detail('CGPA', s.cgpa.toStringAsFixed(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}