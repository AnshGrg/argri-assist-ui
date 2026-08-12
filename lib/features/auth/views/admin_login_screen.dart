import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back navigation
            if (Navigator.of(context).canPop())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AgriAssist Admin Portal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Web Admin Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 24,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AgriAssist Admin',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Sign in to Admin Console',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Enter your credentials to access system analytics & news portal.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Error Message Banner
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFCA5A5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFF991B1B),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Username / Email Field
                            const Text(
                              'Username or Email',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: 'admin@agriassist.com',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Please enter username or email' : null,
                            ),
                            const SizedBox(height: 18),

                            // Password Field
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscurePassword,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    setState(() => _isObscurePassword = !_isObscurePassword);
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Please enter password' : null,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
