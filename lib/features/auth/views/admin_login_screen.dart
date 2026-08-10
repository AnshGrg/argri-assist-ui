import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/login_request_model.dart';
import '../repos/auth_repo.dart';
import '../../news/controllers/news_controller.dart';
import '../../analytics/views/analytics_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  final AuthRepo? authRepo;
  final NewsController? newsController;

  const AdminLoginScreen({
    super.key,
    this.authRepo,
    this.newsController,
  });

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthRepo _authRepo;
  bool _isLoading = false;
  bool _isObscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authRepo = widget.authRepo ?? HttpAuthRepo();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = LoginRequestModel(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      final tokens = await _authRepo.login(request);

      if (tokens.access.isNotEmpty) {
        if (widget.newsController != null) {
          widget.newsController!.setAdminToken(tokens.access);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin login successful! Token active.'),
              backgroundColor: Colors.green,
            ),
          );

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(tokens.access);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AnalyticsDashboardScreen(authToken: tokens.access),
              ),
            );
          }
        }
      } else {
        throw Exception('Server did not return a valid admin access token.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.l),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Navigator.of(context).canPop())
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 48,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    AppSizes.spaceM,
                    Text(
                      'Admin Portal Login',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Authenticate to manage news & advisories',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                    ),
                    AppSizes.spaceL,
                    GlassCard(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                                ),
                              ),
                              AppSizes.spaceM,
                            ],
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Admin Email or Username',
                                hintText: 'admin@agriassist.com',
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGreen),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Enter email/username' : null,
                            ),
                            AppSizes.spaceM,
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryGreen),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textMedium,
                                  ),
                                  onPressed: () {
                                    setState(() => _isObscurePassword = !_isObscurePassword);
                                  },
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Enter password' : null,
                            ),
                            AppSizes.spaceL,
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Login & Authorize API',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
