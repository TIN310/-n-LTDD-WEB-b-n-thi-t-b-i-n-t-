import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product.dart';
import 'login.dart';
import 'category.dart';

// ==========================================
// ADMIN DASHBOARD - MÀN HÌNH QUẢN TRỊ VIÊN
// ==========================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _AdminHomeTab(),
      _AdminOrdersTab(onRefresh: () => setState(() {})),
      _AdminProductsTab(onRefresh: () => setState(() {})),
      const _AdminUsersTab(),
      const _AdminSettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF1A0000),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.redAccent,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Tổng quan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Đơn hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                activeIcon: Icon(Icons.storefront),
                label: 'Sản phẩm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group),
                label: 'Người dùng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Cài đặt',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: TỔNG QUAN & DOANH THU
// ==========================================

class _AdminHomeTab extends StatelessWidget {
  const _AdminHomeTab();

  // Mock tính doanh thu từ history
  int get _totalRevenue =>
      AppData.history.fold(0, (sum, o) => sum + o.totalAmount);

  int get _pendingCount =>
      AppData.history.where((o) => o.status == 'Chờ xác nhận').length;

  int get _completedCount =>
      AppData.history.where((o) => o.status == 'Đã giao thành công').length;

  int get _cancelledCount =>
      AppData.history.where((o) => o.status == 'Đã hủy').length;

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      double m = amount / 1000000;
      return '${m.toStringAsFixed(1)}M đ';
    }
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.')
        + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    final adminEmail =
        Supabase.instance.client.auth.currentUser?.email ?? 'Admin';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Panel',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
            Text(
              adminEmail,
              style:
              TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
            const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF3A0000),
                child: Icon(Icons.admin_panel_settings,
                    color: Colors.redAccent, size: 18),
              ),
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
            // ---- CARD DOANH THU NỔI BẬT ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng doanh thu',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tất cả thời gian',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(_totalRevenue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppData.history.length} đơn hàng tổng cộng',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- THỐNG KÊ 2x2 ----
            const _AdminSectionHeader(title: 'Thống kê đơn hàng'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _AdminStatCard(
                  title: 'Tổng đơn',
                  value: '${AppData.history.length}',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.blueAccent,
                  trend: '+12%',
                  trendUp: true,
                ),
                _AdminStatCard(
                  title: 'Chờ xác nhận',
                  value: '$_pendingCount',
                  icon: Icons.pending_actions_outlined,
                  color: Colors.orange,
                ),
                _AdminStatCard(
                  title: 'Hoàn thành',
                  value: '$_completedCount',
                  icon: Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  trend: '+5%',
                  trendUp: true,
                ),
                _AdminStatCard(
                  title: 'Đã hủy',
                  value: '$_cancelledCount',
                  icon: Icons.cancel_outlined,
                  color: Colors.redAccent,
                  trend: '-2%',
                  trendUp: false,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- BIỂU ĐỒ DOANH THU (MOCK BAR CHART) ----
            const _AdminSectionHeader(title: 'Doanh thu 7 ngày qua'),
            const SizedBox(height: 12),
            _RevenueBarChart(),
            const SizedBox(height: 24),

            // ---- TOP SẢN PHẨM BÁN CHẠY ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _AdminSectionHeader(title: 'Sản phẩm bán chạy'),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả',
                      style: TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...mockProducts
                .take(3)
                .toList()
                .asMap()
                .entries
                .map((entry) => _TopProductRow(
              rank: entry.key + 1,
              product: entry.value,
            )),
            const SizedBox(height: 24),

            // ---- ĐƠN HÀNG GẦN NHẤT ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _AdminSectionHeader(title: 'Đơn hàng gần đây'),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả',
                      style: TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (AppData.history.isEmpty)
              _buildEmptyState('Chưa có đơn hàng nào')
            else
              ...AppData.history
                  .take(5)
                  .map((o) => _AdminOrderRow(order: o)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(msg,
            style: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}

// ==========================================
// TAB 2: QUẢN LÝ ĐƠN HÀNG (ADMIN)
// ==========================================

class _AdminOrdersTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AdminOrdersTab({required this.onRefresh});

  @override
  State<_AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<_AdminOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'Tất cả';

  final List<String> _statusList = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang giao',
    'Đã giao thành công',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() =>
      _filterStatus = _statusList[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderData> get _filteredOrders => _filterStatus == 'Tất cả'
      ? AppData.history
      : AppData.history
      .where((o) => o.status == _filterStatus)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Quản lý đơn hàng',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: Colors.white),
            tooltip: 'Xuất danh sách',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đang xuất file CSV...'),
                backgroundColor: Colors.grey[800],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          tabs: _statusList
              .map((s) => Tab(
            child: Text(s,
                style: const TextStyle(fontSize: 13)),
          ))
              .toList(),
        ),
      ),
      body: _filteredOrders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 72, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text('Không có đơn hàng',
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        physics: const BouncingScrollPhysics(),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _AdminFullOrderCard(
            order: order,
            onStatusChanged: () => setState(() {}),
          );
        },
      ),
    );
  }
}

