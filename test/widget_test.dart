// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_assist/features/home/controllers/home_controller.dart';
import 'package:agri_assist/features/home/repos/home_repo.dart';
import 'package:agri_assist/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    final homeRepo = MockHomeRepo();
    final homeController = HomeController(homeRepo: homeRepo);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(homeController: homeController));

    // Verify loading indicator or initial state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
