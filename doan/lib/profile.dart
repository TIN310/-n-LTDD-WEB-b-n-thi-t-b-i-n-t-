import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'product.dart';
import 'history.dart';
import 'favorite.dart';
import 'voucher.dart';
import 'support.dart';

class VipProfileScreen extends StatefulWidget {
  const VipProfileScreen({super.key});

  @override
  State<VipProfileScreen> createState() => _VipProfileScreenState();
}

class _VipProfileScreenState extends State<VipProfileScreen> {
  // Tính tỷ lệ thanh tiến trình (chia đều 3 mốc: 0->33%, 33->66%, 66->100%)
  double get uiProgress {
    int p = AppData.lifetimePoints;
    if (p <= 5000) return (p / 5000) * 0.3333;
    if (p <= 20000) return 0.3333 + ((p - 5000) / 15000) * 0.3333;
    if (p <= 50000) return 0.6666 + ((p - 20000) / 30000) * 0.3333;
    return 1.0;
  }

  int get targetPoints {
    if (AppData.lifetimePoints < 5000) return 5000;
    if (AppData.lifetimePoints < 20000) return 20000;
    if (AppData.lifetimePoints < 50000) return 50000;
    return 50000;
  }

  String get nextTier {
    if (AppData.lifetimePoints < 5000) return 'Thân thiết';
    if (AppData.lifetimePoints < 20000) return 'VIP';
    if (AppData.lifetimePoints < 50000) return 'Kim cương';
    return 'MAX';
  }

