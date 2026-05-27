import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/admin/admin_chat_list_screen.dart';
import 'package:smart_tutor/screens/admin/admin_tutor_approval_screen.dart';
import 'package:smart_tutor/screens/admin/admin_users_screen.dart';
import 'package:smart_tutor/screens/admin/tutor_verification_list_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _bg = Color(0xFFF6F8FC);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _primary = Color(0xFF4F46E5);
  static const _border = Color(0xFFE5E7EB);

  Future<void> _logout() async {
    await AuthService.logout();
  }

  Future<Map<String, int>> _loadMetrics() async {
    final results = await Future.wait([
      FirebaseFirestore.instance.collection('users').get(),
      FirebaseFirestore.instance.collection('tutor_profiles').get(),
      FirebaseFirestore.instance.collection('guardian_profiles').get(),
      FirebaseFirestore.instance
          .collection('tutor_profiles')
          .where('adminStatus', isEqualTo: 'pending')
          .get(),
      FirebaseFirestore.instance
          .collection('tuition_posts')
          .where('status', isEqualTo: 'open')
          .get(),
      FirebaseFirestore.instance.collection('verification_payments').get(),
    ]);

    return {
      'users': results[0].docs.length,
      'tutors': results[1].docs.length,
      'guardians': results[2].docs.length,
      'pendingTutors': results[3].docs.length,
      'openTuitions': results[4].docs.length,
      'payments': results[5].docs.length,
    };
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barRow({
    required String label,
    required int value,
    required int max,
    required Color color,
  }) {
    final progress = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphPanel({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _graphSection(Map<String, int> metrics, bool loading) {
    final users = metrics['users'] ?? 0;
    final tutors = metrics['tutors'] ?? 0;
    final guardians = metrics['guardians'] ?? 0;
    final pendingTutors = metrics['pendingTutors'] ?? 0;
    final openTuitions = metrics['openTuitions'] ?? 0;
    final payments = metrics['payments'] ?? 0;
    final activityMax = [
      pendingTutors,
      openTuitions,
      payments,
      1,
    ].reduce((a, b) => a > b ? a : b);

    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final panels = [
          _graphPanel(
            title: 'User Mix',
            subtitle: 'Tutor and guardian profile distribution',
            children: [
              _barRow(
                label: 'Tutors',
                value: tutors,
                max: users,
                color: const Color(0xFF2563EB),
              ),
              _barRow(
                label: 'Guardians',
                value: guardians,
                max: users,
                color: const Color(0xFF0891B2),
              ),
              _barRow(
                label: 'Other Accounts',
                value: (users - tutors - guardians).clamp(0, users),
                max: users,
                color: const Color(0xFF9333EA),
              ),
            ],
          ),
          _graphPanel(
            title: 'Operating Load',
            subtitle: 'Items that need admin attention',
            children: [
              _barRow(
                label: 'Pending Tutor Approval',
                value: pendingTutors,
                max: activityMax,
                color: const Color(0xFFF59E0B),
              ),
              _barRow(
                label: 'Open Tuitions',
                value: openTuitions,
                max: activityMax,
                color: const Color(0xFF16A34A),
              ),
              _barRow(
                label: 'Payment Records',
                value: payments,
                max: activityMax,
                color: const Color(0xFF9333EA),
              ),
            ],
          ),
        ];

        if (!wide) {
          return Column(
            children: [
              panels[0],
              const SizedBox(height: 10),
              panels[1],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: panels[0]),
            const SizedBox(width: 10),
            Expanded(child: panels[1]),
          ],
        );
      },
    );
  }

  Widget _overview() {
    return FutureBuilder<Map<String, int>>(
      future: _loadMetrics(),
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? {};
        final loading = snapshot.connectionState == ConnectionState.waiting;

        String value(String key) => loading ? '-' : '${metrics[key] ?? 0}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22111827),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platform Control Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Monitor users, approvals, tuition activity and safety.',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _metricCard(
                    icon: Icons.people_outline_rounded,
                    label: 'Total Users',
                    value: value('users'),
                    color: _primary,
                  ),
                  _metricCard(
                    icon: Icons.school_outlined,
                    label: 'Tutors',
                    value: value('tutors'),
                    color: const Color(0xFF2563EB),
                  ),
                  _metricCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'Guardians',
                    value: value('guardians'),
                    color: const Color(0xFF0891B2),
                  ),
                  _metricCard(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pending Tutors',
                    value: value('pendingTutors'),
                    color: const Color(0xFFF59E0B),
                  ),
                  _metricCard(
                    icon: Icons.work_outline_rounded,
                    label: 'Open Tuitions',
                    value: value('openTuitions'),
                    color: const Color(0xFF16A34A),
                  ),
                  _metricCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Payment Records',
                    value: value('payments'),
                    color: const Color(0xFF9333EA),
                  ),
                ]
                    .expand((widget) => [widget, const SizedBox(width: 10)])
                    .toList()
                  ..removeLast(),
              ),
            ),
            const SizedBox(height: 14),
            _graphSection(metrics, loading),
          ],
        );
      },
    );
  }

  Widget _operationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Admin',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: _ink),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadMetrics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _overview(),
              const SizedBox(height: 24),
              _sectionTitle(
                'Operations',
                'Review, approve and supervise daily platform activity.',
              ),
              const SizedBox(height: 14),
              _operationCard(
                context: context,
                icon: Icons.people_outline_rounded,
                title: 'Users',
                subtitle: 'View all tutors, guardians and admins',
                color: _primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUsersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _operationCard(
                context: context,
                icon: Icons.verified_user_outlined,
                title: 'Tutor Approval',
                subtitle: 'Approve or reject tutor profiles',
                color: const Color(0xFF16A34A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminTutorApprovalScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _operationCard(
                context: context,
                icon: Icons.payments_outlined,
                title: 'Tutor Verification Payments',
                subtitle: 'Review tutor payment submissions',
                color: const Color(0xFF9333EA),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TutorVerificationListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _operationCard(
                context: context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Guardian Payments',
                subtitle: 'Review guardian payment submissions',
                color: const Color(0xFFF59E0B),
                onTap: () => _showComingSoon(context, 'Guardian Payments'),
              ),
              const SizedBox(height: 10),
              _operationCard(
                context: context,
                icon: Icons.forum_outlined,
                title: 'Chat Monitoring',
                subtitle: 'View guardian and tutor conversations',
                color: const Color(0xFF0891B2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminChatListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
