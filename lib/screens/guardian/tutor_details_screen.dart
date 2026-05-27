import 'package:flutter/material.dart';

class TutorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> tutorData;

  const TutorDetailsScreen({
    super.key,
    required this.tutorData,
  });

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

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFEDE9FE),
            child: Icon(
              icon,
              color: const Color(0xFF4F46E5),
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = _stringValue(tutorData['profileImage'], '');
    final fullName = _stringValue(tutorData['fullName'], 'Unknown Tutor');
    final qualification =
        _stringValue(tutorData['qualification'], 'No qualification added');
    final university =
        _stringValue(tutorData['universityOrCollege'], 'No university added');
    final department =
        _stringValue(tutorData['department'], 'No department added');
    final subjects = _listValue(tutorData['subjects'], 'No subjects added');
    final preferredClasses =
        _listValue(tutorData['preferredClasses'], 'No classes added');
    final experience =
        _stringValue(tutorData['teachingExperience'], 'No experience added');
    final teachingStyle =
        _stringValue(tutorData['teachingStyle'], 'No teaching style added');
    final salary = _stringValue(tutorData['expectedSalary'], 'No salary added');
    final availableDays =
        _listValue(tutorData['availableDays'], 'No days added');
    final preferredArea =
        _stringValue(tutorData['preferredArea'], 'No area added');
    final medium = _stringValue(tutorData['medium'], 'No medium added');
    final tutoringMode =
        _stringValue(tutorData['tutoringMode'], 'No mode added');
    final bio = _stringValue(tutorData['bio'], 'No bio added');
    final achievements =
        _stringValue(tutorData['achievements'], 'No achievements added');
    final gender = _stringValue(tutorData['gender'], 'No gender added');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Tutor Details'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Color(0xFF4F46E5),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    qualification,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _infoTile(
                icon: Icons.person_outline, title: 'Gender', value: gender),
            _infoTile(
                icon: Icons.school_outlined,
                title: 'University / College',
                value: university),
            _infoTile(
                icon: Icons.account_tree_outlined,
                title: 'Department',
                value: department),
            _infoTile(
                icon: Icons.menu_book_outlined,
                title: 'Subjects',
                value: subjects),
            _infoTile(
                icon: Icons.class_outlined,
                title: 'Preferred Classes',
                value: preferredClasses),
            _infoTile(
                icon: Icons.work_outline,
                title: 'Teaching Experience',
                value: experience),
            _infoTile(
                icon: Icons.psychology_outlined,
                title: 'Teaching Style',
                value: teachingStyle),
            _infoTile(
                icon: Icons.attach_money_outlined,
                title: 'Expected Salary',
                value: salary),
            _infoTile(
                icon: Icons.calendar_month_outlined,
                title: 'Available Days',
                value: availableDays),
            _infoTile(
                icon: Icons.location_on_outlined,
                title: 'Preferred Area',
                value: preferredArea),
            _infoTile(
                icon: Icons.language_outlined, title: 'Medium', value: medium),
            _infoTile(
                icon: Icons.computer_outlined,
                title: 'Tutoring Mode',
                value: tutoringMode),
            _infoTile(icon: Icons.info_outline, title: 'Bio', value: bio),
            _infoTile(
                icon: Icons.emoji_events_outlined,
                title: 'Achievements',
                value: achievements),
            const SizedBox(height: 12),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