// ==========================================
// TAB 3: QUẢN LÝ SẢN PHẨM (ADMIN)
// ==========================================

class _AdminProductsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AdminProductsTab({required this.onRefresh});

  @override
  State<_AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<_AdminProductsTab> {
  String _searchQuery = '';

  List<Product> get _filteredProducts => mockProducts
      .where((p) =>
  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.brand.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Quản lý sản phẩm',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined, color: Colors.white),
            tooltip: 'Quản lý danh mục',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                  const CategoryScreen(role: 'Quản trị viên')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm SP',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditProductSheet(context, null),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Tìm theo tên, hãng...',
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
          const SizedBox(height: 8),

          // Tổng số sản phẩm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredProducts.length} sản phẩm',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách
          Expanded(
            child: ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _AdminProductCard(
                  product: product,
                  onEdit: () =>
                      _showAddEditProductSheet(context, product),
                  onDelete: () =>
                      _confirmDeleteProduct(context, product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductSheet(
      BuildContext context, Product? product) {
    final isEdit = product != null;
    final nameCtrl =
    TextEditingController(text: product?.name ?? '');
    final priceCtrl =
    TextEditingController(text: product?.rawPrice.toString() ?? '');
    final brandCtrl =
    TextEditingController(text: product?.brand ?? '');
    final imageCtrl =
    TextEditingController(text: product?.imageUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSheetTextField(nameCtrl, 'Tên sản phẩm', Icons.label_outline),
            const SizedBox(height: 12),
            _buildSheetTextField(brandCtrl, 'Hãng sản xuất', Icons.business_outlined),
            const SizedBox(height: 12),
            _buildSheetTextField(priceCtrl, 'Giá (VND)', Icons.attach_money,
                type: TextInputType.number),
            const SizedBox(height: 12),
            _buildSheetTextField(imageCtrl, 'URL ảnh sản phẩm', Icons.image_outlined),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(color: Colors.grey[700]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // TODO: Gọi Supabase để lưu
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit
                              ? 'Đã cập nhật sản phẩm'
                              : 'Đã thêm sản phẩm mới'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Text(
                      isEdit ? 'Lưu thay đổi' : 'Thêm mới',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetTextField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType type = TextInputType.text,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Xác nhận xóa',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa "${product.name}"?\nHành động này không thể hoàn tác.',
          style: TextStyle(color: Colors.grey[400]),
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
              // TODO: Xóa trên Supabase
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa sản phẩm'),
                  backgroundColor: Colors.grey[800],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Xóa',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: QUẢN LÝ NGƯỜI DÙNG
// ==========================================

class _AdminUsersTab extends StatefulWidget {
  const _AdminUsersTab();

  @override
  State<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<_AdminUsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _filterRole = 'Tất cả';
  String _searchQuery = '';

  // Map từ giá trị hiển thị sang giá trị DB và ngược lại
  static const Map<String, String> _roleToDb = {
    'Người dùng': 'user',
    'Nhân viên': 'staff',
    'Quản trị viên': 'admin',
  };
  static const Map<String, String> _roleFromDb = {
    'user': 'Người dùng',
    'staff': 'Nhân viên',
    'admin': 'Quản trị viên',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Load danh sách user từ bảng profiles
  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, role, created_at')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> loaded = (response as List).map((row) {
        return {
          'id': row['id'],
          'name': (row['full_name'] as String?)?.isNotEmpty == true
              ? row['full_name']
              : 'Người dùng',
          'email': '', // profiles không lưu email — hiển thị id rút gọn
          'role': _roleFromDb[row['role']] ?? 'Người dùng',
          'tier': '-',
          'orders': 0,
          'isLocked': false,
        };
      }).toList();

      if (mounted) setState(() { _users = loaded; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Đổi role — ghi trực tiếp vào bảng profiles trên Supabase
  // Lưu ý: cần cấp quyền UPDATE cho service_role hoặc dùng RLS admin bypass
  // Xem hướng dẫn ở cuối file
  Future<void> _changeRoleOnSupabase(Map<String, dynamic> user, String newRoleDisplay) async {
    final newRoleDb = _roleToDb[newRoleDisplay] ?? 'user';
    final oldRole = user['role'];

    // Cập nhật UI ngay để phản hồi nhanh (optimistic update)
    setState(() => user['role'] = newRoleDisplay);

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': newRoleDb})
          .eq('id', user['id'] as String);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đổi role ${user['name']} → $newRoleDisplay'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      // Rollback nếu lỗi
      if (mounted) {
        setState(() => user['role'] = oldRole);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đổi role: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers => _users.where((u) {
    final matchRole = _filterRole == 'Tất cả' || u['role'] == _filterRole;
    final matchSearch = u['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase());
    return matchRole && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
          // Bộ lọc role
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (v) => setState(() => _filterRole = v),
            itemBuilder: (_) => [
              'Tất cả',
              'Người dùng',
              'Nhân viên',
              'Quản trị viên',
            ]
                .map((r) => PopupMenuItem(
              value: r,
              child: Text(r,
                  style: TextStyle(
                      color: _filterRole == r
                          ? Colors.redAccent
                          : Colors.white)),
            ))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Tìm theo tên...',
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

          // Thống kê nhanh
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _UserCountBadge(
                    label: 'Tổng',
                    count: _users.length,
                    color: Colors.white),
                const SizedBox(width: 10),
                _UserCountBadge(
                    label: 'Khách',
                    count: _users
                        .where((u) => u['role'] == 'Người dùng')
                        .length,
                    color: Colors.blueAccent),
                const SizedBox(width: 10),
                _UserCountBadge(
                    label: 'Nhân viên',
                    count: _users
                        .where((u) => u['role'] == 'Nhân viên')
                        .length,
                    color: Colors.orange),
                const SizedBox(width: 10),
                _UserCountBadge(
                    label: 'Admin',
                    count: _users
                        .where((u) => u['role'] == 'Quản trị viên')
                        .length,
                    color: Colors.redAccent),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text('Không tìm thấy người dùng',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _AdminUserCard(
                  user: user,
                  onToggleLock: () {
                    // TODO: Khi có cột is_locked trong profiles thì gọi Supabase
                    // Hiện tại chỉ cập nhật local state
                    setState(() => user['isLocked'] = !user['isLocked']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(user['isLocked']
                            ? 'Đã khóa tài khoản ${user['name']}'
                            : 'Đã mở khóa tài khoản ${user['name']}'),
                        backgroundColor: user['isLocked']
                            ? Colors.redAccent
                            : Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  onChangeRole: (newRole) =>
                      _changeRoleOnSupabase(user, newRole),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 5: CÀI ĐẶT & VOUCHER
// ==========================================

class _AdminSettingsTab extends StatefulWidget {
  const _AdminSettingsTab();

  @override
  State<_AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<_AdminSettingsTab> {
  // Mock vouchers
  final List<Map<String, dynamic>> _vouchers = [
    {
      'code': 'GAMING50',
      'discount': '50%',
      'desc': 'Thiết bị Gaming',
      'uses': 34,
      'maxUses': 100,
      'active': true,
    },
    {
      'code': 'FREESHIP',
      'discount': 'Freeship',
      'desc': 'Cho đơn từ 300K',
      'uses': 87,
      'maxUses': 200,
      'active': true,
    },
    {
      'code': 'VIP10',
      'discount': '10%',
      'desc': 'Dành riêng VIP',
      'uses': 12,
      'maxUses': 50,
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Cài đặt & Voucher',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- QUẢN LÝ VOUCHER ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _AdminSectionHeader(title: 'Mã Voucher'),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text('Tạo mới',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddVoucherSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._vouchers
                .map((v) => _AdminVoucherCard(
              voucher: v,
              onToggle: () =>
                  setState(() => v['active'] = !v['active']),
              onDelete: () =>
                  setState(() => _vouchers.remove(v)),
            )),
            const SizedBox(height: 24),

            // ---- CÀI ĐẶT CỬA HÀNG ----
            const _AdminSectionHeader(title: 'Cài đặt cửa hàng'),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: Icons.store_outlined,
              title: 'Thông tin cửa hàng',
              subtitle: '5AE Electro Store',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Phí vận chuyển',
              subtitle: 'Cố định 30.000 đ',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              context,
              icon: Icons.image_outlined,
              title: 'Banner quảng cáo',
              subtitle: '3 banner đang hiển thị',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingItem(
              context,
              icon: Icons.workspace_premium_outlined,
              title: 'Hạng thành viên',
              subtitle: 'Thân thiết / VIP / Kim cương',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 24),

            // ---- TÀI KHOẢN ----
            const _AdminSectionHeader(title: 'Tài khoản'),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              subtitle: '',
              onTap: () => _showComingSoon(context),
            ),
            _buildDangerItem(
              context,
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 10),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.redAccent, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle,
            style:
            TextStyle(color: Colors.grey[500], fontSize: 12))
            : null,
        trailing:
        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      color: Colors.redAccent.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 10),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent, size: 22),
        title: Text(title,
            style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        onTap: onTap,
      ),
    );
  }

  void _showAddVoucherSheet(BuildContext context) {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final maxUsesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text('Tạo voucher mới',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildVoucherField(codeCtrl, 'Mã voucher (VD: SALE20)',
                Icons.local_offer_outlined),
            const SizedBox(height: 12),
            _buildVoucherField(discountCtrl,
                'Mức giảm (VD: 20% hoặc 50K)', Icons.percent),
            const SizedBox(height: 12),
            _buildVoucherField(
                descCtrl, 'Mô tả điều kiện', Icons.info_outline),
            const SizedBox(height: 12),
            _buildVoucherField(
                maxUsesCtrl, 'Số lượt dùng tối đa', Icons.confirmation_number_outlined,
                type: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (codeCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _vouchers.add({
                        'code': codeCtrl.text.trim().toUpperCase(),
                        'discount': discountCtrl.text.trim(),
                        'desc': descCtrl.text.trim(),
                        'uses': 0,
                        'maxUses':
                        int.tryParse(maxUsesCtrl.text) ?? 100,
                        'active': true,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã tạo voucher mới'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: const Text('Tạo Voucher',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherField(TextEditingController ctrl, String label,
      IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
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
// REUSABLE WIDGETS CHO ADMIN
// ==========================================

class _AdminSectionHeader extends StatelessWidget {
  final String title;
  const _AdminSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      trendUp! ? Icons.trending_up : Icons.trending_down,
                      color: trendUp! ? Colors.greenAccent : Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend!,
                      style: TextStyle(
                          color: trendUp!
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// Mock bar chart doanh thu
class _RevenueBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> _weekData = const [
    {'day': 'T2', 'amount': 0.4},
    {'day': 'T3', 'amount': 0.7},
    {'day': 'T4', 'amount': 0.5},
    {'day': 'T5', 'amount': 0.9},
    {'day': 'T6', 'amount': 0.6},
    {'day': 'T7', 'amount': 1.0},
    {'day': 'CN', 'amount': 0.8},
  ];

  _RevenueBarChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekData.map((d) {
          final double height = (d['amount'] as double) * 100;
          final bool isToday = d['day'] == 'T7';
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isToday
                        ? [Colors.redAccent, Colors.red.shade800]
                        : [Colors.grey[700]!, Colors.grey[800]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d['day'],
                style: TextStyle(
                  color: isToday ? Colors.redAccent : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final Product product;
  const _TopProductRow({required this.rank, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.amber.withOpacity(0.2)
                  : rank == 2
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.brown.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank == 1
                      ? Colors.amber
                      : rank == 2
                      ? Colors.grey[400]
                      : Colors.brown[300],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(product.imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, color: Colors.grey))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(product.brand,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(product.price,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AdminOrderRow extends StatelessWidget {
  final OrderData order;
  const _AdminOrderRow({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang giao':
        return Colors.blueAccent;
      case 'Đã giao thành công':
        return Colors.greenAccent;
      default:
        return Colors.redAccent;
    }
  }

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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.orderId,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text('${order.items.length} sản phẩm',
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(order.totalAmount),
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Card đơn hàng đầy đủ cho admin
class _AdminFullOrderCard extends StatelessWidget {
  final OrderData order;
  final VoidCallback onStatusChanged;

  const _AdminFullOrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang giao':
        return Colors.blueAccent;
      case 'Đã giao thành công':
        return Colors.greenAccent;
      default:
        return Colors.redAccent;
    }
  }

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
      margin: const EdgeInsets.only(bottom: 14),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status,
                      style: TextStyle(
                          color: _statusColor(order.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} sản phẩm • ${_formatCurrency(order.totalAmount)} • ${order.paymentMethod}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order.address,
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            // Admin có thể cập nhật sang bất kỳ trạng thái nào
            if (order.status != 'Đã giao thành công' &&
                order.status != 'Đã hủy') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Hủy đơn',
                          style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã hủy ${order.orderId}'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                        );
                        onStatusChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusColor(order.status),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.arrow_forward,
                          size: 16, color: Colors.white),
                      label: Text(
                        order.status == 'Chờ xác nhận'
                            ? 'Xác nhận giao'
                            : 'Đã giao xong',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text('Đã cập nhật ${order.orderId}'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                          ),
                        );
                        onStatusChanged();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Card sản phẩm cho admin
class _AdminProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(product.imageUrl,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      width: 65,
                      height: 65,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.grey))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.brand,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(product.price,
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blueAccent, size: 20),
                  tooltip: 'Chỉnh sửa',
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  tooltip: 'Xóa',
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Card user cho admin
class _AdminUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onToggleLock;
  final ValueChanged<String> onChangeRole;

  const _AdminUserCard({
    required this.user,
    required this.onToggleLock,
    required this.onChangeRole,
  });

  Color get _roleColor {
    switch (user['role']) {
      case 'Nhân viên':
        return Colors.orange;
      case 'Quản trị viên':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Color get _tierColor {
    switch (user['tier']) {
      case 'Kim cương':
        return Colors.cyanAccent;
      case 'VIP':
        return Colors.amber;
      case 'Thân thiết':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = user['isLocked'] == true;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _roleColor.withOpacity(0.15),
                  child: Text(
                    user['name'].toString()[0].toUpperCase(),
                    style: TextStyle(
                        color: _roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                if (isLocked)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(Icons.lock,
                        color: Colors.redAccent, size: 14),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: TextStyle(
                        color: isLocked
                            ? Colors.grey
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(user['email'],
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(user['role'],
                            style: TextStyle(
                                color: _roleColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      if (user['tier'] != '-') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _tierColor.withOpacity(0.15),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Text(user['tier'],
                              style: TextStyle(
                                  color: _tierColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Action menu
            PopupMenuButton<String>(
              icon:
              const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              color: Colors.grey[900],
              onSelected: (action) {
                if (action == 'lock') {
                  onToggleLock();
                } else if (action == 'staff') {
                  onChangeRole('Nhân viên');
                } else if (action == 'user') {
                  onChangeRole('Người dùng');
                } else if (action == 'admin') {
                  onChangeRole('Quản trị viên');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(
                        isLocked ? Icons.lock_open : Icons.lock_outline,
                        color: isLocked
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLocked ? 'Mở khóa' : 'Khóa tài khoản',
                        style: TextStyle(
                            color: isLocked
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                if (user['role'] != 'Nhân viên')
                  const PopupMenuItem(
                    value: 'staff',
                    child: Row(
                      children: [
                        Icon(Icons.badge_outlined,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 10),
                        Text('Đặt làm Nhân viên',
                            style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                if (user['role'] != 'Người dùng')
                  const PopupMenuItem(
                    value: 'user',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.blueAccent, size: 18),
                        SizedBox(width: 10),
                        Text('Hạ xuống Người dùng',
                            style:
                            TextStyle(color: Colors.blueAccent)),
                      ],
                    ),
                  ),
                if (user['role'] != 'Quản trị viên')
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 10),
                        Text('Nâng lên Quản trị viên',
                            style: TextStyle(color: Colors.redAccent)),
                      ],
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

// Card voucher cho admin
class _AdminVoucherCard extends StatelessWidget {
  final Map<String, dynamic> voucher;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AdminVoucherCard({
    required this.voucher,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = voucher['active'] == true;
    final double progress =
        (voucher['uses'] as int) / (voucher['maxUses'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.redAccent.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      voucher['code'],
                      style: TextStyle(
                          color:
                          isActive ? Colors.redAccent : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    voucher['discount'],
                    style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: [
                  Switch(
                    value: isActive,
                    activeColor: Colors.redAccent,
                    onChanged: (_) => onToggle(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.grey, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(voucher['desc'],
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 10),
          // Progress bar lượt dùng
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 0.9
                            ? Colors.redAccent
                            : Colors.greenAccent),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${voucher['uses']}/${voucher['maxUses']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserCountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _UserCountBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text('$count',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
        ],
      ),
    );
  }
}