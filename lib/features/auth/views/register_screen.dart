import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/token_storage.dart';
import '../../predict/controllers/predict_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/register_request_model.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController controller;

  const RegisterScreen({super.key, required this.controller});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  LocationOption? _selectedCity;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nameParts = _fullNameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final username = _emailController.text.trim().split('@').first;

    final request = RegisterRequestModel(
      username: username,
      email: _emailController.text.trim(),
      firstName: firstName,
      lastName: lastName,
      city: _selectedCity!.name,
      password: _passwordController.text,
      passwordConfirm: _passwordConfirmController.text,
    );

    await TokenStorage.saveSelectedCity(_selectedCity!.name);

    final success = await widget.controller.register(request);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.of(context).pop();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Header
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A29),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join AgriAssist',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B8E77),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

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
                              if (widget.controller.errorMessage != null) ...[
                                _buildErrorCard(widget.controller.errorMessage!),
                                const SizedBox(height: 16),
                              ],

                              // Full Name
                              _buildFieldLabel('Full Name'),
                              TextFormField(
                                controller: _fullNameController,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
                                decoration: _buildInputDecoration(
                                  hintText: 'John Doe',
                                  prefixIcon: Icons.person_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

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
                              ),
                              const SizedBox(height: 18),

                              // Location Dropdown
                              _buildFieldLabel('Location'),
                              DropdownButtonFormField<LocationOption>(
                                initialValue: _selectedCity,
                                hint: const Text(
                                  'Select a location',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                decoration: _buildInputDecoration(
                                  hintText: 'Select a location',
                                  prefixIcon: Icons.location_on_rounded,
                                ),
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                onChanged: (LocationOption? val) {
                                  if (val != null) {
                                    setState(() => _selectedCity = val);
                                  }
                                },
                                validator: (val) {
                                  if (val == null) {
                                    return 'Please select a location';
                                  }
                                  return null;
                                },
                                items: PredictController.locationOptions
                                    .map<DropdownMenuItem<LocationOption>>((LocationOption loc) {
                                  return DropdownMenuItem<LocationOption>(
                                    value: loc,
                                    child: Text(
                                      loc.displayName,
                                      style: const TextStyle(
                                        color: Color(0xFF2D3748),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 18),

                              // Password
                              _buildFieldLabel('Password'),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isObscurePassword,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
                                decoration: _buildInputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _isObscurePassword = !_isObscurePassword),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (val.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  'Min 8 characters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Confirm Password
                              _buildFieldLabel('Confirm Password'),
                              TextFormField(
                                controller: _passwordConfirmController,
                                obscureText: _isObscureConfirmPassword,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
                                decoration: _buildInputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _isObscureConfirmPassword = !_isObscureConfirmPassword),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // Create Account Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: widget.controller.isLoading ? null : () => _handleRegister(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF76C893),
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
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login Link
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: Color(0xFF4A5568),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Login',
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
        borderSide: const BorderSide(color: Color(0xFF76C893), width: 2),
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
