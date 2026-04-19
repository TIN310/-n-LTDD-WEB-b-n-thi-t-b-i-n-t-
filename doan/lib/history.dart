import 'package:flutter/material.dart';
import 'product.dart'; // Nơi chứa AppData và thông tin Đơn hàng

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Lịch sử mua hàng'),
          backgroundColor: Colors.black,
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Truyền trạng thái tương ứng để lọc đơn hàng
            _OrderList(status: 'Chờ xác nhận', color: Colors.orange),
            _OrderList(status: 'Đang giao', color: Colors.blue),
            _OrderList(status: 'Đã giao thành công', color: Colors.green),
            _OrderList(status: 'Đã hủy', color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String status;
  final Color color;
  const _OrderList({required this.status, required this.color});

  // Hàm tự viết để định dạng tiền tệ (Không cần dùng gói intl)
  String formatCurrency(int amount) {
    String result = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.'
    );
    return '$result đ';
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các đơn hàng có trạng thái khớp với Tab hiện tại
    final filteredOrders = AppData.history.where((order) => order.status == status).toList();

    // Nếu không có đơn hàng nào ở trạng thái này
    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào\nở trạng thái này.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Nếu có đơn hàng, in ra danh sách
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mã: ${order.orderId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(order.status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 20),

                // Hiển thị danh sách các sản phẩm bên trong đơn hàng này
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey)),
                          )
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 5),
                            Text('Số lượng: x${item.quantity}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

                const Divider(color: Colors.white24, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('+ ${order.earnedPoints} điểm', style: const TextStyle(color: Colors.green)),
                    // Đã thay thế dòng này để dùng hàm format tự viết
                    Text(formatCurrency(order.totalAmount), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}