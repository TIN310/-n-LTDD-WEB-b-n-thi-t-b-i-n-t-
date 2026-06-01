import 'package:flutter/material.dart';
import 'product.dart';
import '../services/app_data.dart';
class VoucherWalletScreen extends StatefulWidget {
  const VoucherWalletScreen({super.key});

  @override
  State<VoucherWalletScreen> createState() => _VoucherWalletScreenState();
}

class _VoucherWalletScreenState extends State<VoucherWalletScreen> {
  void _applyVoucher(VoucherData voucher) {
    if (voucher.isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher này đã được sử dụng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AppData.applyVoucher(voucher);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chọn ${voucher.title} cho đơn hàng tiếp theo',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getVoucherColor(double percent) {
    if (percent >= 0.15) return Colors.purple;
    if (percent >= 0.10) return Colors.redAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final available =
    AppData.myVouchers.where((e) => !e.isUsed).toList();

    final used =
    AppData.myVouchers.where((e) => e.isUsed).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Ví Voucher',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: available.isEmpty && used.isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            const Text(
              'Voucher khả dụng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...available.map(
                  (voucher) =>
                  _buildVoucherCard(voucher),
            ),

            if (used.isNotEmpty) ...[
              const SizedBox(height: 25),

              const Text(
                'Voucher đã sử dụng',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...used.map(
                    (voucher) =>
                    _buildVoucherCard(voucher),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5A0000),
            Color(0xFFB71C1C),
          ],
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.card_giftcard,
              color: Colors.amber,
              size: 32,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kho voucher cá nhân',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${AppData.myVouchers.length} voucher',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(
      VoucherData voucher) {
    final color =
    _getVoucherColor(voucher.discountPercent);

    final selected =
        AppData.appliedVoucherCode ==
            voucher.code;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? Colors.greenAccent
              : Colors.white10,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: voucher.isUsed
                  ? Colors.grey
                  : color,
              borderRadius:
              const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
            child: Center(
              child: Text(
                voucher.isUsed
                    ? 'USED'
                    : '-${(voucher.discountPercent * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: TextStyle(
                      color: voucher.isUsed
                          ? Colors.grey
                          : Colors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    voucher.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment:
                    Alignment.centerRight,
                    child: voucher.isUsed
                        ? const Text(
                      'Đã sử dụng',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    )
                        : ElevatedButton(
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        selected
                            ? Colors
                            .green
                            : Colors
                            .redAccent,
                      ),
                      onPressed: () =>
                          _applyVoucher(
                              voucher),
                      child: Text(
                        selected
                            ? 'Đang dùng'
                            : 'Sử dụng',
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 90,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 20),
            const Text(
              'Bạn chưa có voucher nào',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hãy vào mục Voucher để đổi điểm lấy mã giảm giá.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}