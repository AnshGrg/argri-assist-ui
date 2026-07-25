import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            child: Column(
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
          'Ramesh Kumar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        AppSizes.spaceXs,
        Text(
          'ramesh.kumar@email.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
              ),
        ),
        Text(
          '+91 98765 43210',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
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
            icon: Icons.tune_rounded,
            title: 'Preferences',
            onTap: () {},
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
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
