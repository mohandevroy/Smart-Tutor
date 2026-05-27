import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class EditExperienceScreen extends StatefulWidget {
  final String experience;

  const EditExperienceScreen({
    super.key,
    required this.experience,
  });

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  late TextEditingController _experienceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _experienceController = TextEditingController(text: widget.experience);
  }

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _updateExperience() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experience লিখো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .update({
      'experience': _experienceController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Experience updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Edit Experience'),
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
                controller: _experienceController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.work, color: Color(0xFF4F46E5)),
                  labelText: 'Experience',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateExperience,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Experience',
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