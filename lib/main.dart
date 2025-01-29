import 'package:flutter/material.dart';
// Импорт HomePage
import 'screens/splash_screen.dart'; // Импорт SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Убираем баннер "Debug"
      home: const SplashScreen(), // Устанавливаем SplashScreen как стартовую страницу
    );
  }
}
