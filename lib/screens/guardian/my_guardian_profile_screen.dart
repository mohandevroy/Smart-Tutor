import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/screens/guardian/edit_guardian_profile_screen.dart';

class MyGuardianProfileScreen extends StatefulWidget {
  const MyGuardianProfileScreen({super.key});

  @override
  State<MyGuardianProfileScreen> createState() =>
      _MyGuardianProfileScreenState();
}

class _MyGuardianProfileScreenState extends State<MyGuardianProfileScreen> {
  // Key to force FutureBuilder to re-fetch on edit
  Key _profileKey = UniqueKey();

  static const _primary = Color(0xFF4F46E5);
  static const _surface = Color(0xFFF8F9FF);
  static const _card = Colors.white;
  static const _textDark = Color(0xFF0F172A);
  static const _textLight = Color(0xFF94A3B8);

  String _stringValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _listValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is List) {
      return value.isEmpty
          ? fallback
          : value.map((e) => e.toString()).join(', ');
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Widget _sectionHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10, left: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
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

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    final isEmpty = value.startsWith('No ');
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 1),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isEmpty
                  ? const Color(0xFFF1F5F9)
                  : _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEmpty ? _textLight : _primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _textLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                    color: isEmpty ? _textLight : _textDark,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Map<String, dynamic>> tiles) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(tiles.length, (i) {
            final t = tiles[i];
            return Column(
              children: [
                _infoTile(
                  icon: t['icon'] as IconData,
                  title: t['title'] as String,
                  value: t['value'] as String,
                  isLast: i == tiles.length - 1,
                ),
                if (i < tiles.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'G';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

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
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
          'My Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 15, color: Color(0xFFDC2626)),
                    SizedBox(width: 5),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : FutureBuilder<List<DocumentSnapshot>>(
              key: _profileKey,
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('guardian_profiles')
                    .doc(user.uid)
                    .get(),
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }

                final profileDoc = snapshot.data?[0];
                final userDoc = snapshot.data?[1];
                final profileData =
                    profileDoc?.data() as Map<String, dynamic>? ?? {};
                final userData = userDoc?.data() as Map<String, dynamic>? ?? {};
                final data = {
                  ...userData,
                  ...profileData,
                };

                final fullName = _stringValue(
                    data['fullName'] ?? data['name'], 'No name added');
                final phone = _stringValue(data['phone'], 'No phone added');
                final childName =
                    _stringValue(data['childName'], 'No student added');
                final email =
                    _stringValue(data['email'] ?? user.email, 'No email added');
                final address =
                    _stringValue(data['address'], 'No address added');
                final area = _stringValue(data['area'], 'No area added');
                final city = _stringValue(data['city'], 'No city added');
                final childClass =
                    _stringValue(data['childClass'], 'No class added');
                final preferredSubjects =
                    _listValue(data['preferredSubjects'], 'No subjects added');
                final preferredTutorGender = _stringValue(
                    data['preferredTutorGender'], 'No preference added');
                final preferredTutorType = _stringValue(
                    data['preferredTutorType'], 'No tutor type added');
                final budgetRange =
                    _stringValue(data['budgetRange'], 'No budget added');
                final preferredSchedule = _stringValue(
                    data['preferredSchedule'], 'No schedule added');
                final notes = _stringValue(data['notes'], 'No notes added');

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── PROFILE HEADER ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4F46E5),
                              Color(0xFF6D28D9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.startsWith('No ')
                                        ? 'Guardian'
                                        : fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Guardian',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    email.startsWith('No ')
                                        ? 'Email not added'
                                        : email,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── EDIT BUTTON ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditGuardianProfileScreen(
                                  fullName: fullName,
                                  phone: phone,
                                  email: email,
                                  address: address,
                                  area: area,
                                  city: city,
                                  childName: childName,
                                  childClass: childClass,
                                  preferredSubjects: preferredSubjects,
                                  preferredTutorGender: preferredTutorGender,
                                  preferredTutorType: preferredTutorType,
                                  budgetRange: budgetRange,
                                  preferredSchedule: preferredSchedule,
                                  notes: notes,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              setState(() {
                                _profileKey = UniqueKey();
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _textDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── SECTION: Personal Info ──
                      _sectionHeader(
                          'PERSONAL INFO', Icons.person_outline_rounded),
                      _infoCard([
                        {
                          'icon': Icons.badge_outlined,
                          'title': 'Full Name',
                          'value': fullName,
                        },
                        {
                          'icon': Icons.phone_outlined,
                          'title': 'Phone Number',
                          'value': phone,
                        },
                        {
                          'icon': Icons.email_outlined,
                          'title': 'Email Address',
                          'value': email,
                        },
                      ]),

                      const SizedBox(height: 14),

                      // ── SECTION: Location ──
                      _sectionHeader('LOCATION', Icons.location_on_outlined),
                      _infoCard([
                        {
                          'icon': Icons.home_outlined,
                          'title': 'Address',
                          'value': address,
                        },
                        {
                          'icon': Icons.near_me_outlined,
                          'title': 'Area',
                          'value': area,
                        },
                        {
                          'icon': Icons.location_city_outlined,
                          'title': 'City',
                          'value': city,
                        },
                      ]),

                      const SizedBox(height: 14),

                      // ── SECTION: Student Info ──
                      _sectionHeader('STUDENT INFO', Icons.school_outlined),
                      _infoCard([
                        {
                          'icon': Icons.face_outlined,
                          'title': 'Student Name',
                          'value': childName,
                        },
                        {
                          'icon': Icons.class_outlined,
                          'title': 'Class / Grade',
                          'value': childClass,
                        },
                        {
                          'icon': Icons.menu_book_outlined,
                          'title': 'Preferred Subjects',
                          'value': preferredSubjects,
                        },
                      ]),

                      const SizedBox(height: 14),

                      // ── SECTION: Tutor Preferences ──
                      _sectionHeader('TUTOR PREFERENCES', Icons.tune_rounded),
                      _infoCard([
                        {
                          'icon': Icons.person_pin_outlined,
                          'title': 'Preferred Gender',
                          'value': preferredTutorGender,
                        },
                        {
                          'icon': Icons.workspace_premium_outlined,
                          'title': 'Preferred Type',
                          'value': preferredTutorType,
                        },
                        {
                          'icon': Icons.payments_outlined,
                          'title': 'Budget Range',
                          'value': budgetRange,
                        },
                        {
                          'icon': Icons.schedule_outlined,
                          'title': 'Preferred Schedule',
                          'value': preferredSchedule,
                        },
                      ]),

                      const SizedBox(height: 14),

                      // ── SECTION: Notes ──
                      _sectionHeader(
                          'ADDITIONAL NOTES', Icons.note_alt_outlined),
                      _infoCard([
                        {
                          'icon': Icons.format_quote_rounded,
                          'title': 'Notes',
                          'value': notes,
                        },
                      ]),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
