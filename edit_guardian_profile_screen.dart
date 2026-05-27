import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class EditGuardianProfileScreen extends StatefulWidget {
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String area;
  final String city;
  final String childName;
  final String childClass;
  final String preferredSubjects;
  final String preferredTutorGender;
  final String preferredTutorType;
  final String budgetRange;
  final String preferredSchedule;
  final String notes;

  const EditGuardianProfileScreen({
    super.key,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.area,
    required this.city,
    required this.childName,
    required this.childClass,
    required this.preferredSubjects,
    required this.preferredTutorGender,
    required this.preferredTutorType,
    required this.budgetRange,
    required this.preferredSchedule,
    required this.notes,
  });

  @override
  State<EditGuardianProfileScreen> createState() =>
      _EditGuardianProfileScreenState();
}

class _EditGuardianProfileScreenState
    extends State<EditGuardianProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _childNameController;
  late TextEditingController _childClassController;
  late TextEditingController _preferredSubjectsController;
  late TextEditingController _budgetRangeController;
  late TextEditingController _preferredScheduleController;
  late TextEditingController _notesController;

  late String _preferredTutorGender;
  late String _preferredTutorType;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _phoneController = TextEditingController(text: widget.phone);
    _emailController = TextEditingController(text: widget.email);
    _addressController = TextEditingController(text: widget.address);
    _areaController = TextEditingController(text: widget.area);
    _cityController = TextEditingController(text: widget.city);
    _childNameController = TextEditingController(text: widget.childName);
    _childClassController = TextEditingController(text: widget.childClass);
    _preferredSubjectsController =
        TextEditingController(text: widget.preferredSubjects);
    _budgetRangeController = TextEditingController(text: widget.budgetRange);
    _preferredScheduleController =
        TextEditingController(text: widget.preferredSchedule);
    _notesController = TextEditingController(text: widget.notes);

    _preferredTutorGender = widget.preferredTutorGender.isNotEmpty
        ? widget.preferredTutorGender
        : 'Any';

    _preferredTutorType = widget.preferredTutorType.isNotEmpty
        ? widget.preferredTutorType
        : 'Any';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _childNameController.dispose();
    _childClassController.dispose();
    _preferredSubjectsController.dispose();
    _budgetRangeController.dispose();
    _preferredScheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _childNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Required field গুলো পূরণ করো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('guardian_profiles')
          .doc(user.uid)
          .update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'area': _areaController.text.trim(),
        'city': _cityController.text.trim(),
        'childName': _childNameController.text.trim(),
        'childClass': _childClassController.text.trim(),
        'preferredSubjects': _preferredSubjectsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'preferredTutorGender': _preferredTutorGender,
        'preferredTutorType': _preferredTutorType,
        'budgetRange': _budgetRangeController.text.trim(),
        'preferredSchedule': _preferredScheduleController.text.trim(),
        'notes': _notesController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Edit Guardian Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Basic Info'),
            _textField(_fullNameController, 'Full Name'),
            _textField(_phoneController, 'Phone'),
            _textField(_emailController, 'Email'),
            _textField(_addressController, 'Address'),
            _textField(_areaController, 'Area'),
            _textField(_cityController, 'City'),

            _sectionTitle('Student Info'),
            _textField(_childNameController, 'Child Name'),
            _textField(_childClassController, 'Child Class'),

            _sectionTitle('Tutor Preference'),
            _textField(
              _preferredSubjectsController,
              'Preferred Subjects (comma separated)',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _preferredTutorGender,
                decoration: _inputDecoration('Preferred Tutor Gender'),
                items: const [
                  DropdownMenuItem(value: 'Any', child: Text('Any')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    _preferredTutorGender = value!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _preferredTutorType,
                decoration: _inputDecoration('Preferred Tutor Type'),
                items: const [
                  DropdownMenuItem(value: 'Any', child: Text('Any')),
                  DropdownMenuItem(
                    value: 'University Student',
                    child: Text('University Student'),
                  ),
                  DropdownMenuItem(
                    value: 'Professional Teacher',
                    child: Text('Professional Teacher'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _preferredTutorType = value!;
                  });
                },
              ),
            ),

            _sectionTitle('Budget & Schedule'),
            _textField(_budgetRangeController, 'Budget Range'),
            _textField(_preferredScheduleController, 'Preferred Schedule'),

            _sectionTitle('Notes'),
            _textField(_notesController, 'Notes', maxLines: 3),

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