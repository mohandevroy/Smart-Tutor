import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/file_upload_service.dart';

class EditTutorProfileScreen extends StatefulWidget {
  final String profileImage;
  final String fullName;
  final String phone;
  final String email;
  final String gender;
  final String currentLocation;
  final String permanentLocation;
  final String qualification;
  final String universityOrCollege;
  final String department;
  final String yearOrSemester;
  final String cgpaOrResult;
  final String subjects;
  final String preferredClasses;
  final String teachingExperience;
  final String teachingStyle;
  final String expectedSalary;
  final String availableDays;
  final String preferredArea;
  final String medium;
  final String tutoringMode;
  final String bio;
  final String achievements;
  final String documentUrl;

  const EditTutorProfileScreen({
    super.key,
    required this.profileImage,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.gender,
    required this.currentLocation,
    required this.permanentLocation,
    required this.qualification,
    required this.universityOrCollege,
    required this.department,
    required this.yearOrSemester,
    required this.cgpaOrResult,
    required this.subjects,
    required this.preferredClasses,
    required this.teachingExperience,
    required this.teachingStyle,
    required this.expectedSalary,
    required this.availableDays,
    required this.preferredArea,
    required this.medium,
    required this.tutoringMode,
    required this.bio,
    required this.achievements,
    required this.documentUrl,
  });

  @override
  State<EditTutorProfileScreen> createState() => _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState extends State<EditTutorProfileScreen> {
  final _uploadService = FileUploadService();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _currentLocationController;
  late TextEditingController _permanentLocationController;
  late TextEditingController _qualificationController;
  late TextEditingController _universityController;
  late TextEditingController _departmentController;
  late TextEditingController _yearSemesterController;
  late TextEditingController _cgpaController;
  late TextEditingController _subjectsController;
  late TextEditingController _preferredClassesController;
  late TextEditingController _experienceController;
  late TextEditingController _teachingStyleController;
  late TextEditingController _expectedSalaryController;
  late TextEditingController _availableDaysController;
  late TextEditingController _preferredAreaController;
  late TextEditingController _mediumController;
  late TextEditingController _bioController;
  late TextEditingController _achievementsController;

  late String _gender;
  late String _tutoringMode;
  late String _uploadedProfileImageUrl;
  late String _uploadedDocumentUrl;

  bool _isLoading = false;

  String _emptyIfFallback(String value) {
    return value.startsWith('No ') ? '' : value;
  }

  String _dropdownValueOrDefault(String value, List<String> allowedValues) {
    return allowedValues.contains(value) ? value : allowedValues.first;
  }

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: _emptyIfFallback(widget.fullName));
    _phoneController =
        TextEditingController(text: _emptyIfFallback(widget.phone));
    _emailController =
        TextEditingController(text: _emptyIfFallback(widget.email));
    _currentLocationController =
        TextEditingController(text: _emptyIfFallback(widget.currentLocation));
    _permanentLocationController =
        TextEditingController(text: _emptyIfFallback(widget.permanentLocation));
    _qualificationController =
        TextEditingController(text: _emptyIfFallback(widget.qualification));
    _universityController = TextEditingController(
        text: _emptyIfFallback(widget.universityOrCollege));
    _departmentController =
        TextEditingController(text: _emptyIfFallback(widget.department));
    _yearSemesterController =
        TextEditingController(text: _emptyIfFallback(widget.yearOrSemester));
    _cgpaController =
        TextEditingController(text: _emptyIfFallback(widget.cgpaOrResult));
    _subjectsController =
        TextEditingController(text: _emptyIfFallback(widget.subjects));
    _preferredClassesController =
        TextEditingController(text: _emptyIfFallback(widget.preferredClasses));
    _experienceController = TextEditingController(
        text: _emptyIfFallback(widget.teachingExperience));
    _teachingStyleController =
        TextEditingController(text: _emptyIfFallback(widget.teachingStyle));
    _expectedSalaryController =
        TextEditingController(text: _emptyIfFallback(widget.expectedSalary));
    _availableDaysController =
        TextEditingController(text: _emptyIfFallback(widget.availableDays));
    _preferredAreaController =
        TextEditingController(text: _emptyIfFallback(widget.preferredArea));
    _mediumController =
        TextEditingController(text: _emptyIfFallback(widget.medium));
    _bioController = TextEditingController(text: _emptyIfFallback(widget.bio));
    _achievementsController =
        TextEditingController(text: _emptyIfFallback(widget.achievements));

    _gender = _dropdownValueOrDefault(widget.gender, [
      'Male',
      'Female',
      'Other',
    ]);
    _tutoringMode = _dropdownValueOrDefault(widget.tutoringMode, [
      'Offline',
      'Online',
      'Both',
    ]);

