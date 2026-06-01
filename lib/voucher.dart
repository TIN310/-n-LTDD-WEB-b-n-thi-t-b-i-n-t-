import 'package:flutter/material.dart';
import '../product.dart';
import '../services/app_data.dart';
class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  void _exchangeVoucher(VoucherData voucher) {
    bool success = AppData.exchangeVoucher(voucher);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đổi voucher ${voucher.title} thành công!'
              : 'Bạn không đủ điểm để đổi voucher này!',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _useVoucher(VoucherData voucher) {
    if (voucher.isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher này đã được sử dụng!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AppData.applyVoucher(voucher);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng voucher ${voucher.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getVoucherColor(double percent) {
    if (percent >= 0.15) return Colors.purpleAccent;
    if (percent >= 0.10) return Colors.redAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final unusedVouchers =
    AppData.myVouchers.where((voucher) => !voucher.isUsed).toList();

    final usedVouchers =
    AppData.myVouchers.where((voucher) => voucher.isUsed).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Kho Voucher',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointHeader(),

            const SizedBox(height: 22),

            const Text(
              'Đổi điểm lấy voucher',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...AppData.availableVouchers.map(
                  (voucher) => _buildExchangeCard(voucher),
            ),

            const SizedBox(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voucher của tôi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${unusedVouchers.length} khả dụng',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (AppData.myVouchers.isEmpty)
              _buildEmptyVoucher()
            else ...[
              ...unusedVouchers.map(
                    (voucher) => _buildMyVoucherCard(voucher),
              ),
              if (usedVouchers.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Voucher đã dùng',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...usedVouchers.map(
                      (voucher) => _buildMyVoucherCard(voucher),
                ),
              ],
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPointHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5A0000),
            Color(0xFFB71C1C),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.amber,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm thưởng hiện có',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppData.currentPoints} điểm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hạng: ${AppData.userTier}  •  Tích điểm x${AppData.tierMultiplier}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(VoucherData voucher) {
    final canExchange = AppData.currentPoints >= voucher.requiredPoints;
    final color = _getVoucherColor(voucher.discountPercent);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: canExchange ? color.withOpacity(0.8) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 105,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 6),
                Text(
                  '-${(voucher.discountPercent * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 8),
                  Text(
                    'Cần ${voucher.requiredPoints} điểm',
                    style: TextStyle(
                      color: canExchange ? Colors.amber : Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        canExchange ? Colors.redAccent : Colors.grey[700],
                        minimumSize: const Size(90, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed:
                      canExchange ? () => _exchangeVoucher(voucher) : null,
                      child: const Text(
                        'Đổi ngay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVoucherCard(VoucherData voucher) {
    final color = voucher.isUsed
        ? Colors.grey
        : _getVoucherColor(voucher.discountPercent);

    final isSelected = AppData.appliedVoucherCode == voucher.code;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.greenAccent : Colors.white10,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 95,
            height: 105,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  voucher.isUsed ? Icons.check_circle : Icons.card_giftcard,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 6),
                Text(
                  voucher.isUsed
                      ? 'ĐÃ DÙNG'
                      : '-${(voucher.discountPercent * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: TextStyle(
                      color: voucher.isUsed ? Colors.grey : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    voucher.isUsed
                        ? 'Voucher đã được sử dụng'
                        : voucher.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: voucher.isUsed
                        ? const Text(
                      'Không khả dụng',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    )
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.green
                            : Colors.redAccent,
                        minimumSize: const Size(90, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _useVoucher(voucher),
                      child: Text(
                        isSelected ? 'Đang dùng' : 'Dùng ngay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVoucher() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard,
            color: Colors.grey[600],
            size: 50,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn chưa có voucher nào',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy dùng điểm thưởng để đổi voucher giảm giá.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}