import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/admin_verification_service.dart';

class TutorVerificationListScreen extends StatelessWidget {
  const TutorVerificationListScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(
    BuildContext context, {
    required String docId,
    required String tutorId,
    required String newStatus,
  }) async {
    try {
      await AdminVerificationService().updatePaymentStatus(
        docId: docId,
        tutorId: tutorId,
        newStatus: newStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment marked as $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String docId,
    required String tutorId,
    required String currentStatus,
    required String buttonStatus,
    required Color color,
  }) {
    final isCurrent =
        currentStatus.toLowerCase() == buttonStatus.toLowerCase();

    return Expanded(
      child: ElevatedButton(
        onPressed: isCurrent
            ? null
            : () {
                _updateStatus(
                  context,
                  docId: docId,
                  tutorId: tutorId,
                  newStatus: buttonStatus,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.35),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isCurrent
              ? '${buttonStatus.toUpperCase()}D'
              : buttonStatus[0].toUpperCase() + buttonStatus.substring(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tutor Verification Payments',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verification_payments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No payments found'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final tutorName = data['tutorName'] ?? 'N/A';
              final tutorId = data['tutorId'] ?? '';
              final amount = data['amount']?.toString() ?? '0';
              final method = data['paymentMethod'] ?? 'N/A';
              final trxId = data['transactionId'] ?? 'N/A';
              final phone = data['phoneNumber'] ?? 'N/A';
              final status = (data['status'] ?? 'pending').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Amount: ৳ $amount'),
                    Text('Method: $method'),
                    Text('Transaction ID: $trxId'),
                    Text('Phone: $phone'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildActionButton(
                          context: context,
                          docId: doc.id,
                          tutorId: tutorId,
                          currentStatus: status,
                          buttonStatus: 'approved',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context: context,
                          docId: doc.id,
                          tutorId: tutorId,
                          currentStatus: status,
                          buttonStatus: 'rejected',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}