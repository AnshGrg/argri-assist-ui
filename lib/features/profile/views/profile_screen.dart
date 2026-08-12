import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/repos/auth_repo.dart';
import '../../auth/views/login_screen.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/repos/home_repo.dart';
import '../../home/views/home_screen.dart';
import '../../../core/utils/string_utils.dart';
import '../controllers/profile_controller.dart';
import '../repos/profile_repo.dart';

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
  String _locationName = 'Bharatpur, Chitwan';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProfileController(profileRepo: HttpProfileRepo());
    _authController = widget.authController ?? AuthController(authRepo: HttpAuthRepo());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.fetchUserProfile(accessToken: _authController.tokens?.access);
      final selectedCity = await TokenStorage.loadSelectedCity();
      if (mounted) {
        setState(() {
          _locationName = selectedCity.displayName;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _authController]),
          builder: (context, _) {
            if (_controller.isLoading || _authController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            final profile = _controller.userProfile;
            final authUsername = _authController.tokens?.username;
            final authEmail = _authController.tokens?.email;
            final formattedUsername = StringUtils.formatUsername(authUsername);
            final fullName = profile?.fullName.isNotEmpty == true
                ? profile!.fullName
                : (formattedUsername.isNotEmpty ? formattedUsername : 'Farmer');
            final email = profile?.email.isNotEmpty == true
                ? profile!.email
                : (authEmail ?? 'alex.johnson@farmmail.com');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Full Name Header
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFFAB47BC),
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: 14),

                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFE91E63),
                    label: 'Location',
                    value: _locationName,
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons: Edit Profile & Logout
                  _buildActionButtons(context, authEmail??'', authUsername??''),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    String? trailingBadge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (trailingBadge != null)
            Text(
              trailingBadge,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String authEmail, String authUsername) {
    return Column(
      children: [
        // Edit Profile Button
        // SizedBox(
        //   width: double.infinity,
        //   height: 52,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primaryGreen,
        //       foregroundColor: Colors.white,
        //       elevation: 2,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(16),
        //       ),
        //     ),
        //     onPressed: () {
        //       final user = _controller.userProfile;
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => EditProfileScreen(
        //             controller: _controller,
        //             initialFullName: authUsername,
        //             initialEmail: authEmail ,
        //             initialCity: user?.profile?.city ?? '',
        //           ),
        //         ),
        //       );
        //     },
        //     child: const Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(Icons.edit_outlined, size: 18),
        //         SizedBox(width: 8),
        //         Text(
        //           'Edit Profile',
        //           style: TextStyle(
        //             fontSize: 15,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 12),
        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _showLogoutDialog(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    if (!_authController.isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            controller: _authController,
            onLoginSuccess: () => _navigateToHome(context),
          ),
        ),
      );
      return;
    }

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
              await _authController.logout();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Successfully logged out.'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      controller: _authController,
                      onLoginSuccess: () => _navigateToHome(context),
                    ),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    final homeController = HomeController(homeRepo: OpenMeteoHomeRepo());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(controller: homeController),
      ),
      (route) => false,
    );
  }
}
