import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/core/constants/app_collections.dart';
import 'package:smart_tutor/services/auth_service.dart';

class PostTuitionScreen extends StatefulWidget {
  const PostTuitionScreen({super.key});

  @override
  State<PostTuitionScreen> createState() => _PostTuitionScreenState();
}

class _PostTuitionScreenState extends State<PostTuitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _classController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _budgetController = TextEditingController();
  final _areaController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _notesController = TextEditingController();

  String _preferredTutorGender = 'Any';
  String _tuitionMode = 'Offline';
  bool _isSaving = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _classController.dispose();
    _subjectsController.dispose();
    _budgetController.dispose();
    _areaController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _postTuition() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final guardianDoc = await FirebaseFirestore.instance
          .collection(AppCollections.guardianProfiles)
          .doc(user.uid)
          .get();
      final userDoc = await FirebaseFirestore.instance
          .collection(AppCollections.users)
          .doc(user.uid)
          .get();
      final guardianData = guardianDoc.data() ?? {};
      final userData = userDoc.data() ?? {};
      final guardianName =
          (guardianData['fullName'] ?? userData['name'] ?? user.email ?? '')
              .toString()
              .trim();
      final guardianEmail =
          (guardianData['email'] ?? userData['email'] ?? user.email ?? '')
              .toString()
              .trim();

      await FirebaseFirestore.instance
          .collection(AppCollections.tuitionPosts)
          .add({
        'guardianId': user.uid,
        'guardianName': guardianName.isEmpty ? 'Guardian' : guardianName,
        'guardianEmail': guardianEmail,
        'guardianPhone': guardianData['phone'] ?? '',
        'studentName': _studentNameController.text.trim(),
        'studentClass': _classController.text.trim(),
        'subjects': _subjectsController.text
            .split(',')
            .map((subject) => subject.trim())
            .where((subject) => subject.isNotEmpty)
            .toList(),
        'budgetRange': _budgetController.text.trim(),
        'area': _areaController.text.trim(),
        'preferredSchedule': _scheduleController.text.trim(),
        'preferredTutorGender': _preferredTutorGender,
        'tuitionMode': _tuitionMode,
        'notes': _notesController.text.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuition posted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Post Tuition'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_studentNameController, 'Student Name', Icons.person),
              _field(_classController, 'Class / Grade', Icons.class_outlined),
              _field(
                _subjectsController,
                'Subjects (comma separated)',
                Icons.menu_book_outlined,
              ),
              _field(
                _budgetController,
                'Budget Range',
                Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
              _field(_areaController, 'Area', Icons.location_on_outlined),
              _field(
                _scheduleController,
                'Preferred Schedule',
                Icons.schedule_outlined,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _preferredTutorGender,
                      decoration: _decoration(
                        'Tutor Gender',
                        Icons.person_pin_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Any', child: Text('Any')),
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        setState(() => _preferredTutorGender = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _tuitionMode,
                      decoration: _decoration('Mode', Icons.computer_outlined),
                      items: const [
                        DropdownMenuItem(
                          value: 'Offline',
                          child: Text('Offline'),
                        ),
                        DropdownMenuItem(
                            value: 'Online', child: Text('Online')),
                        DropdownMenuItem(value: 'Both', child: Text('Both')),
                      ],
                      onChanged: (value) {
                        setState(() => _tuitionMode = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _notesController,
                'Notes',
                Icons.note_alt_outlined,
                maxLines: 3,
                required: false,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _postTuition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Post Tuition',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
