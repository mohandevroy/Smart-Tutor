import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class EditSubjectScreen extends StatefulWidget {
  final String subject;

  const EditSubjectScreen({
    super.key,
    required this.subject,
  });

  @override
  State<EditSubjectScreen> createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  late TextEditingController _subjectController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.subject);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _updateSubject() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject লিখো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .update({
      'subject': _subjectController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subject updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Edit Subject'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.book, color: Color(0xFF4F46E5)),
                  labelText: 'Subject',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Subject',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}