import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/screens/chat/chat_list_screen.dart';
import 'package:smart_tutor/screens/guardian/find_tutor_screen.dart';
import 'package:smart_tutor/screens/guardian/guardian_applications_screen.dart';
import 'package:smart_tutor/screens/guardian/guardian_my_requests_screen.dart';
import 'package:smart_tutor/screens/guardian/my_guardian_profile_screen.dart';
import 'package:smart_tutor/screens/guardian/post_tuition_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class GuardianDashboardScreen extends StatelessWidget {
  const GuardianDashboardScreen({super.key});

  static const _bg = Color(0xFFF4F7FB);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _primary = Color(0xFF2563EB);
  static const _border = Color(0xFFE2E8F0);

  Future<void> _logout(BuildContext context) async {
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

  Future<void> _openAdminSupport(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('guardian_profiles')
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
              'Guardian')
          .toString()
          .trim();

      final support = await ChatService.createOrGetAdminSupportChat(
        userId: user.uid,
        userName: name.isEmpty ? 'Guardian' : name,
        userRole: 'guardian',
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

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'name': 'Guardian',
        'posted': 0,
        'applications': 0,
        'requests': 0,
      };
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final profileDoc = await FirebaseFirestore.instance
        .collection('guardian_profiles')
        .doc(user.uid)
        .get();
    final posts = await FirebaseFirestore.instance
        .collection('tuition_posts')
        .where('guardianId', isEqualTo: user.uid)
        .get();
    final applications = await FirebaseFirestore.instance
        .collection('applications')
        .where('guardianId', isEqualTo: user.uid)
        .get();
    final requests = await FirebaseFirestore.instance
        .collection('tutor_requests')
        .where('guardianId', isEqualTo: user.uid)
        .get();

    final userData = userDoc.data() ?? {};
    final profileData = profileDoc.data() ?? {};
    final name = (profileData['fullName'] ?? userData['name'] ?? 'Guardian')
        .toString()
        .trim();

    return {
      'name': name.isEmpty ? 'Guardian' : name,
      'posted': posts.docs.length,
      'applications': applications.docs.length,
      'requests': requests.docs.length,
    };
  }

  Widget _hero(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF164E63)],
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
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: const Icon(
              Icons.family_restroom_rounded,
              color: Colors.white,
              size: 28,
            ),
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
                const SizedBox(height: 5),
                const Text(
                  'Post tuition, compare applicants and manage learning support.',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 13,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? screen,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (onTap != null) {
          onTap();
          return;
        }
        if (screen == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
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
    final List<(IconData, String, String, Color, Widget?)> items = [
      (
        Icons.add_home_work_outlined,
        'Post Tuition',
        'Create a new tuition post',
        const Color(0xFF4F46E5),
        const PostTuitionScreen(),
      ),
      (
        Icons.how_to_reg_outlined,
        'Applications',
        'Review tutor applications',
        const Color(0xFF16A34A),
        const GuardianApplicationsScreen(),
      ),
      (
        Icons.search_rounded,
        'Find Tutor',
        'Browse approved tutors',
        const Color(0xFF2563EB),
        const FindTutorScreen(),
      ),
      (
        Icons.person_outline_rounded,
        'My Profile',
        'Update guardian details',
        const Color(0xFF9333EA),
        const MyGuardianProfileScreen(),
      ),
      (
        Icons.assignment_outlined,
        'Requests',
        'Track old tutor requests',
        const Color(0xFFF59E0B),
        const GuardianMyRequestsScreen(),
      ),
      (
        Icons.chat_bubble_outline,
        'Chats',
        'Message accepted tutors',
        const Color(0xFF0891B2),
        const ChatListScreen(role: 'guardian'),
      ),
      (
        Icons.support_agent_outlined,
        'Need Help?',
        'Chat with admin support',
        const Color(0xFF0F766E),
        null,
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
          context: context,
          icon: item.$1,
          title: item.$2,
          subtitle: item.$3,
          color: item.$4,
          screen: item.$5,
          onTap: item.$5 == null ? () => _openAdminSupport(context) : null,
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Guardian',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: _ink),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadDashboardData(),
        builder: (context, snapshot) {
          final data = snapshot.data ??
              {
                'name': 'Guardian',
                'posted': 0,
                'applications': 0,
                'requests': 0,
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
                              'Posts',
                              '${data['posted']}',
                              Icons.work_outline_rounded,
                              _primary,
                            ),
                            const SizedBox(width: 10),
                            _stat(
                              'Applications',
                              '${data['applications']}',
                              Icons.how_to_reg_outlined,
                              const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 10),
                            _stat(
                              'Requests',
                              '${data['requests']}',
                              Icons.assignment_outlined,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
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
                          'Everything you need to manage tuition in one place.',
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