  @override
  Widget build(BuildContext context) {
    int pendingCount = AppData.history.where((o) => o.status == 'Chờ xác nhận').length;
    int shippingCount = AppData.history.where((o) => o.status == 'Đang giao').length;
    int ratingCount = AppData.history.where((o) => o.status == 'Đã giao thành công').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER LÀM LẠI BỐ CỤC KHÔNG BỊ CHE CHỮ
            // ==========================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Phần nền đỏ đun chứa Avatar + Tên + SĐT
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF5A0000), Color(0xFF0A0A0A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // Khoảng cách từ trên cùng xuống
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]), boxShadow: [BoxShadow(color: Colors.amber.withAlpha(77), blurRadius: 20)]),
                        child: const CircleAvatar(radius: 45, backgroundImage: NetworkImage('https://i.pravatar.cc/300')),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Phạm Trí Tín', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 6),
                          if(AppData.lifetimePoints >= 20000) const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('+84 912 345 678', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),

                // THẺ VIP CỐ ĐỊNH NẰM DƯỚI SỐ ĐIỆN THOẠI
                Positioned(
                  top: 250, // Định vị cách top 250px (vừa khít dưới SĐT)
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: AppData.lifetimePoints >= 50000
                            ? const LinearGradient(colors: [Color(0xFFB9F2FF), Color(0xFFE2F9FF)]) // Kim Cương
                            : AppData.lifetimePoints >= 20000
                            ? const LinearGradient(colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)]) // VIP
                            : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF)]), // Thân thiết/Khách hàng
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppData.userTier.toUpperCase(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
                            Icon(Icons.diamond, color: Colors.black87.withAlpha(204)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${AppData.lifetimePoints}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(width: 4),
                            const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Điểm', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // THANH TIẾN TRÌNH TÍCH ĐIỂM (MỚI ĐẸP HƠN)
                        LayoutBuilder(
                            builder: (context, constraints) {
                              double maxWidth = constraints.maxWidth;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 20, // Đủ cao để chứa dấu chấm tròn lớn
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Nền thanh mờ
                                        Container(height: 8, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4))),
                                        // Thanh phần trăm (Màu nổi)
                                        Container(
                                            height: 8,
                                            width: maxWidth * uiProgress,
                                            decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 6)]
                                            )
                                        ),
                                        // 4 Điểm Mốc (Kèm Tooltip)
                                        _buildMilestoneDot('Khách Mới', 0, 0.0, maxWidth, 'Tích điểm cơ bản\n(Tỷ lệ x1.0)'),
                                        _buildMilestoneDot('Thân thiết', 5000, 0.3333, maxWidth, 'Giảm 5% mọi đơn hàng\n(Tỷ lệ x1.2)'),
                                        _buildMilestoneDot('VIP', 20000, 0.6666, maxWidth, 'Giảm 8%, Freeship\n(Tỷ lệ x1.5)'),
                                        _buildMilestoneDot('Kim Cương', 50000, 1.0, maxWidth, 'Giảm 12%, Quà Sinh Nhật\n(Tỷ lệ x2.0)'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Hàng chữ chú thích tên hạng bên dưới thanh
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Khách', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                                      Text('Thân thiết', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                                      Text('VIP', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                                      Text('Kim cương', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              );
                            }
                        ),

                        const SizedBox(height: 12),
                        if (AppData.lifetimePoints < 50000)
                          Text('Còn ${targetPoints - AppData.lifetimePoints} điểm để thăng hạng $nextTier. (Chạm/rê chuột vào mốc để xem ưu đãi)', style: const TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))
                        else
                          const Text('Bạn đã đạt cấp bậc cao nhất! Tận hưởng các đặc quyền Kim Cương.', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Chừa một khoảng trống bù vào phần thẻ VIP bị đẩy xuống
            const SizedBox(height: 160),

            // ==========================================
            // 2. TÌNH TRẠNG ĐƠN HÀNG
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Đơn mua của tôi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          child: Text('Xem lịch sử >', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOrderIcon(Icons.receipt_long, 'Chờ xác nhận', pendingCount > 0 ? '$pendingCount' : '', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                        }),
                        _buildOrderIcon(Icons.inventory_2_outlined, 'Chờ lấy hàng', '', () {}),
                        _buildOrderIcon(Icons.local_shipping_outlined, 'Đang giao', shippingCount > 0 ? '$shippingCount' : '', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                        }),
                        _buildOrderIcon(Icons.star_border_outlined, 'Đánh giá', ratingCount > 0 ? '$ratingCount' : '', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 3. MENU CHỨC NĂNG BÊN DƯỚI
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TIỆN ÍCH CỦA TÔI', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListTileGroup([
                    _buildMenuItem(Icons.favorite_border, 'Sản phẩm yêu thích', true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()))),
                    _buildMenuItem(Icons.local_offer_outlined, 'Kho Voucher', true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherScreen()))),
                    _buildMenuItem(Icons.access_time, 'Đã xem gần đây', false, onTap: () {}),
                  ]),

                  const SizedBox(height: 20),
                  const Text('CÀI ĐẶT TÀI KHOẢN', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListTileGroup([
                    _buildMenuItem(Icons.person_outline, 'Thông tin cá nhân', true, onTap: () {}),
                    _buildMenuItem(Icons.location_on_outlined, 'Sổ địa chỉ', true, onTap: () {}),
                    _buildMenuItem(Icons.payment, 'Tài khoản ngân hàng / Thẻ', false, onTap: () {}),
                  ]),

                  const SizedBox(height: 20),
                  const Text('HỖ TRỢ', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListTileGroup([
                    _buildMenuItem(Icons.support_agent, 'Trung tâm trợ giúp', true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
                    _buildMenuItem(Icons.chat_outlined, 'Trò chuyện với Electro Store', false, onTap: () {}),
                  ]),

                  const SizedBox(height: 30),
                  _buildLogoutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM TẠO CHẤM TRÒN VÀ TOOLTIP BẢNG GIÁ/ƯU ĐÃI ---
  Widget _buildMilestoneDot(String tierName, int reqPoints, double leftRatio, double maxWidth, String benefits) {
    bool isReached = AppData.lifetimePoints >= reqPoints;
    double dotSize = 18.0; // Tăng kích thước chấm cho dễ nhấn

    return Positioned(
      left: leftRatio == 1.0 ? null : (maxWidth * leftRatio) - (leftRatio == 0.0 ? 0 : dotSize / 2),
      right: leftRatio == 1.0 ? 0 : null,
      child: Tooltip(
        message: 'HẠNG ${tierName.toUpperCase()}\n🎯 Yêu cầu: $reqPoints điểm\n🎁 Ưu đãi: $benefits',
        triggerMode: TooltipTriggerMode.tap, // Chạm vào trên màn hình cảm ứng
        showDuration: const Duration(seconds: 4),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.redAccent, width: 1.5)
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
        child: Container(
          width: dotSize, height: dotSize,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReached ? Colors.redAccent : Colors.white,
              border: Border.all(color: isReached ? Colors.white : Colors.grey[400]!, width: 3), // Viền nổi
              boxShadow: [
                if(isReached) BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)
              ]
          ),
        ),
      ),
    );
  }

  // --- WIDGET HIỂN THỊ CÁC ICON ĐƠN HÀNG (CÓ BADGE ĐẾM SỐ) ---
  Widget _buildOrderIcon(IconData icon, String label, String badgeCount, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white70, size: 30),
              if (badgeCount.isNotEmpty)
                Positioned(
                  right: -8, top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF161616), width: 2)
                    ),
                    child: Text(badgeCount, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildListTileGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool hasDivider, {required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.redAccent),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          onTap: onTap,
        ),
        if (hasDivider) const Divider(height: 1, indent: 56, endIndent: 16, color: Colors.white10),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (e) {
            // Nếu signOut thất bại, vẫn tiếp tục điều hướng về LoginScreen
            debugPrint('signOut error: $e');
          }
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.redAccent.withAlpha(128)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}