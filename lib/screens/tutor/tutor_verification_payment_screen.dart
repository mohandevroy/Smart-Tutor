import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/models/verification_payment_model.dart';
import 'package:smart_tutor/services/verification_payment_service.dart';

class TutorVerificationPaymentScreen extends StatefulWidget {
  const TutorVerificationPaymentScreen({super.key});

  @override
  State<TutorVerificationPaymentScreen> createState() =>
      _TutorVerificationPaymentScreenState();
}

class _TutorVerificationPaymentScreenState
    extends State<TutorVerificationPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tutorNameController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '500');
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController =
      TextEditingController(text: 'Verification fee submitted');

  final VerificationPaymentService _paymentService =
      VerificationPaymentService();

  String _selectedPaymentMethod = 'Bkash';
  bool _isLoading = false;
  bool _isCheckingExistingPayment = true;
  Map<String, dynamic>? _existingPaymentData;

  final List<String> _paymentMethods = [
    'Bkash',
    'Nagad',
    'Rocket',
    'Bank',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingPayment();
  }

  Future<void> _loadExistingPayment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isCheckingExistingPayment = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('verification_payments')
          .where('tutorId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docs = snapshot.docs;

        docs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          final aTime = aData['createdAt'];
          final bTime = bData['createdAt'];

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return (bTime as Timestamp).compareTo(aTime as Timestamp);
        });

        _existingPaymentData = docs.first.data();
      }
    } catch (e) {
      debugPrint('Failed to load existing payment: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isCheckingExistingPayment = false;
      });
    }
  }

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

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Verification Approved';
      case 'rejected':
        return 'Verification Rejected';
      case 'pending':
        return 'Verification Under Review';
      default:
        return 'Verification Submitted';
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Your tutor verification payment has been approved successfully.';
      case 'rejected':
        return 'Your previous payment was rejected. You can contact admin later if needed.';
      case 'pending':
        return 'Your payment has already been submitted and is currently under review.';
      default:
        return 'Your verification payment has already been submitted.';
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final alreadyExists = await _paymentService.hasExistingPayment(user.uid);

      if (alreadyExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already submitted a verification payment'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        await _loadExistingPayment();
        return;
      }

      final payment = VerificationPaymentModel(
        tutorId: user.uid,
        tutorName: _tutorNameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        paymentMethod: _selectedPaymentMethod,
        transactionId: _transactionIdController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        note: _noteController.text.trim(),
        status: 'pending',
      );

      await _paymentService.submitVerificationPayment(payment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification payment submitted successfully'),
        ),
      );

      await _loadExistingPayment();

      _formKey.currentState!.reset();
      _tutorNameController.clear();
      _amountController.text = '500';
      _transactionIdController.clear();
      _phoneController.clear();
      _noteController.text = 'Verification fee submitted';

      setState(() {
        _selectedPaymentMethod = 'Bkash';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF4F46E5),
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }

  Widget _buildExistingPaymentCard() {
    final data = _existingPaymentData!;
    final status = (data['status'] ?? 'pending').toString();
    final tutorName = data['tutorName'] ?? 'N/A';
    final amount = data['amount']?.toString() ?? '0';
    final paymentMethod = data['paymentMethod'] ?? 'N/A';
    final transactionId = data['transactionId'] ?? 'N/A';
    final phoneNumber = data['phoneNumber'] ?? 'N/A';
    final note = data['note'] ?? '';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: _getStatusColor(status).withOpacity(0.12),
                child: Icon(
                  _getStatusIcon(status),
                  size: 32,
                  color: _getStatusColor(status),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getStatusTitle(status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getStatusMessage(status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submitted Payment Details',
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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF4F46E5),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You already have a verification payment record. New submission is currently disabled to keep your data clean.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4338CA),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
                Color(0xFF2563EB),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334F46E5),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF4F46E5),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Submit Verification Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Fill in your payment details to request tutor verification.',
                style: TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 14,
                  height: 1.5,
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
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Fee',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF166534),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '৳ 500',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tutorNameController,
                  decoration: _inputDecoration('Tutor Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter tutor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  readOnly: true,
                  decoration: _inputDecoration('Amount'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  decoration: _inputDecoration('Payment Method'),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _transactionIdController,
                  decoration: _inputDecoration('Transaction ID'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter transaction ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Payment Phone Number'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: _inputDecoration('Note'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Payment',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tutorNameController.dispose();
    _amountController.dispose();
    _transactionIdController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
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
          'Tutor Verification Payment',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: _isCheckingExistingPayment
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _existingPaymentData != null
                  ? _buildExistingPaymentCard()
                  : _buildPaymentForm(),
            ),
    );
  }
}