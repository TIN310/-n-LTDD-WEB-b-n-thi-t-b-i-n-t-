import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Danh Mục Sản Phẩm'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
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
          return InkWell(
            onTap: () {}, // Xử lý khi chọn danh mục
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
                  Icon(phoneCategories[index]['icon'], size: 40, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    phoneCategories[index]['name'],
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
}