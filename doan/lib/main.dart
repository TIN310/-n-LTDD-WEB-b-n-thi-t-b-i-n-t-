import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

// ✅ main phải là async để dùng await
Future<void> main() async {
  // ✅ Bắt buộc gọi trước khi dùng bất kỳ Flutter API nào
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Khởi tạo Supabase - thay 2 giá trị bên dưới bằng thông tin project của bạn
  await Supabase.initialize(
    url: 'https://lckagidapvvcwwqnhbzf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxja2FnaWRhcHZ2Y3d3cW5oYnpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3OTE0NjAsImV4cCI6MjA5MzM2NzQ2MH0.FjZ1St_q45nIRJgdhSWfqnSMN2RMdi9QpSzhQ8kKXIw',
  );

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