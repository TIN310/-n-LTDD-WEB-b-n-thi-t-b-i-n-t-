import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product.dart';
import 'screens/detail.dart';
import 'profile.dart';
import 'category.dart';
import 'cart.dart';
import 'favorite.dart';
import 'history.dart';
import 'voucher.dart';
import 'support.dart';
import 'chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  int _currentBannerIndex = 0;
  String _searchQuery = '';
  String _selectedBrand = 'Tất cả';

  List<Product> _realProducts = [];
  bool _isLoading = true;

  late PageController _pageController;
  late Timer _bannerTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> brands = ['Tất cả', 'Asus', 'Samsung', 'Sony', 'Logitech', 'LG'];
  final List<String> categories = ['Tất cả', 'Laptop', 'Điện thoại', 'Phụ kiện', 'Màn hình'];

  final List<Map<String, dynamic>> banners = [
    {'title': 'GIẢM GIÁ 50%\nTHIẾT BỊ GAMING', 'color1': Colors.redAccent, 'color2': Colors.black87},
    {'title': 'SIÊU SALE APPLE\nĐỒNG GIÁ 99K', 'color1': Colors.blueAccent, 'color2': Colors.black87},
    {'title': 'TUẦN LỄ PHỤ KIỆN\nMUA 1 TẶNG 1', 'color1': Colors.orangeAccent, 'color2': Colors.black87},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductsFromSupabase();

    _pageController = PageController(initialPage: 0);
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentBannerIndex < banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  // ==========================================
  // ĐÃ SỬA: Hàm gọi dữ liệu từ Database
  // ==========================================
  Future<void> _fetchProductsFromSupabase() async {
    try {
      final data = await Supabase.instance.client
          .from('sanpham')
      // CHÚ Ý: Toàn bộ tên cột đã được đưa về chữ thường
          .select('masp, tensp, gia, loaisanpham(tenloai), hinhanhsp(urlanh)');
      // Tạm tắt dòng lọc trạng thái để ép load toàn bộ dữ liệu
      // .eq('trangthai', 'Đã duyệt');

      if (mounted) {
        setState(() {
          _realProducts = (data as List).map((item) => Product.fromJson(item)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Hiển thị thẳng lỗi ra màn hình để bắt bệnh nếu còn lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải sản phẩm: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        elevation: 0,
        title: const Text('5AE', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.red),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
              ]
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
            backgroundColor: Colors.red,
            elevation: 0,
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.redAccent.withOpacity(0.15), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 5))
            ]
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
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildSearchTab();
      case 2: return const FavoriteScreen();
      case 3: return const VipProfileScreen();
      default: return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(colors: [banners[index]['color1'], banners[index]['color2']], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(color: banners[index]['color1'].withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Center(child: Text(banners[index]['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2))),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentBannerIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: _currentBannerIndex == index ? Colors.redAccent : Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text('Danh mục nổi bật', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.redAccent.withOpacity(0.15) : Colors.grey[900],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent, width: 1.5),
                    ),
                    child: Center(
                        child: Text(categories[index], style: TextStyle(color: isSelected ? Colors.redAccent : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 15))
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          const Text('Sản phẩm đề xuất', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.redAccent),
            )),

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 15),
            itemCount: _isLoading ? 0 : _realProducts.length,
            itemBuilder: (context, index) {
              final product = _realProducts[index];

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 800)),
                curve: Curves.easeOutQuart,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[800]!),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Hero(
                              tag: 'product_img_${product.name}',
                              child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.grey, size: 40))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text(product.brand, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 4)]
                                      ),
                                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16)
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    List<Product> filteredProducts = _realProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBrand = _selectedBrand == 'Tất cả' || product.brand == _selectedBrand;
      return matchesSearch && matchesBrand;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[900],
              hintText: 'Nhập tên sản phẩm cần tìm...', hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[800]!)),
            ),
          ),
          const SizedBox(height: 25),
          const Text('Nhà sản xuất', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = _selectedBrand == brand;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(brand, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14)),
                    selected: isSelected, selectedColor: Colors.redAccent.withOpacity(0.8), backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: isSelected ? Colors.redAccent : Colors.grey[800]!)),
                    onSelected: (selected) => setState(() => _selectedBrand = brand),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          Text('Kết quả: ${filteredProducts.length} sản phẩm', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Không tìm thấy sản phẩm nào!', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
              physics: const BouncingScrollPhysics(), itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  color: Colors.grey[900], margin: const EdgeInsets.only(bottom: 15), elevation: 5,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[850]!)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(product.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey))),
                    ),
                    title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Hãng: ${product.brand}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/300')),
            ),
            accountName: const Text('Phạm Trí Tín', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: const Text('Thành viên VIP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          _buildDrawerItem(icon: Icons.home_filled, title: 'Trang chủ', onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 0); }),
          _buildDrawerItem(icon: Icons.category_outlined, title: 'Danh mục sản phẩm', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())); }),
          _buildDrawerItem(icon: Icons.local_offer_outlined, title: 'Kho Voucher / Mã giảm giá', iconColor: Colors.amber, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherScreen())); }),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Divider(color: Colors.white24)),
          _buildDrawerItem(icon: Icons.history, title: 'Lịch sử mua hàng', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())); }),
          _buildDrawerItem(icon: Icons.favorite_border, title: 'Sản phẩm yêu thích', iconColor: Colors.pinkAccent, onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 2); }),
          _buildDrawerItem(icon: Icons.person_outline, title: 'Hồ sơ cá nhân', onTap: () { Navigator.pop(context); setState(() => _selectedIndex = 3); }),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Divider(color: Colors.white24)),
          _buildDrawerItem(icon: Icons.support_agent, title: 'Trung tâm hỗ trợ', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())); }),
          _buildDrawerItem(icon: Icons.logout, title: 'Đăng xuất', textColor: Colors.redAccent, iconColor: Colors.redAccent, onTap: () { Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color iconColor = Colors.white70, Color textColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      onTap: onTap,
    );
  }
}