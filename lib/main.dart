import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform/register_preferences.dart';
import 'views/quiz_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerPreferencesPlatform();
  runApp(const ProviderScope(child: QuizApp()));
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF19251F);
    const green = Color(0xFF4D715A);
    return MaterialApp(
      title: 'The Daily Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            height: 1.08,
            letterSpacing: -1.5,
            color: ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            height: 1.15,
            letterSpacing: -.7,
            color: ink,
          ),
          titleLarge: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: Color(0xFF47524C),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF737B74),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),
      home: const QuizPage(),
    );
  }
}
