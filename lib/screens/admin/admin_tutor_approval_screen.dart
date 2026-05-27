import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminTutorApprovalScreen extends StatelessWidget {
  const AdminTutorApprovalScreen({super.key});

  Future<void> _updateStatus({
    required BuildContext context,
    required String tutorId,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('tutor_profiles')
          .doc(tutorId)
          .update({
        'adminStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor $status successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _listText(dynamic value, String fallback) {
    if (value == null) return fallback;

    if (value is List) {
      if (value.isEmpty) return fallback;
      return value.map((e) => e.toString()).join(', ');
    }

    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  Color _statusColor(String status) {
    if (status == 'approved') return const Color(0xFF16A34A);
    if (status == 'rejected') return const Color(0xFFDC2626);
    return const Color(0xFFF59E0B);
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tutorCard({
    required BuildContext context,
    required String tutorId,
    required Map<String, dynamic> data,
  }) {
    final profileImage = _text(data['profileImage'], '');
    final fullName = _text(data['fullName'], 'Unknown Tutor');
    final phone = _text(data['phone'], 'No phone');
    final email = _text(data['email'], 'No email');
    final gender = _text(data['gender'], 'No gender');
    final qualification = _text(data['qualification'], 'No qualification');
    final university = _text(data['universityOrCollege'], 'No university');
    final department = _text(data['department'], 'No department');
    final subjects = _listText(data['subjects'], 'No subjects');
    final area = _text(data['preferredArea'], 'No area');
    final salary = _text(data['expectedSalary'], 'No salary');
    final status = _text(data['adminStatus'], 'pending').toLowerCase();

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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFEDE9FE),
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF4F46E5),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _info('Phone', phone),
          _info('Email', email),
          _info('Gender', gender),
          _info('Qualification', qualification),
          _info('University', university),
          _info('Department', department),
          _info('Subjects', subjects),
          _info('Area', area),
          _info('Salary', salary),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: status == 'rejected'
                      ? null
                      : () {
                          _updateStatus(
                            context: context,
                            tutorId: tutorId,
                            status: 'rejected',
                          );
                        },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: status == 'approved'
                      ? null
                      : () {
                          _updateStatus(
                            context: context,
                            tutorId: tutorId,
                            status: 'approved',
                          );
                        },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Approve',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Tutor Approval'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tutor_profiles')
            .snapshots(),
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

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No tutor profile found',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final tutorId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;

              return _tutorCard(
                context: context,
                tutorId: tutorId,
                data: data,
              );
            },
          );
        },
      ),
    );
  }
}