import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/guardian/tutor_details_screen.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedGender = 'All';
  String _selectedMode = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final search = _searchController.text.trim().toLowerCase();

    final fullName = (data['fullName'] ?? '').toString().toLowerCase();
    final preferredArea = (data['preferredArea'] ?? '').toString().toLowerCase();
    final qualification = (data['qualification'] ?? '').toString().toLowerCase();
    final gender = (data['gender'] ?? '').toString();
    final tutoringMode = (data['tutoringMode'] ?? '').toString();

    final subjects = List<String>.from(data['subjects'] ?? [])
        .join(' ')
        .toLowerCase();

    final genderMatch = _selectedGender == 'All' || gender == _selectedGender;
    final modeMatch = _selectedMode == 'All' || tutoringMode == _selectedMode;

    final searchMatch = search.isEmpty ||
        fullName.contains(search) ||
        preferredArea.contains(search) ||
        qualification.contains(search) ||
        subjects.contains(search);

    return genderMatch && modeMatch && searchMatch;
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTutorCard(BuildContext context, Map<String, dynamic> data) {
    final profileImage = (data['profileImage'] ?? '').toString();
    final fullName = (data['fullName'] ?? 'Unknown Tutor').toString();
    final qualification = (data['qualification'] ?? '').toString();
    final preferredArea = (data['preferredArea'] ?? '').toString();
    final expectedSalary = (data['expectedSalary'] ?? '').toString();
    final tutoringMode = (data['tutoringMode'] ?? '').toString();
    final subjects = List<String>.from(data['subjects'] ?? []);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TutorDetailsScreen(
              tutorData: data,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage:
                  profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
              child: profileImage.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 34,
                      color: Color(0xFF4F46E5),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (qualification.isNotEmpty)
                    Text(
                      qualification,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (subjects.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: subjects.take(3).map((subject) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 10),
                  if (preferredArea.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            preferredArea,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (tutoringMode.isNotEmpty)
                        Text(
                          tutoringMode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      if (expectedSalary.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '৳$expectedSalary',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _approvedTutorsStream() {
    return FirebaseFirestore.instance
        .collection('tutor_profiles')
        .where('adminStatus', isEqualTo: 'approved')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Find Tutor'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, subject, area...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _dropdown(
                      value: _selectedGender,
                      items: const ['All', 'Male', 'Female', 'Other'],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _dropdown(
                      value: _selectedMode,
                      items: const ['All', 'Offline', 'Online', 'Both'],
                      onChanged: (value) {
                        setState(() {
                          _selectedMode = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _approvedTutorsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final tutors = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _matchesSearch(data);
                }).toList();

                if (tutors.isEmpty) {
                  return const Center(
                    child: Text(
                      'No approved tutor found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final data = tutors[index].data() as Map<String, dynamic>;

                    final tutorData = {
                      ...data,
                      'tutorId': tutors[index].id,
                    };

                    return _buildTutorCard(context, tutorData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}