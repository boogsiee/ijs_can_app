import 'package:flutter/material.dart';
import 'database_helper.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<Map<String, dynamic>> _linkedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadLinkedStudents();
  }

  Future<void> _loadLinkedStudents() async {
    final db = await DatabaseHelper.instance.database;
    // Fetch students linked to parent_id = 4 (parent_delacruz)
    final result = await db.rawQuery('''
      SELECT users.username FROM users
      JOIN parent_student_links ON users.id = parent_student_links.student_id
      WHERE parent_student_links.parent_id = 4
    ''');
    setState(() {
      _linkedStudents = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Monitoring Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Linked Children Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _linkedStudents.length,
                itemBuilder: (context, index) {
                  final student = _linkedStudents[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(student['username']),
                      subtitle: const Text('Status: Active • No recent restrictions'),
                      trailing: const Text('₱0.00 Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}