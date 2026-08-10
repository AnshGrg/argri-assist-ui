import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/widgets/glass_card.dart';
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

  LocationOption _selectedCity = PredictController.locationOptions.first;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final nameParts = _fullNameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      final username = _emailController.text.trim().split('@').first;

      final request = RegisterRequestModel(
        username: username,
        email: _emailController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        city: _selectedCity.name,
        password: _passwordController.text,
        passwordConfirm: _passwordConfirmController.text,
      );

      // Persist selected city locally
      await TokenStorage.saveSelectedCity(_selectedCity.name);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Filter & Translucent Overlay
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          // Screen UI
          SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xl,
                      vertical: AppSizes.l,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogoHeader(context),
                          AppSizes.spaceXl,
                          _buildGlassFormCard(context),
                          AppSizes.spaceL,
                          _buildLoginLink(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.eco,
              color: AppColors.primaryGreen,
              size: 42,
            ),
            const SizedBox(width: 8),
            Text(
              'AgriAssist',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Crop & Fertilizer\nRecommendation App',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildGlassFormCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xxl),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (widget.controller.errorMessage != null) ...[
              _buildErrorCard(widget.controller.errorMessage!),
              AppSizes.spaceM,
            ],
            // Full Name Input
            TextFormField(
              controller: _fullNameController,
              decoration: _buildInputDecoration(
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline_rounded,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            AppSizes.spaceM,
            // Email Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration(
                hintText: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
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
            AppSizes.spaceM,
            // City / Location Dropdown Selection
            DropdownButtonFormField<LocationOption>(
              initialValue: _selectedCity,
              decoration: _buildInputDecoration(
                hintText: 'Select City',
                prefixIcon: Icons.location_city_rounded,
              ),
              dropdownColor: AppColors.backgroundGreen,
              isExpanded: true,
              onChanged: (LocationOption? val) {
                if (val != null) {
                  setState(() => _selectedCity = val);
                }
              },
              items: PredictController.locationOptions
                  .map<DropdownMenuItem<LocationOption>>((LocationOption loc) {
                return DropdownMenuItem<LocationOption>(
                  value: loc,
                  child: Text(
                    loc.displayName,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSizes.spaceM,
            // Password Input
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscurePassword,
              decoration: _buildInputDecoration(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMedium,
                  ),
                  onPressed: () => setState(() => _isObscurePassword = !_isObscurePassword),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            AppSizes.spaceM,
            // Confirm Password Input
            TextFormField(
              controller: _passwordConfirmController,
              obscureText: _isObscureConfirmPassword,
              decoration: _buildInputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMedium,
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
            AppSizes.spaceXl,
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.controller.isLoading ? null : () => _handleRegister(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
                  ),
                  elevation: 3,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            AppSizes.spaceL,
            _buildAlreadyHaveAccountText(context),
          ],
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
      hintStyle: const TextStyle(color: AppColors.textMedium, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: AppColors.textMedium),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white.withValues(alpha: 0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.m,
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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

  Widget _buildAlreadyHaveAccountText(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
          children: const [
            TextSpan(
              text: 'Login',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return const SizedBox.shrink();
  }
}
