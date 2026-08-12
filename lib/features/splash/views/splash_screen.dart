import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/repos/auth_repo.dart';
import '../../auth/views/login_screen.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home_screen.dart';

/// Splash screen that checks login state and navigates accordingly.
class SplashScreen extends StatefulWidget {
  final HomeController homeController;

  const SplashScreen({super.key, required this.homeController});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Brief delay for splash visibility
    await Future.delayed(const Duration(milliseconds: 800));

    final tokens = await TokenStorage.loadTokens();
    if (!mounted) return;

    if (tokens != null && tokens.access.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(controller: widget.homeController),
        ),
      );
    } else {
      final authController = AuthController(authRepo: HttpAuthRepo());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            controller: authController,
            onLoginSuccess: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(controller: widget.homeController),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EAD8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2B9348),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AgriAssist',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A29),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Smart Farming Solutions',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B8E77),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
