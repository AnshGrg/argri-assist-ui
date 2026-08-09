import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/repos/auth_repo.dart';
import '../../auth/views/login_screen.dart';
import '../controllers/profile_controller.dart';
import '../repos/profile_repo.dart';
import 'edit_profile_screen.dart';
import '../../analytics/views/analytics_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileController? controller;
  final AuthController? authController;

  const ProfileScreen({
    super.key,
    this.controller,
    this.authController,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProfileController(profileRepo: HttpProfileRepo());
    _authController = widget.authController ?? AuthController(authRepo: HttpAuthRepo());
    _controller.fetchUserProfile();
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
          // Screen UI
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, _authController]),
              builder: (context, _) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          children: [
                            _buildUserProfileHeader(context),
                            AppSizes.spaceXl,
                            _buildMenuOptionsCard(context),
                          ],
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textDark,
              size: AppSizes.iconMedium,
            ),
            onPressed: () {
              // Open Settings Sheet
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context) {
    if (_controller.isLoading || _authController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xl),
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    final profile = _controller.userProfile;
    final fullName = profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Ramesh Kumar';
    final email = profile?.email.isNotEmpty == true ? profile!.email : 'ramesh.kumar@email.com';
    final phone = profile?.profile?.phoneNumber ?? '+977 98765 43210';
    final city = profile?.profile?.city;

    return Column(
      children: [
        // Styled circular profile image container
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white,
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const CircleAvatar(
            backgroundColor: AppColors.lightGreen,
            child: Icon(
              Icons.person_rounded,
              size: 56,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        AppSizes.spaceM,
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        AppSizes.spaceXs,
        Text(
          email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
              ),
        ),
        if (phone.isNotEmpty) ...[
          AppSizes.spaceXs,
          Text(
            phone,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ],
        if (city != null && city.isNotEmpty) ...[
          AppSizes.spaceXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                city,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMenuOptionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuRow(
            context: context,
            icon: Icons.landscape_outlined,
            title: 'My Fields',
            onTap: () {},
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.history_edu_outlined,
            title: 'Saved Predictions',
            onTap: () {},
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    controller: _controller,
                  ),
                ),
              );
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.tune_rounded,
            title: 'Preferences',
            onTap: () {},
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.analytics_outlined,
            title: 'Admin Analytics Dashboard',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnalyticsDashboardScreen(
                    authToken: _authController.tokens?.access,
                  ),
                ),
              );
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {},
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.login_rounded,
            title: 'Account Login',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    controller: _authController,
                  ),
                ),
              );
            },
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          _buildMenuRow(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            textColor: Colors.red,
            iconColor: Colors.red,
            showChevron: false,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primaryGreen,
        size: AppSizes.iconMedium,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textDark,
        ),
      ),
      trailing: showChevron
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(dialogContext).pop();
              final success = await _authController.logout();
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Successfully logged out.'
                          : (_authController.errorMessage ?? 'Logged out successfully.'),
                    ),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(controller: _authController),
                  ),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
