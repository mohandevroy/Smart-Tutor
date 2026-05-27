import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tutor_profile_model.dart';
import '../../services/tutor_profile_service.dart';
import '../../services/file_upload_service.dart';
import 'tutor_dashboard_screen.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TutorProfileService();
  final _uploadService = FileUploadService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _uploadedProfileImageUrl = '';
  String _uploadedDocumentUrl = '';

  bool _isLoading = false;

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = TutorProfileModel(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: _uploadedProfileImageUrl,
        gender: 'Male',
        currentLocation: '',
        permanentLocation: '',
        qualification: '',
        universityOrCollege: '',
        department: '',
        yearOrSemester: '',
        cgpaOrResult: '',
        subjects: [],
        preferredClasses: [],
        teachingExperience: '',
        teachingStyle: '',
        expectedSalary: '',
        availableDays: [],
        preferredArea: '',
        medium: '',
        tutoringMode: 'Offline',
        bio: '',
        achievements: '',
        documentUrl: _uploadedDocumentUrl,
        verificationStatus: 'not_submitted',
        guardianRatingAverage: 0.0,
        guardianTotalReviews: 0,
        adminRating: 0.0,
        adminStatus: 'pending',
        updatedAt: DateTime.now(),
      );

      await _service.saveTutorProfile(profile);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TutorDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label required';
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text =
        FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              input('Full Name', _fullNameController),
              input('Phone', _phoneController),
              input('Email', _emailController),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final url =
                        await _uploadService.pickAndUploadFile(
                      folderName: 'tutor_profile_images',
                      allowedExtensions: [
                        'jpg',
                        'jpeg',
                        'png'
                      ],
                    );

                    if (url != null) {
                      setState(() {
                        _uploadedProfileImageUrl = url;
                      });
                    }
                  },
                  child: const Text('Upload Profile Image'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final url =
                        await _uploadService.pickAndUploadFile(
                      folderName: 'tutor_documents',
                      allowedExtensions: [
                        'jpg',
                        'jpeg',
                        'png',
                        'pdf'
                      ],
                    );

                    if (url != null) {
                      setState(() {
                        _uploadedDocumentUrl = url;
                      });
                    }
                  },
                  child: const Text('Upload Document'),
                ),
              ),

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