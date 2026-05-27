import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/screens/guardian/edit_guardian_profile_screen.dart';

class MyGuardianProfileScreen extends StatelessWidget {
  const MyGuardianProfileScreen({super.key});

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Icon(icon, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stringValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _listValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is List) {
      if (value.isEmpty) return fallback;
      return value.map((e) => e.toString()).join(', ');
    }
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('guardian_profiles')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No profile data found'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                final fullName =
                    _stringValue(data['fullName'], 'No name added');
                final phone =
                    _stringValue(data['phone'], 'No phone added');
                final childName =
                    _stringValue(data['childName'], 'No student added');
                final email =
                    _stringValue(data['email'], 'No email added');
                final address =
                    _stringValue(data['address'], 'No address added');
                final area =
                    _stringValue(data['area'], 'No area added');
                final city =
                    _stringValue(data['city'], 'No city added');
                final childClass =
                    _stringValue(data['childClass'], 'No class added');
                final preferredSubjects = _listValue(
                  data['preferredSubjects'],
                  'No subjects added',
                );
                final preferredTutorGender = _stringValue(
                  data['preferredTutorGender'],
                  'No preference added',
                );
                final preferredTutorType = _stringValue(
                  data['preferredTutorType'],
                  'No tutor type added',
                );
                final budgetRange = _stringValue(
                  data['budgetRange'],
                  'No budget added',
                );
                final preferredSchedule = _stringValue(
                  data['preferredSchedule'],
                  'No schedule added',
                );
                final notes =
                    _stringValue(data['notes'], 'No notes added');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                        ),
                        child: const Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.family_restroom_rounded,
                                size: 36,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Guardian Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your guardian information',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
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

                            if (result == true && context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                      infoTile(
                        icon: Icons.person_outline,
                        title: 'Guardian Name',
                        value: fullName,
                      ),
                      infoTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: phone,
                      ),
                      infoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: email,
                      ),
                      infoTile(
                        icon: Icons.home_outlined,
                        title: 'Address',
                        value: address,
                      ),
                      infoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Area',
                        value: area,
                      ),
                      infoTile(
                        icon: Icons.location_city_outlined,
                        title: 'City',
                        value: city,
                      ),
                      infoTile(
                        icon: Icons.school_outlined,
                        title: 'Student Name',
                        value: childName,
                      ),
                      infoTile(
                        icon: Icons.class_outlined,
                        title: 'Student Class',
                        value: childClass,
                      ),
                      infoTile(
                        icon: Icons.menu_book_outlined,
                        title: 'Preferred Subjects',
                        value: preferredSubjects,
                      ),
                      infoTile(
                        icon: Icons.person_pin_outlined,
                        title: 'Preferred Tutor Gender',
                        value: preferredTutorGender,
                      ),
                      infoTile(
                        icon: Icons.badge_outlined,
                        title: 'Preferred Tutor Type',
                        value: preferredTutorType,
                      ),
                      infoTile(
                        icon: Icons.attach_money_outlined,
                        title: 'Budget Range',
                        value: budgetRange,
                      ),
                      infoTile(
                        icon: Icons.schedule_outlined,
                        title: 'Preferred Schedule',
                        value: preferredSchedule,
                      ),
                      infoTile(
                        icon: Icons.note_alt_outlined,
                        title: 'Notes',
                        value: notes,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}