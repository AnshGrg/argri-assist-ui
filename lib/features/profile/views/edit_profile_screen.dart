import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/primary_button.dart';
import '../../predict/controllers/predict_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile_update_model.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileController controller;
  final String initialFullName;
  final String initialEmail;
  final String initialCity;

  const EditProfileScreen({
    super.key,
    required this.controller,
    this.initialFullName = '',
    this.initialEmail = '',
    this.initialCity = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;

  LocationOption? _selectedCity;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialFullName);
    _emailController = TextEditingController(text: widget.initialEmail);

    _initCity(widget.initialCity);

    _fetchAndPopulate();
  }

  void _initCity(String cityStr) {
    final cleanCity = cityStr.toLowerCase().trim();
    if (cleanCity.isNotEmpty) {
      _selectedCity = PredictController.locationOptions.firstWhere(
        (loc) =>
            loc.name.toLowerCase() == cleanCity ||
            loc.displayName.toLowerCase() == cleanCity ||
            cleanCity.contains(loc.name.toLowerCase()),
        orElse: () => PredictController.locationOptions.first,
      );
    } else {
      _selectedCity = PredictController.locationOptions.first;
    }
  }

  Future<void> _fetchAndPopulate() async {
    await widget.controller.fetchUserProfile();
    if (mounted) {
      final profile = widget.controller.userProfile;
      if (profile != null) {
        setState(() {
          if (_fullNameController.text.isEmpty && profile.fullName.isNotEmpty) {
            _fullNameController.text = profile.fullName;
          }
          if (_emailController.text.isEmpty && profile.email.isNotEmpty) {
            _emailController.text = profile.email;
          }
          if (profile.profile?.city != null &&
              profile.profile!.city!.isNotEmpty) {
            _initCity(profile.profile!.city!);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final rawName = _fullNameController.text.trim();
      final nameParts = rawName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final request = UserProfileUpdateModel(
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text.trim(),
        city: _selectedCity?.name ?? '',
      );

      debugPrint('[EditProfile] Saving: ${request.toJson()}');
      final success = await widget.controller.updateProfile(request);
      debugPrint('[EditProfile] Update result: $success, error: ${widget.controller.errorMessage}');
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      debugPrint('[EditProfile] Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.controller.errorMessage != null) ...[
                                _buildErrorCard(
                                  widget.controller.errorMessage!,
                                ),
                                AppSizes.spaceM,
                              ],
                              _buildFormCard(context),
                              AppSizes.spaceXl,
                              PrimaryButton(
                                text: widget.controller.isLoading
                                    ? 'Saving...'
                                    : 'Save Changes',
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
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textDark,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
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
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: AppSizes.iconMedium,
          ),
          AppSizes.spaceM,
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA8E0B5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Full Name',
            controller: _fullNameController,
            icon: Icons.person_outline_rounded,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Full Name is required';
              }
              return null;
            },
          ),
          AppSizes.spaceM,
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
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
                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                    color: AppColors.primaryGreen,
                  ),
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
                    .map<DropdownMenuItem<LocationOption>>((
                      LocationOption loc,
                    ) {
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
                    })
                    .toList(),
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
    bool readOnly = false,
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
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryGreen),
            filled: true,
            fillColor: readOnly
                ? Colors.grey.shade100
                : AppColors.white.withValues(alpha: 0.8),
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
