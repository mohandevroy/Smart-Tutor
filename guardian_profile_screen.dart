import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/guardian_profile_model.dart';
import '../../services/guardian_profile_service.dart';
import 'my_guardian_profile_screen.dart';

class GuardianProfileScreen extends StatefulWidget {
  const GuardianProfileScreen({super.key});

  @override
  State<GuardianProfileScreen> createState() => _GuardianProfileScreenState();
}

class _GuardianProfileScreenState extends State<GuardianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GuardianProfileService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childClassController = TextEditingController();
  final _preferredSubjectsController = TextEditingController();
  final _budgetRangeController = TextEditingController();
  final _preferredScheduleController = TextEditingController();
  final _notesController = TextEditingController();

  String _preferredTutorGender = 'Any';
  String _preferredTutorType = 'Any';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      _emailController.text = user?.email ?? '';

      final profile = await _service.getGuardianProfile();

      if (profile == null) return;

      _fullNameController.text = profile.fullName;
      _phoneController.text = profile.phone;
      _emailController.text = profile.email;
      _addressController.text = profile.address;
      _areaController.text = profile.area;
      _cityController.text = profile.city;
      _childNameController.text = profile.childName;
      _childClassController.text = profile.childClass;
      _preferredSubjectsController.text = profile.preferredSubjects.join(', ');
      _budgetRangeController.text = profile.budgetRange;
      _preferredScheduleController.text = profile.preferredSchedule;
      _notesController.text = profile.notes;

      _preferredTutorGender = profile.preferredTutorGender.isNotEmpty
          ? profile.preferredTutorGender
          : 'Any';

      _preferredTutorType = profile.preferredTutorType.isNotEmpty
          ? profile.preferredTutorType
          : 'Any';

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = GuardianProfileModel(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        childName: _childNameController.text.trim(),
        childClass: _childClassController.text.trim(),
        preferredSubjects: _preferredSubjectsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        preferredTutorGender: _preferredTutorGender,
        preferredTutorType: _preferredTutorType,
        budgetRange: _budgetRangeController.text.trim(),
        preferredSchedule: _preferredScheduleController.text.trim(),
        notes: _notesController.text.trim(),
        adminStatus: 'pending',
        updatedAt: DateTime.now(),
      );

      await _service.saveGuardianProfile(profile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardian profile saved successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MyGuardianProfileScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionTitle('Basic Info'),
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Phone', _phoneController),
              _buildTextField('Email', _emailController),
              _buildTextField('Address', _addressController),
              _buildTextField('Area', _areaController),
              _buildTextField('City', _cityController),

              _buildSectionTitle('Student Info'),
              _buildTextField('Child Name', _childNameController),
              _buildTextField('Child Class', _childClassController),

              _buildSectionTitle('Tutor Preference'),
              _buildTextField(
                'Preferred Subjects (comma separated)',
                _preferredSubjectsController,
              ),
              DropdownButtonFormField<String>(
                value: _preferredTutorGender,
                decoration: const InputDecoration(
                  labelText: 'Preferred Tutor Gender',
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _preferredTutorType,
                decoration: const InputDecoration(
                  labelText: 'Preferred Tutor Type',
                  border: OutlineInputBorder(),
                ),
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

              const SizedBox(height: 16),
              _buildSectionTitle('Budget & Schedule'),
              _buildTextField('Budget Range', _budgetRangeController),
              _buildTextField('Preferred Schedule', _preferredScheduleController),

              _buildSectionTitle('Notes'),
              _buildTextField('Notes', _notesController, maxLines: 3),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save Profile'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}