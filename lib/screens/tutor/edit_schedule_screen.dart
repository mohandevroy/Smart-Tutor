import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class EditScheduleScreen extends StatefulWidget {
  final String day;
  final String time;

  const EditScheduleScreen({
    super.key,
    required this.day,
    required this.time,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late TextEditingController _dayController;
  late TextEditingController _timeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(
      text: widget.day == 'No day added' ? '' : widget.day,
    );
    _timeController = TextEditingController(
      text: widget.time == 'No time added' ? '' : widget.time,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF4F46E5)),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _updateSchedule() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_dayController.text.trim().isEmpty ||
        _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day আর time দুইটাই লিখো')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('tutor_profiles')
        .doc(user.uid)
        .set({
      'scheduleDay': _dayController.text.trim(),
      'scheduleTime': _timeController.text.trim(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Edit Schedule'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInputField(
              label: 'Available Day',
              icon: Icons.calendar_today,
              controller: _dayController,
            ),
            buildInputField(
              label: 'Available Time',
              icon: Icons.access_time,
              controller: _timeController,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Schedule',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}