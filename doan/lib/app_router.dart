import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Home.dart';
import 'staff_dashboard.dart';
import 'admin_dashboard.dart';

class AppRouter {
  // Lấy role của user hiện tại từ bảng profiles
  static Future<String> fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      print('=== ĐANG LẤY ROLE CHO USER ID: $userId ===');
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      print('=== KẾT QUẢ ROLE TRẢ VỀ: ${response['role']} ===');
      return (response['role'] as String?) ?? 'user';
    } catch (e) {
      print('=== LỖI LẤY ROLE TỪ SUPABASE ===');
      print(e);
      // Nếu có lỗi hoặc không tìm thấy profile, trả về 'user' làm mặc định an toàn
      return 'user';
    }
  }

  // Trả về màn hình tương ứng với role
  static Widget getHomeByRole(String role) {
    switch (role) {
      case 'admin':
        return const AdminDashboard();
      case 'staff':
        return const StaffDashboard();
      default:
        return const HomeScreen();
    }
  }

  // Điều hướng đến màn hình tương ứng, xóa toàn bộ navigation stack
  static Future<void> navigateByRole(
      BuildContext context, String role) async {
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => getHomeByRole(role)),
          (route) => false,
    );
  }
}