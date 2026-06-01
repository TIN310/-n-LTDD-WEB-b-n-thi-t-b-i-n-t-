import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'checkout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yuirveasmxdzngbijwaa.supabase.co',
    anonKey: 'sb_publishable_ectBcM06I8wOk4bvDEMLNA_Q-Gj1FJI',
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
      routes: {
        '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}