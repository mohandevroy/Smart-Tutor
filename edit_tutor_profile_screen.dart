import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class EditTutorProfileScreen extends StatefulWidget {
  final String education;
  final String subject;
  final String experience;

  const EditTutorProfileScreen({
    super.key,
    required this.education,
    required this.subject,
    required this.experience,
  });

  @override
  State<EditTutorProfileScreen> createState() => _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState extends State<EditTutorProfileScreen> {
  late TextEditingController _educationController;
  late TextEditingController _subjectController;
  late TextEditingController _experienceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _educationController = TextEditingController(text: widget.education);
    _subjectController = TextEditingController(text: widget.subject);
    _experienceController = TextEditingController(text: widget.experience);
  }

  @override
  void dispose() {
    _educationController.dispose();
    _subjectController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF4F46E5)),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_educationController.text.trim().isEmpty ||
        _subjectController.text.trim().isEmpty ||
        _experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সব field পূরণ করো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .update({
      'education': _educationController.text.trim(),
      'subject': _subjectController.text.trim(),
      'experience': _experienceController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Edit Tutor Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInputField(
              label: 'Education',
              icon: Icons.school,
              controller: _educationController,
            ),
            buildInputField(
              label: 'Subject',
              icon: Icons.book,
              controller: _subjectController,
            ),
            buildInputField(
              label: 'Experience',
              icon: Icons.work,
              controller: _experienceController,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Profile',
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