import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/screens/chat/chat_list_screen.dart';
import 'package:smart_tutor/screens/tutor/my_applications_screen.dart';
import 'package:smart_tutor/screens/tutor/my_profile_screen.dart';
import 'package:smart_tutor/screens/tutor/payment_status_screen.dart';
import 'package:smart_tutor/screens/tutor/tuition_feed_screen.dart';
import 'package:smart_tutor/screens/tutor/tutor_requests_screen.dart';
import 'package:smart_tutor/screens/tutor/tutor_verification_payment_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  static const _bg = Color(0xFFF4F7FB);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _primary = Color(0xFF2563EB);
  static const _border = Color(0xFFE2E8F0);

  Future<void> _logout() async {
    await AuthService.logout();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'name': 'Tutor',
        'adminStatus': 'pending',
        'profileImage': '',
        'requests': 0,
        'applications': 0,
        'payments': 0,
      };
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final profileDoc = await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .get();
    final requests = await FirebaseFirestore.instance
        .collection('tutor_requests')
        .where('tutorId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();
    final applications = await FirebaseFirestore.instance
        .collection('applications')
        .where('tutorId', isEqualTo: user.uid)
        .get();
    final payments = await FirebaseFirestore.instance
        .collection('verification_payments')
        .where('tutorId', isEqualTo: user.uid)
        .get();

    final userData = userDoc.data() ?? {};
    final profileData = profileDoc.data() ?? {};
    final name = (profileData['fullName'] ?? userData['name'] ?? 'Tutor')
        .toString()
        .trim();

    return {
      'name': name.isEmpty ? 'Tutor' : name,
      'adminStatus': (profileData['adminStatus'] ?? 'pending').toString(),
      'profileImage': (profileData['profileImage'] ?? '').toString(),
      'requests': requests.docs.length,
      'applications': applications.docs.length,
      'payments': payments.docs.length,
    };
  }

  Future<bool> _isTutorApproved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .get();
    final status = (doc.data()?['adminStatus'] ?? '').toString().toLowerCase();
    return status == 'approved';
  }

  Future<void> _openAdminSupport(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('tutor_profiles')
          .doc(user.uid)
          .get();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final profileData = profileDoc.data() ?? {};
      final userData = userDoc.data() ?? {};
      final name = (profileData['fullName'] ??
              userData['name'] ??
              user.displayName ??
              user.email ??
              'Tutor')
          .toString()
          .trim();

      final support = await ChatService.createOrGetAdminSupportChat(
        userId: user.uid,
        userName: name.isEmpty ? 'Tutor' : name,
        userRole: 'tutor',
      );

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: support['chatId']!,
            receiverId: support['adminId']!,
            receiverName: support['adminName']!,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open admin support: $e')),
      );
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openTuitionFeed(BuildContext context) async {
    final approved = await _isTutorApproved();
    if (!context.mounted) return;
    if (!approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin approval required before viewing Tuition Feed'),
        ),
      );
      return;
    }
    _open(context, const TuitionFeedScreen());
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _hero(Map<String, dynamic> data) {
    final status = data['adminStatus'].toString();
    final color = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: data['profileImage'].toString().trim().isEmpty
                ? null
                : NetworkImage(data['profileImage'].toString()),
            child: data['profileImage'].toString().trim().isEmpty
                ? const Icon(Icons.school_rounded, color: _primary, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ADMIN ${status.toUpperCase()}',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x070F172A),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12.3,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final items = [
      (
        Icons.school_outlined,
        'Tuition Feed',
        'Browse and apply to jobs',
        const Color(0xFF4F46E5),
        () => _openTuitionFeed(context),
      ),
      (
        Icons.assignment_outlined,
        'Applications',
        'Track your offers',
        const Color(0xFF16A34A),
        () => _open(context, const MyApplicationsScreen()),
      ),
      (
        Icons.person_outline_rounded,
        'My Profile',
        'Edit tutor details',
        const Color(0xFF2563EB),
        () => _open(context, const MyProfileScreen()),
      ),
      (
        Icons.verified_outlined,
        'Verification',
        'Submit payment proof',
        const Color(0xFF9333EA),
        () => _open(context, const TutorVerificationPaymentScreen()),
      ),
      (
        Icons.receipt_long_outlined,
        'Payment Status',
        'Check verification',
        const Color(0xFFF59E0B),
        () => _open(context, const PaymentStatusScreen()),
      ),
      (
        Icons.chat_bubble_outline,
        'Chats',
        'Message guardians',
        const Color(0xFF0891B2),
        () => _open(context, const ChatListScreen(role: 'tutor')),
      ),
      (
        Icons.mark_email_unread_outlined,
        'Requests',
        'Old guardian requests',
        const Color(0xFFDC2626),
        () => _open(context, const TutorRequestsScreen()),
      ),
      (
        Icons.support_agent_outlined,
        'Need Help?',
        'Chat with admin support',
        const Color(0xFF0F766E),
        () => _openAdminSupport(context),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 132,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _actionCard(
          icon: item.$1,
          title: item.$2,
          subtitle: item.$3,
          color: item.$4,
          onTap: item.$5,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Tutor',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: _ink),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadDashboardData(),
        builder: (context, snapshot) {
          final data = snapshot.data ??
              {
                'name': 'Tutor',
                'adminStatus': 'pending',
                'profileImage': '',
                'requests': 0,
                'applications': 0,
                'payments': 0,
              };

          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 900 ? 1260.0 : 520.0;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(data),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _stat(
                              'Requests',
                              '${data['requests']}',
                              Icons.mark_email_unread_outlined,
                              _primary,
                            ),
                            const SizedBox(width: 10),
                            _stat(
                              'Applications',
                              '${data['applications']}',
                              Icons.assignment_outlined,
                              const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 10),
                            _stat(
                              'Payments',
                              '${data['payments']}',
                              Icons.receipt_long_outlined,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Workspace',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Manage profile, applications, verification and messages.',
                          style: TextStyle(color: _muted, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        _actions(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
