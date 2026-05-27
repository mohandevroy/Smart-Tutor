import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.access_time_filled_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Status',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: user == null
          ? const Center(
              child: Text('User not logged in'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('verification_payments')
                  .where('tutorId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 48,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No payment submitted yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Submit your tutor verification payment first.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['createdAt'];
                  final bTime = bData['createdAt'];

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return (bTime as Timestamp).compareTo(aTime as Timestamp);
                });

                final latestDoc = docs.first;
                final data = latestDoc.data() as Map<String, dynamic>;

                final amount = data['amount']?.toString() ?? '0';
                final paymentMethod = data['paymentMethod'] ?? 'N/A';
                final transactionId = data['transactionId'] ?? 'N/A';
                final phoneNumber = data['phoneNumber'] ?? 'N/A';
                final tutorName = data['tutorName'] ?? 'N/A';
                final status = data['status'] ?? 'pending';
                final note = data['note'] ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  _getStatusColor(status).withOpacity(0.12),
                              child: Icon(
                                _getStatusIcon(status),
                                size: 30,
                                color: _getStatusColor(status),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Verification Payment Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                status.toString().toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text('Tutor Name: $tutorName'),
                            const SizedBox(height: 8),
                            Text('Amount: ৳ $amount'),
                            const SizedBox(height: 8),
                            Text('Method: $paymentMethod'),
                            const SizedBox(height: 8),
                            Text('Transaction ID: $transactionId'),
                            const SizedBox(height: 8),
                            Text('Phone Number: $phoneNumber'),
                            const SizedBox(height: 8),
                            Text('Note: $note'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}