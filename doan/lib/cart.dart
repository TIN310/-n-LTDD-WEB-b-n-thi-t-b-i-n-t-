import 'package:flutter/material.dart';
import 'product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Hàm tự viết để định dạng tiền tệ (Không cần dùng gói intl)
  String formatCurrency(int amount) {
    String result = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.'
    );
    return '$result đ';
  }

  int get subtotal => AppData.cart.fold(0, (sum, item) => sum + (item.product.rawPrice * item.quantity));
  int get discountAmount => (subtotal * AppData.discountPercent).round();
  int get finalTotal => subtotal - discountAmount;

  void _showPaymentModal() {
    if (AppData.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống!')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CHỌN PHƯƠNG THỨC THANH TOÁN', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _paymentOption(Icons.local_shipping, 'Thanh toán khi nhận hàng (COD)', 'COD'),
              _paymentOption(Icons.account_balance_wallet, 'Thanh toán qua Ví MoMo', 'MoMo'),
              _paymentOption(Icons.account_balance, 'Chuyển khoản Ngân hàng', 'Bank'),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentOption(IconData icon, String title, String methodCode) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context); // Đóng modal
          _processOrder(methodCode);
        },
      ),
    );
  }

  void _processOrder(String methodCode) {
    AppData.processCheckout(methodCode); // Gọi logic xử lý trừ tiền, cộng điểm ở file product.dart

    // Hiển thị thông báo thành công
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text('Đặt hàng thành công!\nĐiểm tích lũy đã được cộng vào tài khoản.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                setState(() {}); // Load lại trang Giỏ hàng (lúc này đã trống)
              },
              child: const Text('Tiếp tục mua sắm', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Giỏ hàng'), backgroundColor: Colors.black),
      body: AppData.cart.isEmpty
          ? const Center(child: Text('Giỏ hàng trống', style: TextStyle(color: Colors.grey, fontSize: 18)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.cart.length,
        itemBuilder: (context, index) {
          final item = AppData.cart[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.only(bottom: 16),
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
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: const TextStyle(color: Colors.white))),
                            GestureDetector(onTap: () => setState(() => item.quantity++), child: _buildQtyBtn(Icons.add)),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => AppData.cart.removeAt(index)))
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
                const Text('Tổng thanh toán:', style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text(formatCurrency(finalTotal), style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _showPaymentModal,
                child: const Text('TIẾN HÀNH THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon) {
    return Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(5)), child: Icon(icon, color: Colors.white, size: 16));
  }
}