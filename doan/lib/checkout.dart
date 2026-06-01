import 'package:flutter/material.dart';
import 'product.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<String> savedAddresses = [
    '12 Phố Trịnh Văn Bô, Nam Từ Liêm, Hà Nội',
    '456 Nguyễn Văn Bảo, Gò Vấp, TP.HCM',
    'Ký túc xá Khu B, Dĩ An, Bình Dương'
  ];
  late String selectedAddress;
  String selectedPaymentMethod = 'COD';

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _voucherController = TextEditingController();

  // Trạng thái Voucher hiện tại ở giao diện
  double _appliedVoucherPercent = 0.0;

  @override
  void initState() {
    super.initState();
    selectedAddress = savedAddresses[0];
  }

  String formatCurrency(int amount) {
    String result = amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '$result đ';
  }

  // --- HÀM KIỂM TRA MÃ GIẢM GIÁ ---
  void _applyVoucher() {
    String code = _voucherController.text.trim().toUpperCase();
    if (code == '5AE5') {
      setState(() {
        _appliedVoucherPercent = 0.05; // Giảm 5%
        AppData.appliedVoucherPercent = 0.05; // Đẩy qua product.dart
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Áp dụng mã giảm 5% thành công!'), backgroundColor: Colors.green));
    } else if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã giảm giá!'), backgroundColor: Colors.orange));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn!'), backgroundColor: Colors.red));
    }
    // Thu gọn bàn phím
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // CÁC BIẾN TÍNH TIỀN
  int get subtotal => AppData.cart.fold(0, (sum, item) => sum + (item.product.rawPrice * item.quantity));
  int get tierDiscountAmount => (subtotal * AppData.discountPercent).round();
  int get voucherDiscountAmount => (subtotal * _appliedVoucherPercent).round();
  int get shippingFee => 30000; // Cố định 30k
  int get finalTotal => subtotal - tierDiscountAmount - voucherDiscountAmount + shippingFee;

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CHỌN ĐỊA CHỈ GIAO HÀNG', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...savedAddresses.map((address) => ListTile(
                leading: Icon(Icons.location_on, color: address == selectedAddress ? Colors.redAccent : Colors.grey),
                title: Text(address, style: TextStyle(color: address == selectedAddress ? Colors.white : Colors.grey[400])),
                trailing: address == selectedAddress ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () {
                  setState(() => selectedAddress = address);
                  Navigator.pop(context);
                },
              ))
            ],
          ),
        );
      },
    );
  }

  void _placeOrder() async {
    await AppData.processCheckout(selectedPaymentMethod, selectedAddress, _noteController.text);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        content: const Text(
          'ĐẶT HÀNG THÀNH CÔNG!\n\nĐiểm thưởng đã được cộng vào tài khoản VIP của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('VỀ TRANG CHỦ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: const Text('Xác nhận Đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ĐỊA CHỈ
            const Text('Địa chỉ nhận hàng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showAddressPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.redAccent, size: 30),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phạm Trí Tín | +84 912 345 678', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(selectedAddress, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 2. SẢN PHẨM
            const Text('Sản phẩm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppData.cart.length,
                itemBuilder: (context, index) {
                  final item = AppData.cart[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
                    title: Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: Text(formatCurrency(item.product.rawPrice), style: const TextStyle(color: Colors.grey)),
                    trailing: Text('x${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // 3. GHI CHÚ
            const Text('Ghi chú cho cửa hàng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(filled: true, fillColor: Colors.grey[900], hintText: 'VD: Giao giờ hành chính...', hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 25),

            // 4. MÃ GIẢM GIÁ (VOUCHER) MỚI
            const Text('Mã giảm giá / Voucher', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        filled: true, fillColor: Colors.grey[900],
                        hintText: 'Nhập mã (VD: 5AE5)',
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _applyVoucher,
                  child: const Text('ÁP DỤNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 25),

            // 5. PHƯƠNG THỨC THANH TOÁN
            const Text('Phương thức thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  RadioListTile(value: 'COD', groupValue: selectedPaymentMethod, activeColor: Colors.redAccent, title: const Text('Thanh toán khi nhận hàng', style: TextStyle(color: Colors.white, fontSize: 14)), secondary: const Icon(Icons.local_shipping_outlined, color: Colors.blueAccent), onChanged: (val) => setState(() => selectedPaymentMethod = val.toString())),
                  RadioListTile(value: 'MOMO', groupValue: selectedPaymentMethod, activeColor: Colors.redAccent, title: const Text('Ví điện tử MoMo', style: TextStyle(color: Colors.white, fontSize: 14)), secondary: const Icon(Icons.account_balance_wallet_outlined, color: Colors.pinkAccent), onChanged: (val) => setState(() => selectedPaymentMethod = val.toString())),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 6. CHI TIẾT THANH TOÁN (HÓA ĐƠN THÔNG MINH)
            const Text('Chi tiết thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildSummaryRow('Tạm tính (${AppData.cart.length} món)', formatCurrency(subtotal), Colors.white),
                  const SizedBox(height: 10),
                  _buildSummaryRow('Phí giao hàng', formatCurrency(shippingFee), Colors.white),

                  // Chỉ hiện dòng Ưu đãi hạng nếu có
                  if (AppData.discountPercent > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow('Ưu đãi hạng VIP', '- ${formatCurrency(tierDiscountAmount)}', Colors.amber),
                  ],

                  // Chỉ hiện dòng Voucher nếu có áp dụng
                  if (_appliedVoucherPercent > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow('Mã giảm giá (5AE5)', '- ${formatCurrency(voucherDiscountAmount)}', Colors.greenAccent),
                  ],

                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white24)),
                  _buildSummaryRow('Tổng thanh toán', formatCurrency(finalTotal), Colors.redAccent, isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey[900], border: const Border(top: BorderSide(color: Colors.white10))),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cần thanh toán:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(formatCurrency(finalTotal), style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _placeOrder,
                child: const Text('ĐẶT HÀNG', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: isBold ? 16 : 14)),
        Text(value, style: TextStyle(color: color, fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}