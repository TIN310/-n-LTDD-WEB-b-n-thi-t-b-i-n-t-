import 'package:flutter/material.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vouchers = [
      {'title': 'Giảm 10%', 'desc': 'Cho đơn từ 500K. Tối đa 100K', 'color': Colors.red},
      {'title': 'Freeship', 'desc': 'Cho đơn từ 300K. Tối đa 30K', 'color': Colors.green},
      {'title': 'Giảm 500K', 'desc': 'Dành riêng cho Laptop Gaming', 'color': Colors.amber},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Kho Voucher'), backgroundColor: Colors.black, centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: vouchers[index]['color'] as Color, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12))),
                  child: const Center(child: Icon(Icons.local_offer, color: Colors.white, size: 40)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vouchers[index]['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(vouchers[index]['desc'] as String, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(80, 30)),
                            onPressed: () {},
                            child: const Text('Dùng ngay', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}