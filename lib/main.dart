import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/admin_login_screen.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/home/repos/home_repo.dart';
import 'features/home/views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up repo and controller instances
  final homeRepo = OpenMeteoHomeRepo();
  final homeController = HomeController(homeRepo: homeRepo);

  runApp(MyApp(homeController: homeController));
}

class MyApp extends StatelessWidget {
  final HomeController homeController;

  const MyApp({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: kIsWeb
          ? const AdminLoginScreen()
          : HomeScreen(controller: homeController),
    );
  }
}
