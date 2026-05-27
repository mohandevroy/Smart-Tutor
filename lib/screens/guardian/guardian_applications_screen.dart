import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/core/constants/app_collections.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/tutor_rating_service.dart';
import 'package:smart_tutor/theme/app_theme.dart';

class GuardianApplicationsScreen extends StatefulWidget {
  const GuardianApplicationsScreen({super.key});

  @override
  State<GuardianApplicationsScreen> createState() =>
      _GuardianApplicationsScreenState();
}

class _GuardianApplicationsScreenState
    extends State<GuardianApplicationsScreen> {
  String _selectedPostId = 'all';

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  List<String> _strings(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? [] : [text];
  }

  String _listText(dynamic value, String fallback) {
    final items = _strings(value);
    return items.isEmpty ? _text(value, fallback) : items.join(', ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'guardian_accepted':
        return AppTheme.primary;
      case 'confirmed':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.danger;
      default:
        return AppTheme.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'guardian_accepted':
        return 'WAITING TUTOR';
      case 'confirmed':
        return 'CONFIRMED';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String applicationId,
    required String status,
    String? tuitionPostId,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final appRef = FirebaseFirestore.instance
          .collection(AppCollections.applications)
          .doc(applicationId);

      batch.update(appRef, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (status == 'guardian_accepted' &&
          tuitionPostId != null &&
          tuitionPostId.isNotEmpty) {
        final postRef = FirebaseFirestore.instance
            .collection(AppCollections.tuitionPosts)
            .doc(tuitionPostId);
        batch.update(postRef, {
          'status': 'offered',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application ${_statusLabel(status)}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Future<void> _showRatingDialog(
    BuildContext context,
    _TutorCandidate candidate,
  ) async {
    final commentController = TextEditingController();
    var rating = 5.0;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Rate Tutor',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text(candidate.application['tutorName'], 'Tutor'),
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setDialogState(() => rating = starValue.toDouble());
                        },
                        icon: Icon(
                          starValue <= rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Short feedback',
                      hintText: 'Share your experience',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _submitRating(
                      context: context,
                      candidate: candidate,
                      rating: rating,
                      comment: commentController.text,
                    );
                  },
                  child: const Text('Save Rating'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  Future<void> _submitRating({
    required BuildContext context,
    required _TutorCandidate candidate,
    required double rating,
    required String comment,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final tutorId = _text(candidate.application['tutorId'], '');
    if (tutorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutor information missing')),
      );
      return;
    }

    try {
      await TutorRatingService.rateTutor(
        tutorId: tutorId,
        guardianId: user.uid,
        guardianName: _text(candidate.application['guardianName'], 'Guardian'),
        applicationId: candidate.applicationId,
        rating: rating,
        comment: comment,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutor rating saved')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating failed: $e')),
      );
    }
  }

  Future<List<_TutorCandidate>> _buildCandidates(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final candidates = <_TutorCandidate>[];

    for (final doc in docs) {
      final application = doc.data() as Map<String, dynamic>;
      final tutorId = _text(application['tutorId'], '');
      Map<String, dynamic> profile = {};

      if (tutorId.isNotEmpty) {
        final profileDoc = await FirebaseFirestore.instance
            .collection(AppCollections.tutorProfiles)
            .doc(tutorId)
            .get();
        profile = profileDoc.data() ?? {};
      }

      candidates.add(
        _TutorCandidate(
          applicationId: doc.id,
          application: application,
          profile: profile,
          score: _scoreCandidate(application, profile),
        ),
      );
    }

    candidates.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      final aTime = a.application['createdAt'];
      final bTime = b.application['createdAt'];
      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }
      return 0;
    });

    return candidates;
  }

  int _scoreCandidate(
    Map<String, dynamic> application,
    Map<String, dynamic> profile,
  ) {
    var score = 35;

    final postSubjects = _strings(application['subjects'])
        .map((item) => item.toLowerCase())
        .toSet();
    final tutorSubjects = [
      ..._strings(application['tutorSubjects']),
      ..._strings(profile['subjects']),
    ].map((item) => item.toLowerCase()).toSet();

    if (postSubjects.isNotEmpty && tutorSubjects.isNotEmpty) {
      final matches =
          postSubjects.where((subject) => tutorSubjects.contains(subject));
      score += math.min(25, matches.length * 9);
    }

    final postArea = _text(application['area'], '').toLowerCase();
    final tutorArea = [
      _text(profile['preferredArea'], ''),
      _text(profile['currentLocation'], ''),
    ].join(' ').toLowerCase();
    if (postArea.isNotEmpty && tutorArea.contains(postArea)) score += 10;

    final postMode = _text(application['tuitionMode'], '').toLowerCase();
    final tutorMode = _text(profile['tutoringMode'], '').toLowerCase();
    if (postMode.isNotEmpty && (tutorMode == postMode || tutorMode == 'both')) {
      score += 8;
    }

    if (_text(profile['verificationStatus'], '').toLowerCase() == 'approved' ||
        _text(profile['adminStatus'], '').toLowerCase() == 'approved') {
      score += 8;
    }

    if (_text(profile['teachingExperience'], '').isNotEmpty) score += 5;
    if (_text(profile['qualification'], '').isNotEmpty) score += 4;
    if (_strings(profile['availableDays']).isNotEmpty) score += 3;

    final guardianRating =
        double.tryParse(_text(profile['guardianRatingAverage'], '0')) ?? 0;
    final adminRating =
        double.tryParse(_text(profile['adminRating'], '0')) ?? 0;
    score += math.min(7, (guardianRating + adminRating).round());

    return score.clamp(0, 100);
  }

  Map<String, List<_TutorCandidate>> _groupByPost(
    List<_TutorCandidate> candidates,
  ) {
    final groups = <String, List<_TutorCandidate>>{};
    for (final candidate in candidates) {
      final postId = _text(candidate.application['tuitionPostId'], 'unknown');
      groups.putIfAbsent(postId, () => []).add(candidate);
    }
    return groups;
  }

  String _postTitle(List<_TutorCandidate> group) {
    if (group.isEmpty) return 'Tuition post';
    final data = group.first.application;
    final studentClass = _text(data['studentClass'], 'Class not added');
    final subjects = _listText(data['subjects'], 'Subjects not added');
    return '$studentClass • $subjects';
  }

  Widget _metric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppTheme.textLight),
          const SizedBox(width: 8),
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _candidateCard(
    BuildContext context,
    _TutorCandidate candidate,
    int index,
  ) {
    final data = candidate.application;
    final profile = candidate.profile;
    final status = _text(data['status'], 'pending').toLowerCase();
    final statusColor = _statusColor(status);
    final profileImage = _text(profile['profileImage'], '');
    final name = _text(data['tutorName'] ?? profile['fullName'], 'Tutor');
    final qualification = _text(profile['qualification'], 'No qualification');
    final scoreColor = candidate.score >= 75
        ? AppTheme.success
        : candidate.score >= 55
            ? AppTheme.primary
            : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: index == 0 ? AppTheme.primary : AppTheme.border,
          width: index == 0 ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                child: profileImage.isEmpty
                    ? const Icon(Icons.person, color: AppTheme.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (index == 0) _chip('BEST MATCH', AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qualification,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _metric('Match', '${candidate.score}%', scoreColor),
              const SizedBox(width: 8),
              _metric(
                'Rating',
                _text(profile['guardianRatingAverage'], '0'),
                const Color(0xFF7C2D12),
              ),
              const SizedBox(width: 8),
              _metric(
                'Reviews',
                _text(profile['guardianTotalReviews'], '0'),
                const Color(0xFF0F766E),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.menu_book_outlined,
            'Subjects',
            _listText(
              profile['subjects'] ?? data['tutorSubjects'],
              'No subjects',
            ),
          ),
          _infoRow(
            Icons.location_on_outlined,
            'Area',
            _text(profile['preferredArea'], _text(data['area'], 'No area')),
          ),
          _infoRow(
            Icons.payments_outlined,
            'Salary',
            _text(profile['expectedSalary'], _text(data['budgetRange'], 'N/A')),
          ),
          _infoRow(
            Icons.schedule_outlined,
            'Available',
            _listText(profile['availableDays'], 'No days added'),
          ),
          _infoRow(
            Icons.phone_outlined,
            'Phone',
            _text(data['tutorPhone'] ?? profile['phone'], 'No phone'),
          ),
          const Divider(height: 20),
          Row(
            children: [
              _chip(_statusLabel(status), statusColor),
              const Spacer(),
              if (status == 'pending') ...[
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(
                      context: context,
                      applicationId: candidate.applicationId,
                      status: 'rejected',
                    ),
                    icon: const Icon(Icons.close, size: 17),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      minimumSize: const Size(92, 40),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(
                      context: context,
                      applicationId: candidate.applicationId,
                      status: 'guardian_accepted',
                      tuitionPostId: _text(data['tuitionPostId'], ''),
                    ),
                    icon: const Icon(Icons.check, size: 17),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(96, 40),
                      backgroundColor: AppTheme.success,
                    ),
                  ),
                ),
              ] else if (status == 'guardian_accepted' ||
                  status == 'confirmed') ...[
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _showRatingDialog(context, candidate),
                    icon: const Icon(Icons.star_rounded, size: 17),
                    label: const Text('Rate'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(92, 40),
                      backgroundColor: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _postFilter(Map<String, List<_TutorCandidate>> groups) {
    final entries = groups.entries.toList();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final postId = isAll ? 'all' : entries[index - 1].key;
          final selected = _selectedPostId == postId;
          final label = isAll
              ? 'All applicants'
              : '${_postTitle(entries[index - 1].value)} (${entries[index - 1].value.length})';

          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _selectedPostId = postId),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected ? AppTheme.primary : AppTheme.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _comparisonPanel(List<_TutorCandidate> candidates) {
    final best = candidates.isEmpty ? null : candidates.first;
    final visible = candidates.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutor comparison',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      best == null
                          ? 'Choose a post to compare applicants.'
                          : '${_text(best.application['tutorName'], 'Tutor')} is currently the strongest match.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (visible.length > 1) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                dataTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                columns: const [
                  DataColumn(label: Text('Tutor')),
                  DataColumn(label: Text('Match')),
                  DataColumn(label: Text('Subjects')),
                  DataColumn(label: Text('Experience')),
                  DataColumn(label: Text('Salary')),
                ],
                rows: visible.map((candidate) {
                  final profile = candidate.profile;
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        _text(candidate.application['tutorName'], 'Tutor'),
                      )),
                      DataCell(Text('${candidate.score}%')),
                      DataCell(Text(
                        _listText(
                          profile['subjects'] ??
                              candidate.application['tutorSubjects'],
                          'N/A',
                        ),
                      )),
                      DataCell(Text(
                        _text(profile['teachingExperience'], 'N/A'),
                      )),
                      DataCell(Text(
                        _text(profile['expectedSalary'], 'N/A'),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.how_to_reg_outlined,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tutor Applications'),
      ),
      body: user == null
          ? _emptyState('User not logged in', 'Please login to continue.')
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppCollections.applications)
                  .where('guardianId', isEqualTo: user.uid)
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
                  return _emptyState(
                    'No tutor applications yet',
                    'When tutors apply to your posts, they will appear here.',
                  );
                }

                return FutureBuilder<List<_TutorCandidate>>(
                  future: _buildCandidates(docs),
                  builder: (context, candidatesSnapshot) {
                    if (candidatesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final candidates = candidatesSnapshot.data ?? [];
                    final groups = _groupByPost(candidates);
                    if (_selectedPostId != 'all' &&
                        !groups.containsKey(_selectedPostId)) {
                      _selectedPostId = 'all';
                    }

                    final visibleCandidates = _selectedPostId == 'all'
                        ? candidates
                        : groups[_selectedPostId] ?? [];
                    final pendingCount = candidates
                        .where((candidate) =>
                            _text(candidate.application['status'], 'pending')
                                .toLowerCase() ==
                            'pending')
                        .length;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth =
                            constraints.maxWidth >= 900 ? 1040.0 : 560.0;

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              children: [
                                Row(
                                  children: [
                                    _metric(
                                      'Applicants',
                                      '${candidates.length}',
                                      AppTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    _metric(
                                      'Pending',
                                      '$pendingCount',
                                      AppTheme.warning,
                                    ),
                                    const SizedBox(width: 8),
                                    _metric(
                                      'Posts',
                                      '${groups.length}',
                                      AppTheme.secondary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _postFilter(groups),
                                const SizedBox(height: 14),
                                _comparisonPanel(visibleCandidates),
                                const SizedBox(height: 14),
                                ...visibleCandidates.asMap().entries.map(
                                      (entry) => _candidateCard(
                                        context,
                                        entry.value,
                                        entry.key,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _TutorCandidate {
  final String applicationId;
  final Map<String, dynamic> application;
  final Map<String, dynamic> profile;
  final int score;

  const _TutorCandidate({
    required this.applicationId,
    required this.application,
    required this.profile,
    required this.score,
  });
}
