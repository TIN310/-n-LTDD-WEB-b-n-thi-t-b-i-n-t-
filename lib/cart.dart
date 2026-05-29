import 'package:flutter/material.dart';
import 'product.dart';
import 'checkout.dart'; // Nạp trang Checkout mới vào đây

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Hàm định dạng tiền tệ
  String formatCurrency(int amount) {
    String result = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.'
    );
    return '$result đ';
  }

  // Các biến tính toán
  int get subtotal => AppData.cart.fold(0, (sum, item) => sum + (item.product.rawPrice * item.quantity));
  int get discountAmount => (subtotal * AppData.discountPercent).round();
  int get finalTotal => subtotal - discountAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppData.cart.isEmpty
          ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.remove_shopping_cart_outlined, color: Colors.grey, size: 80),
              SizedBox(height: 20),
              Text('Giỏ hàng của bạn đang trống', style: TextStyle(color: Colors.grey, fontSize: 18)),
            ],
          )
      )
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: AppData.cart.length,
        itemBuilder: (context, index) {
          final item = AppData.cart[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[850]!)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(item.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(item.product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(onTap: () => setState(() { if(item.quantity > 1) item.quantity--; }), child: _buildQtyBtn(Icons.remove)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                            GestureDetector(onTap: () => setState(() => item.quantity++), child: _buildQtyBtn(Icons.add)),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => setState(() => AppData.cart.removeAt(index))
                  )
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (AppData.discountPercent > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ưu đãi hạng ${AppData.userTier}:', style: const TextStyle(color: Colors.amber)),
                  Text('- ${formatCurrency(discountAmount)}', style: const TextStyle(color: Colors.amber)),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tạm tính:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text(formatCurrency(finalTotal), style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                // ĐÃ SỬA: Bấm nút này sẽ nhảy sang trang Checkout
                onPressed: () {
                  if (AppData.cart.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen())
                    ).then((value) {
                      // Cập nhật lại giỏ hàng khi từ trang Checkout quay về (ví dụ lỡ thanh toán xong rồi)
                      setState(() {});
                    });
                  }
                },
                child: const Text('TIẾN HÀNH THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon) {
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 18)
    );
  }
}