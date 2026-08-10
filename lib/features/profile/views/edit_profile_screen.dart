import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../predict/controllers/predict_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_update_model.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileController controller;

  const EditProfileScreen({super.key, required this.controller});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  LocationOption? _selectedCity;
  bool _hasInitializedFields = false;

  @override
  void initState() {
    super.initState();
    _fetchAndPopulate();
  }

  Future<void> _fetchAndPopulate() async {
    if (widget.controller.userProfile == null) {
      await widget.controller.fetchUserProfile();
    }
    if (mounted) {
      _updateFieldsFromController();
    }
  }

  void _updateFieldsFromController() {
    final profile = widget.controller.userProfile;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _emailController.text = profile.email;
      _phoneController.text = profile.profile?.phoneNumber ?? '';

      final existingCityStr = profile.profile?.city?.toLowerCase().trim();
      if (existingCityStr != null && existingCityStr.isNotEmpty) {
        _selectedCity = PredictController.locationOptions.firstWhere(
          (loc) =>
              loc.name.toLowerCase() == existingCityStr ||
              loc.displayName.toLowerCase() == existingCityStr ||
              existingCityStr.contains(loc.name.toLowerCase()),
          orElse: () => PredictController.locationOptions.first,
        );
      } else {
        _selectedCity = PredictController.locationOptions.first;
      }
      _hasInitializedFields = true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = UserProfileUpdateModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        city: _selectedCity?.name ?? '',
      );

      final success = await widget.controller.updateProfile(request);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
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
                filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                if (!_hasInitializedFields && widget.controller.userProfile != null) {
                  _updateFieldsFromController();
                }

                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.controller.errorMessage != null) ...[
                                    _buildErrorCard(widget.controller.errorMessage!),
                                    AppSizes.spaceM,
                                  ],
                                  _buildFormCard(context),
                                  AppSizes.spaceXl,
                                  PrimaryButton(
                                    text: widget.controller.isLoading ? 'Saving...' : 'Save Changes',
                                    onPressed: () => _handleSave(),
                                    isLoading: widget.controller.isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: AppSizes.iconExtraLarge,
              color: AppColors.textDark,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.m),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: AppSizes.iconMedium),
          AppSizes.spaceM,
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'First Name',
            controller: _firstNameController,
            icon: Icons.person_outline_rounded,
          ),
          AppSizes.spaceM,
          _buildTextField(
            label: 'Last Name',
            controller: _lastNameController,
            icon: Icons.person_outline_rounded,
          ),
          AppSizes.spaceM,
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Email is required';
              }
              if (!val.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          AppSizes.spaceM,
          _buildTextField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          AppSizes.spaceM,
          // City / District Selection Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City / Location',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              AppSizes.spaceS,
              DropdownButtonFormField<LocationOption>(
                key: ValueKey(_selectedCity?.displayName ?? 'city_dropdown'),
                initialValue: _selectedCity,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.primaryGreen),
                  filled: true,
                  fillColor: AppColors.white.withValues(alpha: 0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                    vertical: AppSizes.m,
                  ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        AppSizes.spaceS,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryGreen),
            filled: true,
            fillColor: AppColors.white.withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.m,
              vertical: AppSizes.m,
            ),
          ),
        ),
      ],
    );
  }
}
