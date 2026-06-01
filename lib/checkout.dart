import 'package:flutter/material.dart';
import 'product.dart';
import '../services/app_data.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<String> savedAddresses = [
    '12 Phố Trịnh Văn Bô, Nam Từ Liêm, Hà Nội',
    '456 Nguyễn Văn Bảo, Gò Vấp, TP.HCM',
    'Ký túc xá Khu B, Dĩ An, Bình Dương',
  ];

  late String selectedAddress;
  String selectedPaymentMethod = 'COD';

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _voucherController = TextEditingController();

  VoucherData? selectedVoucher;
  double _appliedVoucherPercent = 0.0;
  String _appliedVoucherCode = '';

  @override
  void initState() {
    super.initState();
    selectedAddress = savedAddresses[0];

    _appliedVoucherPercent = AppData.appliedVoucherPercent;
    _appliedVoucherCode = AppData.appliedVoucherCode;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  String formatCurrency(int amount) {
    String result = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return '$result đ';
  }

  int get subtotal => AppData.cart.fold(
    0,
        (sum, item) => sum + item.product.rawPrice * item.quantity,
  );

  int get shippingFee => AppData.cart.isEmpty ? 0 : 30000;

  int get tierDiscountAmount {
    return (subtotal * AppData.discountPercent).round();
  }

  int get voucherDiscountAmount {
    return (subtotal * _appliedVoucherPercent).round();
  }

  int get finalTotal {
    return subtotal - tierDiscountAmount - voucherDiscountAmount + shippingFee;
  }

  int get earnedPoints {
    return ((finalTotal / 10000).floor() * AppData.tierMultiplier).round();
  }

  void _applyVoucherByCode() {
    String code = _voucherController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã giảm giá!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double percent = 0.0;

    if (code == '5AE5' || code == 'SALE5') {
      percent = 0.05;
    } else if (code == 'SALE10') {
      percent = 0.10;
    } else if (code == 'VIP15') {
      percent = 0.15;
    }

    if (percent == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedVoucher = null;
      _appliedVoucherPercent = percent;
      _appliedVoucherCode = code;

      AppData.appliedVoucherPercent = percent;
      AppData.appliedVoucherCode = code;
    });

    FocusManager.instance.primaryFocus?.unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Áp dụng mã giảm ${(percent * 100).toInt()}% thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeVoucher() {
    setState(() {
      selectedVoucher = null;
      _voucherController.clear();
      _appliedVoucherPercent = 0.0;
      _appliedVoucherCode = '';

      AppData.removeVoucher();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hủy voucher đang áp dụng!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showVoucherWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'VÍ VOUCHER CỦA BẠN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Điểm hiện có: ${AppData.currentPoints} điểm',
                    style: const TextStyle(color: Colors.amber),
                  ),
                  const SizedBox(height: 16),

                  if (AppData.myVouchers.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Bạn chưa có voucher nào. Hãy đổi điểm ở danh sách bên dưới.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (AppData.myVouchers.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: AppData.myVouchers.length,
                        itemBuilder: (_, index) {
                          final voucher = AppData.myVouchers[index];

                          return Card(
                            color: voucher.isUsed
                                ? Colors.grey[800]
                                : Colors.redAccent.withOpacity(0.18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: voucher.isUsed
                                    ? Colors.white12
                                    : Colors.redAccent,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.card_giftcard,
                                color: voucher.isUsed
                                    ? Colors.grey
                                    : Colors.redAccent,
                              ),
                              title: Text(
                                voucher.title,
                                style: TextStyle(
                                  color: voucher.isUsed
                                      ? Colors.grey
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                voucher.isUsed
                                    ? 'Voucher đã được sử dụng'
                                    : voucher.description,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              trailing: Text(
                                '-${(voucher.discountPercent * 100).toInt()}%',
                                style: TextStyle(
                                  color: voucher.isUsed
                                      ? Colors.grey
                                      : Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: voucher.isUsed
                                  ? null
                                  : () {
                                setState(() {
                                  selectedVoucher = voucher;
                                  _appliedVoucherPercent =
                                      voucher.discountPercent;
                                  _appliedVoucherCode = voucher.code;

                                  AppData.applyVoucher(voucher);
                                });

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã chọn voucher ${voucher.title}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 18),
                  const Text(
                    'Đổi điểm lấy voucher',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: AppData.availableVouchers.length,
                      itemBuilder: (_, index) {
                        final voucher = AppData.availableVouchers[index];
                        final canExchange =
                            AppData.currentPoints >= voucher.requiredPoints;

                        return Card(
                          color: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.stars,
                              color: Colors.amber,
                            ),
                            title: Text(
                              voucher.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${voucher.description}\nCần ${voucher.requiredPoints} điểm',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canExchange
                                    ? Colors.redAccent
                                    : Colors.grey,
                              ),
                              onPressed: canExchange
                                  ? () {
                                bool success =
                                AppData.exchangeVoucher(voucher);

                                modalSetState(() {});
                                setState(() {});

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Đổi voucher thành công!'
                                          : 'Bạn không đủ điểm!',
                                    ),
                                    backgroundColor: success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                                  : null,
                              child: const Text(
                                'Đổi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CHỌN ĐỊA CHỈ GIAO HÀNG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ...savedAddresses.map(
                    (address) => ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: address == selectedAddress
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                  title: Text(
                    address,
                    style: TextStyle(
                      color: address == selectedAddress
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                  ),
                  trailing: address == selectedAddress
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => selectedAddress = address);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (AppData.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng đang trống!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await AppData.processCheckout(
        selectedPaymentMethod,
        selectedAddress,
        _noteController.text,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
            size: 62,
          ),
          content: Text(
            'ĐẶT HÀNG THÀNH CÔNG!\n\nBạn nhận được $earnedPoints điểm thưởng.\nHạng hiện tại: ${AppData.userTier}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'VỀ TRANG CHỦ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
      String label,
      String value,
      Color color, {
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile({
    required String value,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return RadioListTile(
      value: value,
      groupValue: selectedPaymentMethod,
      activeColor: Colors.redAccent,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      secondary: Icon(icon, color: iconColor),
      onChanged: (val) {
        setState(() => selectedPaymentMethod = val.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Địa chỉ nhận hàng', Icons.location_on_outlined),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showAddressPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phạm Trí Tín | +84 912 345 678',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            selectedAddress,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Sản phẩm', Icons.shopping_bag_outlined),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: AppData.cart.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Giỏ hàng đang trống',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppData.cart.length,
                itemBuilder: (context, index) {
                  final item = AppData.cart[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item.product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      formatCurrency(item.product.rawPrice),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Ghi chú cho cửa hàng', Icons.edit_note),
            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'VD: Giao giờ hành chính...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Mã giảm giá / Voucher', Icons.local_offer),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black26,
                            hintText: 'Nhập mã: 5AE5, SALE5, SALE10, VIP15',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _applyVoucherByCode,
                        child: const Text(
                          'ÁP DỤNG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.amber),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _showVoucherWallet,
                          icon: const Icon(
                            Icons.wallet_giftcard,
                            color: Colors.amber,
                          ),
                          label: const Text(
                            'Chọn / đổi voucher',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ),
                      if (_appliedVoucherPercent > 0) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _removeVoucher,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (_appliedVoucherPercent > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Đang áp dụng: $_appliedVoucherCode - Giảm ${(100 * _appliedVoucherPercent).toInt()}%',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Thông tin thành viên', Icons.workspace_premium),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.28),
                    Colors.redAccent.withOpacity(0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Hạng thành viên',
                    AppData.userTier,
                    Colors.amber,
                    isBold: true,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Điểm hiện có',
                    '${AppData.currentPoints} điểm',
                    Colors.greenAccent,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Hệ số tích điểm',
                    'x${AppData.tierMultiplier}',
                    Colors.white,
                  ),
                  if (AppData.discountPercent > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'Ưu đãi theo hạng',
                      '${(AppData.discountPercent * 100).toInt()}%',
                      Colors.redAccent,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle(
              'Phương thức thanh toán',
              Icons.payments_outlined,
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildPaymentTile(
                    value: 'COD',
                    title: 'Thanh toán khi nhận hàng',
                    icon: Icons.local_shipping_outlined,
                    iconColor: Colors.blueAccent,
                  ),
                  _buildPaymentTile(
                    value: 'MOMO',
                    title: 'Ví điện tử MoMo',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.pinkAccent,
                  ),
                  _buildPaymentTile(
                    value: 'ZALOPAY',
                    title: 'Ví điện tử ZaloPay',
                    icon: Icons.account_balance,
                    iconColor: Colors.blue,
                  ),
                  _buildPaymentTile(
                    value: 'VNPAY',
                    title: 'Cổng thanh toán VNPay',
                    icon: Icons.qr_code_2,
                    iconColor: Colors.lightBlueAccent,
                  ),
                  _buildPaymentTile(
                    value: 'BANK',
                    title: 'Thẻ ngân hàng nội địa',
                    icon: Icons.credit_card,
                    iconColor: Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Chi tiết thanh toán', Icons.receipt_long),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Tạm tính (${AppData.cart.length} món)',
                    formatCurrency(subtotal),
                    Colors.white,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Phí giao hàng',
                    formatCurrency(shippingFee),
                    Colors.white,
                  ),
                  if (AppData.discountPercent > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'Ưu đãi hạng ${AppData.userTier}',
                      '- ${formatCurrency(tierDiscountAmount)}',
                      Colors.amber,
                    ),
                  ],
                  if (_appliedVoucherPercent > 0) ...[
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'Voucher $_appliedVoucherCode',
                      '- ${formatCurrency(voucherDiscountAmount)}',
                      Colors.greenAccent,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24),
                  ),
                  _buildSummaryRow(
                    'Điểm nhận được',
                    '$earnedPoints điểm',
                    Colors.greenAccent,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Tổng thanh toán',
                    formatCurrency(finalTotal),
                    Colors.redAccent,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: const Border(
            top: BorderSide(color: Colors.white10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cần thanh toán:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    formatCurrency(finalTotal),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '+$earnedPoints điểm',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _placeOrder,
                child: const Text(
                  'ĐẶT HÀNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}