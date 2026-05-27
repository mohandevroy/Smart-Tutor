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

class _EditGuardianProfileScreenState extends State<EditGuardianProfileScreen> {
  // ── Controllers ──
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

  // ── Theme constants ──
  static const _primary = Color(0xFF4F46E5);
  static const _surface = Color(0xFFF8F9FF);
  static const _textDark = Color(0xFF0F172A);
  static const _textMid = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);
  static const _border = Color(0xFFE2E8F0);
  static const _cardBg = Colors.white;

  String _dropdownValueOrDefault(String value, List<String> allowedValues) {
    return allowedValues.contains(value) ? value : allowedValues.first;
  }

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

    _preferredTutorGender = _dropdownValueOrDefault(
      widget.preferredTutorGender,
      ['Any', 'Male', 'Female'],
    );
    _preferredTutorType = _dropdownValueOrDefault(
      widget.preferredTutorType,
      ['Any', 'University Student', 'Professional Teacher'],
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

  // ── Shared InputDecoration ──
  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _textMid,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: _textLight,
        fontSize: 13.5,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: _primary, size: 18),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 46,
        minHeight: 46,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  // ── Section header ──
  Widget _sectionHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 15),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: _primary.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper for grouped fields ──
  Widget _fieldCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: children,
      ),
    );
  }

  // ── Text field with spacing ──
  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14.5,
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(label, icon, hint: hint),
      ),
    );
  }

  // ── Dropdown field ──
  Widget _dropdownField<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: _inputDecoration(label, icon),
        style: const TextStyle(
          fontSize: 14.5,
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _textMid,
        ),
        items: items,
        onChanged: onChanged,
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
      _showSnackBar(
        'Required fields are empty',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('guardian_profiles')
          .doc(user.uid)
          .set({
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
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileCompleted': true,
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      _showSnackBar('Profile updated successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: _textDark,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top info banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _primary.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Fields marked with * are required.',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── SECTION: Personal Info ──
            _sectionHeader('PERSONAL INFO', Icons.person_outline_rounded),
            _fieldCard([
              _textField(
                _fullNameController,
                'Full Name *',
                Icons.badge_outlined,
                hint: 'e.g. Rahim Uddin',
              ),
              _textField(
                _phoneController,
                'Phone Number *',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hint: '01XXXXXXXXX',
              ),
              _textField(
                _emailController,
                'Email Address *',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                hint: 'example@mail.com',
                isLast: true,
              ),
            ]),

            // ── SECTION: Location ──
            _sectionHeader('LOCATION', Icons.location_on_outlined),
            _fieldCard([
              _textField(
                _addressController,
                'Address',
                Icons.home_outlined,
                hint: 'House / Road / Block',
              ),
              _textField(
                _areaController,
                'Area',
                Icons.near_me_outlined,
                hint: 'e.g. Mirpur, Uttara',
              ),
              _textField(
                _cityController,
                'City',
                Icons.location_city_outlined,
                hint: 'e.g. Dhaka',
                isLast: true,
              ),
            ]),

            // ── SECTION: Student Info ──
            _sectionHeader('STUDENT INFO', Icons.school_outlined),
            _fieldCard([
              _textField(
                _childNameController,
                'Student Name *',
                Icons.face_outlined,
                hint: 'Student\'s full name',
              ),
              _textField(
                _childClassController,
                'Class / Grade',
                Icons.class_outlined,
                hint: 'e.g. Class 8, HSC 1st Year',
                isLast: true,
              ),
            ]),

            // ── SECTION: Tutor Preferences ──
            _sectionHeader('TUTOR PREFERENCES', Icons.tune_rounded),
            _fieldCard([
              _textField(
                _preferredSubjectsController,
                'Preferred Subjects',
                Icons.menu_book_outlined,
                hint: 'Math, Physics, English (comma separated)',
              ),
              _dropdownField<String>(
                value: _preferredTutorGender,
                label: 'Preferred Tutor Gender',
                icon: Icons.person_pin_outlined,
                items: const [
                  DropdownMenuItem(value: 'Any', child: Text('Any')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _preferredTutorGender = v!),
              ),
              _dropdownField<String>(
                value: _preferredTutorType,
                label: 'Preferred Tutor Type',
                icon: Icons.workspace_premium_outlined,
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
                onChanged: (v) => setState(() => _preferredTutorType = v!),
                isLast: true,
              ),
            ]),

            // ── SECTION: Budget & Schedule ──
            _sectionHeader('BUDGET & SCHEDULE', Icons.payments_outlined),
            _fieldCard([
              _textField(
                _budgetRangeController,
                'Budget Range',
                Icons.payments_outlined,
                hint: 'e.g. 3000–5000 BDT/month',
              ),
              _textField(
                _preferredScheduleController,
                'Preferred Schedule',
                Icons.schedule_outlined,
                hint: 'e.g. Weekends, Fri–Sat 4–6 PM',
                isLast: true,
              ),
            ]),

            // ── SECTION: Notes ──
            _sectionHeader('ADDITIONAL NOTES', Icons.note_alt_outlined),
            _fieldCard([
              _textField(
                _notesController,
                'Notes',
                Icons.format_quote_rounded,
                maxLines: 4,
                hint: 'Any special requirements or preferences...',
                isLast: true,
              ),
            ]),

            const SizedBox(height: 28),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withOpacity(0.5),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
