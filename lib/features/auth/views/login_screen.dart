import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.controller,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.setEmail(_emailController.text);
      widget.controller.setPassword(_passwordController.text);

      final success = await widget.controller.login();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EAD8),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // App Logo & Header
                      _buildLogoHeader(),
                      const SizedBox(height: 28),

                      // Form Container Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F3E6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A29),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (widget.controller.errorMessage != null) ...[
                                _buildErrorCard(widget.controller.errorMessage!),
                                const SizedBox(height: 16),
                              ],

                              // Email
                              _buildFieldLabel('Email'),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
                                decoration: _buildInputDecoration(
                                  hintText: 'your@email.com',
                                  prefixIcon: Icons.email_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                onChanged: widget.controller.setEmail,
                              ),
                              const SizedBox(height: 18),

                              // Password
                              _buildFieldLabel('Password'),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: widget.controller.isObscurePassword,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
                                decoration: _buildInputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      widget.controller.isObscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    onPressed: widget.controller.togglePasswordVisibility,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onChanged: widget.controller.setPassword,
                              ),
                              const SizedBox(height: 28),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: widget.controller.isLoading ? null : () => _handleLogin(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2B9348),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: widget.controller.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Divider "or"
                              Row(
                                children: const [
                                  Expanded(child: Divider(color: Color(0xFFCBD5E1), height: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Color(0xFFCBD5E1), height: 1)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Sign Up Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(controller: widget.controller),
                                      ),
                                    );
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        color: Color(0xFF4A5568),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign up',
                                          style: TextStyle(
                                            color: Color(0xFF2B9348),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF2B9348),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'AgriAssist',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A29),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w400),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFB8C5D6), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2B9348), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
