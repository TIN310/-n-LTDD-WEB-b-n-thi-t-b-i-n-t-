import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  // Biến xác định vai trò của người đang mở màn hình này
  // Có thể là: "Người dùng", "Nhân viên", hoặc "Quản trị viên"
  final String role;

  const CategoryScreen({super.key, this.role = 'Người dùng'});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có phải là Admin không
    bool isAdmin = role == 'Quản trị viên';

    // (Tạm thời dùng list cứng. Sau này sẽ lấy từ Supabase)
    final List<Map<String, dynamic>> phoneCategories = [
      {'icon': Icons.phone_android, 'name': 'Điện thoại'},
      {'icon': Icons.laptop_mac, 'name': 'Laptop'},
      {'icon': Icons.tablet_mac, 'name': 'Máy tính bảng'},
      {'icon': Icons.headphones, 'name': 'Âm thanh'},
      {'icon': Icons.watch, 'name': 'Đồng hồ thông minh'},
      {'icon': Icons.home_repair_service, 'name': 'Nhà thông minh'},
      {'icon': Icons.cable, 'name': 'Phụ kiện'},
      {'icon': Icons.tv, 'name': 'Tivi - Màn hình'},
      {'icon': Icons.desktop_windows, 'name': 'PC - Linh kiện'},
      {'icon': Icons.gamepad, 'name': 'Máy chơi game'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Danh Mục Sản Phẩm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // NẾU LÀ ADMIN -> HIỆN NÚT THÊM DANH MỤC
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: phoneCategories.length,
        itemBuilder: (context, index) {
          final category = phoneCategories[index];

          return InkWell(
            onTap: () {
              if (isAdmin) {
                // Admin bấm vào thì hiện menu Sửa / Xóa
                _showAdminOptions(context, category['name']);
              } else {
                // Người dùng/Nhân viên bấm vào thì chuyển sang màn hình Lọc sản phẩm
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang lọc sản phẩm mục: ${category['name']}')),
                );
                // TODO: Navigator.push qua trang SearchScreen truyền theo category
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'], size: 40, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    category['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // CÁC HÀM XỬ LÝ DÀNH RIÊNG CHO QUẢN TRỊ VIÊN
  // ==========================================

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Thêm Danh Mục Mới', style: TextStyle(color: Colors.white)),
        content: const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập tên danh mục...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Gửi dữ liệu lên Supabase Database
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm danh mục!')));
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAdminOptions(BuildContext context, String categoryName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tùy chỉnh: $categoryName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text('Chỉnh sửa tên/icon', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Xóa danh mục', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa danh mục')));
              },
            ),
          ],
        ),
      ),
    );
  }
}