    _uploadedProfileImageUrl = _emptyIfFallback(widget.profileImage);
    _uploadedDocumentUrl = _emptyIfFallback(widget.documentUrl);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentLocationController.dispose();
    _permanentLocationController.dispose();
    _qualificationController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _yearSemesterController.dispose();
    _cgpaController.dispose();
    _subjectsController.dispose();
    _preferredClassesController.dispose();
    _experienceController.dispose();
    _teachingStyleController.dispose();
    _expectedSalaryController.dispose();
    _availableDaysController.dispose();
    _preferredAreaController.dispose();
    _mediumController.dispose();
    _bioController.dispose();
    _achievementsController.dispose();
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

  Future<void> _updateProfile() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _qualificationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Required field গুলো পূরণ করো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingDoc = await FirebaseFirestore.instance
          .collection('tutor_profiles')
          .doc(user.uid)
          .get();
      final existingData = existingDoc.data() ?? {};

      await FirebaseFirestore.instance
          .collection('tutor_profiles')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _gender,
        'currentLocation': _currentLocationController.text.trim(),
        'permanentLocation': _permanentLocationController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'universityOrCollege': _universityController.text.trim(),
        'department': _departmentController.text.trim(),
        'yearOrSemester': _yearSemesterController.text.trim(),
        'cgpaOrResult': _cgpaController.text.trim(),
        'subjects': _subjectsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'preferredClasses': _preferredClassesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'teachingExperience': _experienceController.text.trim(),
        'teachingStyle': _teachingStyleController.text.trim(),
        'expectedSalary': _expectedSalaryController.text.trim(),
        'availableDays': _availableDaysController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'preferredArea': _preferredAreaController.text.trim(),
        'medium': _mediumController.text.trim(),
        'tutoringMode': _tutoringMode,
        'bio': _bioController.text.trim(),
        'achievements': _achievementsController.text.trim(),
        'profileImage': _uploadedProfileImageUrl,
        'documentUrl': _uploadedDocumentUrl,
        'verificationStatus':
            existingData['verificationStatus'] ?? 'not_submitted',
        'guardianRatingAverage': existingData['guardianRatingAverage'] ?? 0.0,
        'guardianTotalReviews': existingData['guardianTotalReviews'] ?? 0,
        'adminRating': existingData['adminRating'] ?? 0.0,
        'adminStatus': existingData['adminStatus'] ?? 'pending',
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileCompleted': true,
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
      }, SetOptions(merge: true));

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Basic Info'),
            _textField(_fullNameController, 'Full Name'),
            _textField(_phoneController, 'Phone'),
            _textField(_emailController, 'Email'),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final url = await _uploadService.pickAndUploadFile(
                      folderName: 'tutor_profile_images',
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                    );

                    if (url != null) {
                      setState(() {
                        _uploadedProfileImageUrl = url;
                      });

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile image uploaded')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.upload),
                label: Text(
                  _uploadedProfileImageUrl.isEmpty
                      ? 'Upload Profile Image'
                      : 'Profile Image Uploaded',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: _inputDecoration('Gender'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
            _textField(_currentLocationController, 'Current Location'),
            _textField(_permanentLocationController, 'Permanent Location'),
            _sectionTitle('Academic Info'),
            _textField(_qualificationController, 'Qualification'),
            _textField(_universityController, 'University / College'),
            _textField(_departmentController, 'Department'),
            _textField(_yearSemesterController, 'Year / Semester'),
            _textField(_cgpaController, 'CGPA / Result'),
            _sectionTitle('Teaching Info'),
            _textField(_subjectsController, 'Subjects (comma separated)'),
            _textField(
              _preferredClassesController,
              'Preferred Classes (comma separated)',
            ),
            _textField(_experienceController, 'Teaching Experience'),
            _textField(_teachingStyleController, 'Teaching Style'),
            _textField(_expectedSalaryController, 'Expected Salary'),
            _textField(
                _availableDaysController, 'Available Days (comma separated)'),
            _textField(_preferredAreaController, 'Preferred Area'),
            _textField(_mediumController, 'Medium'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _tutoringMode,
                decoration: _inputDecoration('Tutoring Mode'),
                items: const [
                  DropdownMenuItem(value: 'Offline', child: Text('Offline')),
                  DropdownMenuItem(value: 'Online', child: Text('Online')),
                  DropdownMenuItem(value: 'Both', child: Text('Both')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tutoringMode = value!;
                  });
                },
              ),
            ),
            _sectionTitle('Professional Info'),
            _textField(_bioController, 'Bio', maxLines: 3),
            _textField(_achievementsController, 'Achievements', maxLines: 3),
            _sectionTitle('Verification Info'),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final url = await _uploadService.pickAndUploadFile(
                      folderName: 'tutor_documents',
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );

                    if (url != null) {
                      setState(() {
                        _uploadedDocumentUrl = url;
                      });

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document uploaded')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(
                  _uploadedDocumentUrl.isEmpty
                      ? 'Upload Verification Document'
                      : 'Document Uploaded',
                ),
              ),
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
