import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/screens/tutor/edit_tutor_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Future<List<DocumentSnapshot>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = AuthService.currentUser;
    if (user == null) return;

    _profileFuture = Future.wait([
      FirebaseFirestore.instance
          .collection('tutor_profiles')
          .doc(user.uid)
          .get(),
      FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
    ]);
  }

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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
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

  ImageProvider? _profileImageProvider(String url) {
    if (url.trim().isEmpty) return null;
    return NetworkImage(url);
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _ratingSummary({
    required double average,
    required int totalReviews,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFBBF24),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  average == 0 ? 'No rating yet' : average.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  totalReviews == 0
                      ? 'Guardian ratings will appear here'
                      : '$totalReviews guardian review${totalReviews == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < average.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFBBF24),
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> data) {
    final guardianName = _stringValue(data['guardianName'], 'Guardian');
    final comment = _stringValue(data['comment'], 'No written feedback');
    final rating = _doubleValue(data['rating']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFFEFF6FF),
                child: Icon(Icons.family_restroom_rounded,
                    color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  guardianName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewsSection(String tutorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('tutorId', isEqualTo: tutorId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['updatedAt'];
          final bTime = bData['updatedAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Guardian Reviews',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'No reviews yet. After guardians rate you, feedback will show here.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              )
            else
              ...docs.map((doc) {
                return _reviewCard(doc.data() as Map<String, dynamic>);
              }),
          ],
        );
      },
    );
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
          : FutureBuilder<List<DocumentSnapshot>>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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

                final profileImage = _stringValue(data['profileImage'], '');
                final fullName = _stringValue(
                    data['fullName'] ?? data['name'], 'No name added');
                final phone = _stringValue(data['phone'], 'No phone added');
                final email =
                    _stringValue(data['email'] ?? user.email, 'No email added');
                final gender = _stringValue(data['gender'], 'No gender added');
                final currentLocation = _stringValue(
                  data['currentLocation'],
                  'No current location added',
                );
                final permanentLocation = _stringValue(
                  data['permanentLocation'],
                  'No permanent location added',
                );
                final qualification = _stringValue(
                  data['qualification'],
                  'No qualification added',
                );
                final universityOrCollege = _stringValue(
                  data['universityOrCollege'],
                  'No university added',
                );
                final department = _stringValue(
                  data['department'],
                  'No department added',
                );
                final yearOrSemester = _stringValue(
                  data['yearOrSemester'],
                  'No year/semester added',
                );
                final cgpaOrResult = _stringValue(
                  data['cgpaOrResult'],
                  'No result added',
                );
                final subjects = _listValue(
                  data['subjects'],
                  'No subjects added',
                );
                final preferredClasses = _listValue(
                  data['preferredClasses'],
                  'No classes added',
                );
                final teachingExperience = _stringValue(
                  data['teachingExperience'],
                  'No experience added',
                );
                final teachingStyle = _stringValue(
                  data['teachingStyle'],
                  'No teaching style added',
                );
                final expectedSalary = _stringValue(
                  data['expectedSalary'],
                  'No salary added',
                );
                final availableDays = _listValue(
                  data['availableDays'],
                  'No days added',
                );
                final preferredArea = _stringValue(
                  data['preferredArea'],
                  'No preferred area added',
                );
                final medium = _stringValue(data['medium'], 'No medium added');
                final tutoringMode = _stringValue(
                  data['tutoringMode'],
                  'No tutoring mode added',
                );
                final bio = _stringValue(data['bio'], 'No bio added');
                final achievements = _stringValue(
                  data['achievements'],
                  'No achievements added',
                );
                final documentUrl = _stringValue(
                  data['documentUrl'],
                  'No document added',
                );
                final averageRating =
                    _doubleValue(data['guardianRatingAverage']);
                final totalReviews = _intValue(data['guardianTotalReviews']);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F172A), Color(0xFF2563EB)],
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _profileImageProvider(profileImage),
                              child: profileImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color(0xFF4F46E5),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Profile, rating and teaching credentials',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ratingSummary(
                        average: averageRating,
                        totalReviews: totalReviews,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTutorProfileScreen(
                                  profileImage: profileImage,
                                  fullName: fullName,
                                  phone: phone,
                                  email: email,
                                  gender: gender,
                                  currentLocation: currentLocation,
                                  permanentLocation: permanentLocation,
                                  qualification: qualification,
                                  universityOrCollege: universityOrCollege,
                                  department: department,
                                  yearOrSemester: yearOrSemester,
                                  cgpaOrResult: cgpaOrResult,
                                  subjects: subjects,
                                  preferredClasses: preferredClasses,
                                  teachingExperience: teachingExperience,
                                  teachingStyle: teachingStyle,
                                  expectedSalary: expectedSalary,
                                  availableDays: availableDays,
                                  preferredArea: preferredArea,
                                  medium: medium,
                                  tutoringMode: tutoringMode,
                                  bio: bio,
                                  achievements: achievements,
                                  documentUrl: documentUrl,
                                ),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                _loadProfile();
                              });
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      infoTile(
                          icon: Icons.person_outline,
                          title: 'Full Name',
                          value: fullName),
                      infoTile(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          value: phone),
                      infoTile(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: email),
                      infoTile(
                          icon: Icons.people_outline,
                          title: 'Gender',
                          value: gender),
                      infoTile(
                          icon: Icons.location_on_outlined,
                          title: 'Current Location',
                          value: currentLocation),
                      infoTile(
                          icon: Icons.home_outlined,
                          title: 'Permanent Location',
                          value: permanentLocation),
                      infoTile(
                          icon: Icons.school_outlined,
                          title: 'Qualification',
                          value: qualification),
                      infoTile(
                          icon: Icons.account_balance_outlined,
                          title: 'University / College',
                          value: universityOrCollege),
                      infoTile(
                          icon: Icons.apartment_outlined,
                          title: 'Department',
                          value: department),
                      infoTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Year / Semester',
                          value: yearOrSemester),
                      infoTile(
                          icon: Icons.grade_outlined,
                          title: 'CGPA / Result',
                          value: cgpaOrResult),
                      infoTile(
                          icon: Icons.menu_book_outlined,
                          title: 'Subjects',
                          value: subjects),
                      infoTile(
                          icon: Icons.class_outlined,
                          title: 'Preferred Classes',
                          value: preferredClasses),
                      infoTile(
                          icon: Icons.work_outline,
                          title: 'Teaching Experience',
                          value: teachingExperience),
                      infoTile(
                          icon: Icons.psychology_outlined,
                          title: 'Teaching Style',
                          value: teachingStyle),
                      infoTile(
                          icon: Icons.attach_money_outlined,
                          title: 'Expected Salary',
                          value: expectedSalary),
                      infoTile(
                          icon: Icons.schedule_outlined,
                          title: 'Available Days',
                          value: availableDays),
                      infoTile(
                          icon: Icons.map_outlined,
                          title: 'Preferred Area',
                          value: preferredArea),
                      infoTile(
                          icon: Icons.language_outlined,
                          title: 'Medium',
                          value: medium),
                      infoTile(
                          icon: Icons.computer_outlined,
                          title: 'Tutoring Mode',
                          value: tutoringMode),
                      infoTile(
                          icon: Icons.person_pin_outlined,
                          title: 'Bio',
                          value: bio),
                      infoTile(
                          icon: Icons.emoji_events_outlined,
                          title: 'Achievements',
                          value: achievements),
                      infoTile(
                          icon: Icons.description_outlined,
                          title: 'Document URL',
                          value: documentUrl),
                      _reviewsSection(user.uid),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
