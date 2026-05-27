import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedRole = 'Guardian';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _friendlyAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        default:
          return error.message ?? 'Registration failed. Please try again.';
      }
    }

    return 'Registration failed. Please try again.';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      _showSnack('Registration successful. Please login.');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String subtitle,
  }) {
    final bool selected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _isLoading
            ? null
            : () {
                setState(() {
                  _selectedRole = role;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEDE9FE) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor:
                    selected ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordHint() {
    final password = _passwordController.text.trim();

    Color color = const Color(0xFF9CA3AF);
    String text = 'Use at least 6 characters';

    if (password.isNotEmpty && password.length < 6) {
      color = const Color(0xFFDC2626);
      text = 'Password is too short';
    } else if (password.length >= 6) {
      color = const Color(0xFF16A34A);
      text = 'Password looks good';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
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
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join Smart Tutor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create your account and continue with the right role.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _roleCard(
                                role: 'Guardian',
                                icon: Icons.family_restroom_rounded,
                                subtitle: 'Find trusted tutors',
                              ),
                              const SizedBox(width: 12),
                              _roleCard(
                                role: 'Tutor',
                                icon: Icons.school_rounded,
                                subtitle: 'Teach students',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              label: 'Full name',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';
                              if (name.isEmpty) return 'Full name is required';
                              if (name.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              label: 'Email address',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Email is required';
                              if (!email.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final password = value?.trim() ?? '';
                              if (password.isEmpty) {
                                return 'Password is required';
                              }
                              if (password.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          _passwordHint(),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _register(),
                            decoration: _inputDecoration(
                              label: 'Confirm password',
                              icon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final confirm = value?.trim() ?? '';
                              if (confirm.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (confirm != _passwordController.text.trim()) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}