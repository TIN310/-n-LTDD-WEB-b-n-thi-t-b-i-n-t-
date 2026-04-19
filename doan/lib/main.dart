import 'package:flutter/material.dart';
import 'login.dart'; // Đã sửa theo tên file của bạn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electro Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A1A1A),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: const Color(0xFFEF5350),
          surface: const Color(0xFF2A2A2A),
          onSurface: Colors.white,
          tertiary: Colors.white,
          outline: Colors.grey[300],
        ),
      ),
      home: const LoginScreen(),
    );
  }
}