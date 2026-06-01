import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product.dart';
import 'login.dart';
import 'chat.dart';

// ==========================================
// STAFF DASHBOARD - MÀN HÌNH NHÂN VIÊN
// ==========================================

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _StaffHomeTab(),
    _StaffOrdersTab(),
    _StaffInventoryTab(),
    _StaffChatSupportTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.grey[900],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.redAccent,
            unselectedItemColor: Colors.grey[500],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Tổng quan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Đơn hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Kho hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.headset_mic_outlined),
                activeIcon: Icon(Icons.headset_mic),
                label: 'Hỗ trợ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: TỔNG QUAN (HOME)
// ==========================================

class _StaffHomeTab extends StatefulWidget {
  const _StaffHomeTab();

  @override
  State<_StaffHomeTab> createState() => _StaffHomeTabState();
}

class _StaffHomeTabState extends State<_StaffHomeTab> {
  Key _streamKey = UniqueKey();

  void _reloadStream() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffName = Supabase.instance.client.auth.currentUser?.email
        ?.split('@')
        .first ??
        'Nhân viên';

    return StreamBuilder<List<Map<String, dynamic>>>(
      key: _streamKey,
      stream: Supabase.instance.client.from('orders').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        final allOrders = snapshot.data ?? [];
        
        final pendingOrdersList = allOrders.where((o) => o['status'] == 'Chờ xác nhận').toList();
        final pendingOrders = pendingOrdersList.length;
        final shippingOrders = allOrders.where((o) => o['status'] == 'Đang giao').length;
        final todayOrders = allOrders.length;
        final completedOrders = allOrders.where((o) => o['status'] == 'Đã giao thành công').length;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, $staffName 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Nhân viên bán hàng',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              // Badge thông báo
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  if (pendingOrders > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$pendingOrders',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              // Avatar nhân viên (có menu Đăng xuất)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PopupMenuButton<String>(
                  color: Colors.grey[900],
                  offset: const Offset(0, 45),
                  icon: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.redAccent.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.redAccent, size: 20),
                  ),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- BANNER CẢNH BÁO NẾU CÓ ĐƠN CẦN XỬ LÝ ----
                if (pendingOrders > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.orange.withOpacity(0.05)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border:
                      Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Có $pendingOrders đơn chờ xử lý',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              const Text(
                                'Vui lòng xác nhận sớm để khách không chờ lâu',
                                style:
                                TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ---- THỐNG KÊ NHANH (2x2 GRID) ----
                const _SectionHeader(title: 'Thống kê hôm nay'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StaffStatCard(
                      title: 'Chờ xác nhận',
                      value: '$pendingOrders',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    _StaffStatCard(
                      title: 'Đang giao',
                      value: '$shippingOrders',
                      icon: Icons.local_shipping_outlined,
                      color: Colors.blueAccent,
                    ),
                    _StaffStatCard(
                      title: 'Đơn hôm nay',
                      value: '$todayOrders',
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.purpleAccent,
                    ),
                    _StaffStatCard(
                      title: 'Đã hoàn thành',
                      value: '$completedOrders',
                      icon: Icons.check_circle_outline,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---- ĐƠN HÀNG CẦN XỬ LÝ NGAY ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionHeader(title: 'Đơn cần xử lý'),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Xem tất cả',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPendingOrdersList(context, pendingOrdersList),
                const SizedBox(height: 24),

                // ---- CÔNG CỤ NHANH ----
                const _SectionHeader(title: 'Công cụ nhanh'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionBtn(
                        icon: Icons.qr_code_scanner,
                        label: 'Quét đơn hàng',
                        color: Colors.teal,
                        onTap: () => _showComingSoon(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionBtn(
                        icon: Icons.inventory_2_outlined,
                        label: 'Kiểm kê kho',
                        color: Colors.indigo,
                        onTap: () => _showComingSoon(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionBtn(
                        icon: Icons.chat_outlined,
                        label: 'Chat CSKH',
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChatScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingOrdersList(BuildContext context, List<Map<String, dynamic>> pendingOrders) {
    if (pendingOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.greenAccent, size: 48),
            SizedBox(height: 12),
            Text(
              'Không có đơn chờ xử lý',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pendingOrders
          .take(3)
          .map((orderRow) {
            final priceVal = orderRow['total_price'] ?? 0;
            final priceNum = priceVal is num ? priceVal.toInt() : int.tryParse(priceVal.toString()) ?? 0;
            
            final order = OrderData(
              orderId: orderRow['id'].toString().substring(0, 8).toUpperCase(),
              items: [],
              totalAmount: priceNum,
              earnedPoints: 0,
              status: orderRow['status'] ?? 'Chờ xác nhận',
              paymentMethod: 'Thanh toán khi nhận hàng',
              address: 'Địa chỉ (Cập nhật sau)',
              note: '',
            );
            return _StaffOrderCard(
              order: order, 
              onStatusChanged: () async {
                try {
                  await Supabase.instance.client
                      .from('orders')
                      .update({'status': 'Đang giao'})
                      .eq('id', orderRow['id']);
                  _reloadStream();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
                  }
                }
              }
            );
          })
          .toList(),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tính năng đang phát triển'),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ==========================================
// TAB 2: QUẢN LÝ ĐƠN HÀNG
// ==========================================

class _StaffOrdersTab extends StatefulWidget {
  const _StaffOrdersTab();

  @override
  State<_StaffOrdersTab> createState() => _StaffOrdersTabState();
}

class _StaffOrdersTabState extends State<_StaffOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadAllTabs() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Đã giao'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: Column(
        children: [
          // THANH TÌM KIẾM ĐƠN HÀNG (Tính năng 3.2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đơn hàng...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderTabContent(
                  key: ValueKey('tab1_$_refreshKey'),
                  status: 'Chờ xác nhận',
                  statusColor: Colors.orange,
                  canUpdate: true,
                  nextStatus: 'Đang giao',
                  nextLabel: 'Xác nhận giao hàng',
                  searchQuery: _searchQuery,
                  onRefresh: _reloadAllTabs,
                ),
                _OrderTabContent(
                  key: ValueKey('tab2_$_refreshKey'),
                  status: 'Đang giao',
                  statusColor: Colors.blueAccent,
                  canUpdate: true,
                  nextStatus: 'Đã giao thành công',
                  nextLabel: 'Xác nhận đã giao',
                  searchQuery: _searchQuery,
                  onRefresh: _reloadAllTabs,
                ),
                _OrderTabContent(
                  key: ValueKey('tab3_$_refreshKey'),
                  status: 'Đã giao thành công',
                  statusColor: Colors.greenAccent,
                  canUpdate: false,
                  searchQuery: _searchQuery,
                  onRefresh: _reloadAllTabs,
                ),
                _OrderTabContent(
                  key: ValueKey('tab4_$_refreshKey'),
                  status: 'Đã hủy',
                  statusColor: Colors.redAccent,
                  canUpdate: false,
                  searchQuery: _searchQuery,
                  onRefresh: _reloadAllTabs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTabContent extends StatefulWidget {
  final String status;
  final Color statusColor;
  final bool canUpdate;
  final String? nextStatus;
  final String? nextLabel;
  final String searchQuery;
  final VoidCallback onRefresh;

  const _OrderTabContent({
    super.key,
    required this.status,
    required this.statusColor,
    required this.canUpdate,
    this.nextStatus,
    this.nextLabel,
    required this.searchQuery,
    required this.onRefresh,
  });

  @override
  State<_OrderTabContent> createState() => _OrderTabContentState();
}

class _OrderTabContentState extends State<_OrderTabContent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('status', widget.status)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải dữ liệu đơn hàng', style: TextStyle(color: Colors.redAccent)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
        }

        // Lọc dữ liệu theo Search Query (Tính năng 3.2)
        final ordersData = snapshot.data!.where((order) {
          if (widget.searchQuery.isEmpty) return true;
          final orderId = order['id'].toString().substring(0, 8).toLowerCase();
          return orderId.contains(widget.searchQuery);
        }).toList();

        if (ordersData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 72, color: Colors.grey[800]),
                const SizedBox(height: 16),
                Text(
                  'Không có đơn hàng',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.redAccent,
          backgroundColor: Colors.grey[900],
          onRefresh: () async {
            widget.onRefresh();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: ordersData.length,
          itemBuilder: (context, index) {
            final orderRow = ordersData[index];
            final priceVal = orderRow['total_price'] ?? 0;
            final priceNum = priceVal is num ? priceVal.toInt() : int.tryParse(priceVal.toString()) ?? 0;

            final order = OrderData(
              orderId: orderRow['id'].toString().substring(0, 8).toUpperCase(),
              items: [], // Tạm thời để trống chi tiết sản phẩm
              totalAmount: priceNum,
              earnedPoints: 0,
              status: orderRow['status'] ?? widget.status,
              paymentMethod: 'Thanh toán trực tuyến / COD',
              address: 'Địa chỉ nhận hàng (Cập nhật sau)',
              note: '',
            );

            return _DetailedOrderCard(
              order: order,
              statusColor: widget.statusColor,
              canUpdate: widget.canUpdate,
              nextStatus: widget.nextStatus,
              nextLabel: widget.nextLabel,
              onStatusChanged: () async {
                if (widget.nextStatus != null) {
                  try {
                    await Supabase.instance.client
                        .from('orders')
                        .update({'status': widget.nextStatus})
                        .eq('id', orderRow['id']);
                    widget.onRefresh(); // Trigger refresh on success
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi cập nhật: $e')),
                      );
                    }
                  }
                }
              },
            );
          },
        ), // Đóng ListView.builder
        ); // Đóng RefreshIndicator
      },
    );
  }
}

// ==========================================
// TAB 3: QUẢN LÝ KHO HÀNG
// ==========================================

class _StaffInventoryTab extends StatefulWidget {
  const _StaffInventoryTab();

  @override
  State<_StaffInventoryTab> createState() => _StaffInventoryTabState();
}

class _StaffInventoryTabState extends State<_StaffInventoryTab> {
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'low_stock', 'in_stock'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Kho hàng',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('products').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu', style: TextStyle(color: Colors.redAccent)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          final allProducts = snapshot.data!;
          final filtered = allProducts.where((p) {
            final name = (p['name'] as String? ?? '').toLowerCase();
            final brand = (p['brand'] as String? ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();
            final matchesSearch = name.contains(query) || brand.contains(query);

            final stock = (p['stock'] as num?)?.toInt() ?? 0;
            bool matchesFilter = true;
            if (_filterType == 'low_stock') {
              matchesFilter = stock <= 5;
            } else if (_filterType == 'in_stock') {
              matchesFilter = stock > 5;
            }

            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              // ---- THANH TÌM KIẾM ----
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    hintText: 'Tìm sản phẩm theo tên hoặc hãng...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.redAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ---- BỘ LỌC NHANH (Tính năng 3.3) ----
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _filterType == 'all',
                      onSelected: (_) => setState(() => _filterType = 'all'),
                      selectedColor: Colors.redAccent.withOpacity(0.3),
                      checkmarkColor: Colors.redAccent,
                      backgroundColor: Colors.grey[900],
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Sắp hết hàng (≤ 5)'),
                      selected: _filterType == 'low_stock',
                      onSelected: (_) => setState(() => _filterType = 'low_stock'),
                      selectedColor: Colors.orange.withOpacity(0.3),
                      checkmarkColor: Colors.orange,
                      backgroundColor: Colors.grey[900],
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Còn hàng'),
                      selected: _filterType == 'in_stock',
                      onSelected: (_) => setState(() => _filterType = 'in_stock'),
                      selectedColor: Colors.green.withOpacity(0.3),
                      checkmarkColor: Colors.greenAccent,
                      backgroundColor: Colors.grey[900],
                    ),
                  ],
                ),
              ),

              // ---- CẢNH BÁO HÀNG SẮP HẾT ----
              _buildLowStockBanner(allProducts),

              // ---- DANH SÁCH SẢN PHẨM ----
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    final priceVal = p['price'] ?? 0;
                    final priceNum = priceVal is num ? priceVal.toInt() : int.tryParse(priceVal.toString()) ?? 0;
                    
                    final product = Product(
                      id: p['id'].toString(),
                      name: p['name'] ?? 'Không tên',
                      price: '${priceNum.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.')} đ',
                      rawPrice: priceNum,
                      brand: p['brand'] ?? 'Khác',
                      imageUrl: p['image_url'] ?? '',
                    );
                    
                    final stock = (p['stock'] as num?)?.toInt() ?? 0;
                    
                    return _InventoryItemCard(
                      product: product,
                      stock: stock,
                      onUpdateStock: (newStock) async {
                        try {
                          await Supabase.instance.client
                              .from('products')
                              .update({'stock': newStock})
                              .eq('id', p['id']);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi cập nhật kho: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLowStockBanner(List<Map<String, dynamic>> allProducts) {
    final lowStock = allProducts.where((p) => (p['stock'] as num? ?? 0) <= 5).length;
    if (lowStock == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded,
              color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Text(
            '$lowStock sản phẩm sắp hết hàng (≤ 5)',
            style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: HỖ TRỢ KHÁCH HÀNG
// ==========================================

class _StaffChatSupportTab extends StatefulWidget {
  const _StaffChatSupportTab();

  @override
  State<_StaffChatSupportTab> createState() => _StaffChatSupportTabState();
}

class _StaffChatSupportTabState extends State<_StaffChatSupportTab> {
  // Bỏ static để có thể setState
  final List<Map<String, dynamic>> _tickets = [
    {
      'customer': 'Nguyễn Văn A',
      'issue': 'Đơn hàng #ORD001 chưa được giao',
      'time': '10 phút trước',
      'priority': 'high',
      'status': 'Chưa giải quyết',
    },
    {
      'customer': 'Trần Thị B',
      'issue': 'Sản phẩm bị lỗi, cần đổi trả',
      'time': '32 phút trước',
      'priority': 'high',
      'status': 'Chưa giải quyết',
    },
    {
      'customer': 'Lê Văn C',
      'issue': 'Hỏi về chính sách bảo hành',
      'time': '1 giờ trước',
      'priority': 'low',
      'status': 'Đang xử lý',
    },
    {
      'customer': 'Phạm Thị D',
      'issue': 'Voucher không áp dụng được',
      'time': '2 giờ trước',
      'priority': 'medium',
      'status': 'Đã giải quyết',
    },
  ];

  void _showReplyDialog(BuildContext context, int index) {
    final ticket = _tickets[index];
    final TextEditingController replyController = TextEditingController();
    String selectedStatus = ticket['status'] == 'Đã giải quyết' ? 'Đã giải quyết' : 'Đang xử lý';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Phản hồi khách hàng', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vấn đề: ${ticket['issue']}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: replyController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung phản hồi...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cập nhật trạng thái:', style: TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Chưa giải quyết', 'Đang xử lý', 'Đã giải quyết']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStatus = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      _tickets[index]['status'] = selectedStatus;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã gửi phản hồi và cập nhật trạng thái'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Gửi phản hồi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unresolvedCount =
        _tickets.where((t) => t['status'] == 'Chưa giải quyết').length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hỗ trợ khách hàng',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            if (unresolvedCount > 0)
              Text(
                '$unresolvedCount yêu cầu chưa xử lý',
                style: const TextStyle(
                    color: Colors.redAccent, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline,
                color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        physics: const BouncingScrollPhysics(),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return _SupportTicketCard(
            ticket: ticket,
            onReply: () => _showReplyDialog(context, index),
          );
        },
      ),
    );
  }
}

// ==========================================
// REUSABLE WIDGETS CHO STAFF
// ==========================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StaffStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StaffStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style:
                TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Card đơn hàng gọn trên HomeTab
class _StaffOrderCard extends StatelessWidget {
  final OrderData order;
  final VoidCallback onStatusChanged;

  const _StaffOrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  String _formatCurrency(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.')
        + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Chờ xác nhận',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} sản phẩm • ${_formatCurrency(order.totalAmount)}',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () =>
                      _showOrderDetail(context, order),
                  child: const Text('Chi tiết',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    // Gọi hàm onStatusChanged để cập nhật Supabase và UI
                    onStatusChanged();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xác nhận đơn ${order.orderId}'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Xác nhận',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderData order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }
}

// Card đơn hàng chi tiết ở tab Đơn hàng
class _DetailedOrderCard extends StatelessWidget {
  final OrderData order;
  final Color statusColor;
  final bool canUpdate;
  final String? nextStatus;
  final String? nextLabel;
  final VoidCallback onStatusChanged;

  const _DetailedOrderCard({
    required this.order,
    required this.statusColor,
    required this.canUpdate,
    this.nextStatus,
    this.nextLabel,
    required this.onStatusChanged,
  });

  String _formatCurrency(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.')
        + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.paymentMethod,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),

            // Địa chỉ giao
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.address,
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sản phẩm
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image,
                              color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('x${item.quantity}',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )),

            const Divider(color: Colors.white12, height: 16),

            // Tổng tiền + action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(order.totalAmount),
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                if (canUpdate && nextStatus != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // TODO: cập nhật lên Supabase
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('Đã cập nhật: $nextStatus'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                      );
                      onStatusChanged();
                    },
                    child: Text(
                      nextLabel ?? '',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Card tồn kho sản phẩm
class _InventoryItemCard extends StatelessWidget {
  final Product product;
  final int stock;
  final ValueChanged<int> onUpdateStock;

  const _InventoryItemCard({
    required this.product,
    required this.stock,
    required this.onUpdateStock,
  });

  Color get _stockColor {
    if (stock == 0) return Colors.redAccent;
    if (stock <= 5) return Colors.orange;
    return Colors.greenAccent;
  }

  String get _stockLabel {
    if (stock == 0) return 'Hết hàng';
    if (stock <= 5) return 'Sắp hết';
    return 'Còn hàng';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 56,
              height: 56,
              color: Colors.grey[800],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.price,
              style: const TextStyle(
                  color: Colors.redAccent, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _stockColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _stockLabel,
                    style: TextStyle(
                        color: _stockColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Còn $stock cái',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          onPressed: () => _showUpdateStockDialog(context),
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context) {
    final controller =
    TextEditingController(text: stock.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Cập nhật tồn kho\n${product.name}',
          style: const TextStyle(
              color: Colors.white, fontSize: 15),
          maxLines: 2,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Số lượng',
            labelStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.inventory_2_outlined,
                color: Colors.redAccent),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () {
              final newStock =
                  int.tryParse(controller.text) ?? stock;
              onUpdateStock(newStock);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Đã cập nhật tồn kho: $newStock cái'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Lưu',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Card ticket hỗ trợ
class _SupportTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onReply;
  const _SupportTicketCard({required this.ticket, required this.onReply});

  Color get _priorityColor {
    switch (ticket['priority']) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.greenAccent;
    }
  }

  Color get _statusColor {
    switch (ticket['status']) {
      case 'Chưa giải quyết':
        return Colors.redAccent;
      case 'Đang xử lý':
        return Colors.orange;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      _priorityColor.withOpacity(0.15),
                      child: Text(
                        ticket['customer'][0],
                        style: TextStyle(
                            color: _priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ticket['customer'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket['status'],
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket['issue'],
              style:
              TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket['time'],
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 12),
                ),
                if (ticket['status'] != 'Đã giải quyết')
                  TextButton.icon(
                    onPressed: onReply,
                    icon: const Icon(Icons.reply,
                        size: 16, color: Colors.blueAccent),
                    label: const Text(
                      'Phản hồi',
                      style: TextStyle(
                          color: Colors.blueAccent, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet chi tiết đơn hàng
class _OrderDetailSheet extends StatelessWidget {
  final OrderData order;
  const _OrderDetailSheet({required this.order});

  String _formatCurrency(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.')
        + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chi tiết đơn ${order.orderId}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.local_shipping_outlined,
                'Trạng thái', order.status),
            _buildInfoRow(Icons.payment_outlined,
                'Thanh toán', order.paymentMethod),
            _buildInfoRow(Icons.location_on_outlined,
                'Địa chỉ', order.address),
            if (order.note.isNotEmpty)
              _buildInfoRow(Icons.note_outlined, 'Ghi chú', order.note),
            const Divider(color: Colors.white12, height: 24),
            const Text(
              'Sản phẩm',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.product.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(Icons.image,
                                color: Colors.grey))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                            '${item.product.price} x ${item.quantity}',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const Divider(color: Colors.white12, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(
                  _formatCurrency(order.totalAmount),
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[500], size: 18),
          const SizedBox(width: 10),
          Text('$label: ',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}