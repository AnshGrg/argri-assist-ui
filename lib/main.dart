import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/home/repos/home_repo.dart';
import 'features/home/views/home_screen.dart';

void main() {
  // Set up repo and controller instances
  final homeRepo = MockHomeRepo();
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
      home: HomeScreen(controller: homeController),
    );
  }
}
