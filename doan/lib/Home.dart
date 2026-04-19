import 'package:flutter/material.dart';
import 'product.dart';
import 'detail.dart';
import 'profile.dart';
// THÊM IMPORT CÁC TRANG MỚI TẠO
import 'category.dart';
import 'cart.dart';
import 'favorite.dart';
import 'history.dart';
import 'voucher.dart';
import 'support.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  int _currentBannerIndex = 0;
  String _searchQuery = '';
  String _selectedBrand = 'Tất cả';

  final List<String> brands = ['Tất cả', 'Asus', 'Samsung', 'Sony', 'Logitech', 'LG'];
  final List<String> categories = ['Tất cả', 'Laptop', 'Điện thoại', 'Phụ kiện', 'Màn hình'];

  final List<Map<String, dynamic>> banners = [
    {'title': 'GIẢM GIÁ 50%\nTHIẾT BỊ GAMING', 'color1': Colors.redAccent, 'color2': Colors.black87},
    {'title': 'SIÊU SALE APPLE\nĐỒNG GIÁ 99K', 'color1': Colors.blueAccent, 'color2': Colors.black87},
    {'title': 'TUẦN LỄ PHỤ KIỆN\nMUA 1 TẶNG 1', 'color1': Colors.orangeAccent, 'color2': Colors.black87},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('ELECTRO STORE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.red),
        actions: [
          // GẮN CHUYỂN TRANG CHO NÚT GIỎ HÀNG
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              }
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        elevation: 4,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildSearchTab();
      case 2: return const FavoriteScreen(); // ĐÃ THAY BẰNG TRANG YÊU THÍCH
      case 3: return const VipProfileScreen(); // Gọi từ profile.dart
      default: return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [banners[index]['color1'], banners[index]['color2']], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: banners[index]['color1'].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Center(child: Text(banners[index]['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2))),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBannerIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: _currentBannerIndex == index ? Colors.red : Colors.grey[700], borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Danh mục nổi bật', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedCategoryIndex == index ? Colors.red : Colors.grey[900],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: _selectedCategoryIndex == index ? Colors.red : Colors.grey[800]!),
                      ),
                      child: Center(child: Text(categories[index], style: TextStyle(color: _selectedCategoryIndex == index ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            const Text('Sản phẩm đề xuất', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: mockProducts.length,
              itemBuilder: (context, index) {
                final product = mockProducts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[850]!)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.grey, size: 40))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(product.brand, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.red, size: 16))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    List<Product> filteredProducts = mockProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBrand = _selectedBrand == 'Tất cả' || product.brand == _selectedBrand;
      return matchesSearch && matchesBrand;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[900],
              hintText: 'Nhập tên sản phẩm cần tìm...', hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Nhà sản xuất', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = _selectedBrand == brand;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(brand, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold)),
                    selected: isSelected, selectedColor: Colors.red, backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.red : Colors.transparent)),
                    onSelected: (selected) => setState(() => _selectedBrand = brand),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Kết quả: ${filteredProducts.length} sản phẩm', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('Không tìm thấy sản phẩm nào!', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
              physics: const BouncingScrollPhysics(), itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  color: Colors.grey[900], margin: const EdgeInsets.only(bottom: 12), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[850]!)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(product.imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.grey))),
                    ),
                    title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Hãng: ${product.brand}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
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

  // --- HÀM BUILD DRAWER MỚI ---
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
            accountName: const Text(
              'Phạm Trí Tín',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text(
              'Thành viên VIP',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.home_filled,
            title: 'Trang chủ',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),

          _buildDrawerItem(
            icon: Icons.category_outlined,
            title: 'Danh mục sản phẩm',
            onTap: () {
              Navigator.pop(context);
              // CHUYỂN SANG TRANG DANH MỤC
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.local_offer_outlined,
            title: 'Kho Voucher / Mã giảm giá',
            iconColor: Colors.amber,
            onTap: () {
              Navigator.pop(context);
              // CHUYỂN SANG TRANG VOUCHER
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherScreen()));
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.white24),
          ),

          _buildDrawerItem(
            icon: Icons.history,
            title: 'Lịch sử mua hàng',
            onTap: () {
              Navigator.pop(context);
              // CHUYỂN SANG TRANG LỊCH SỬ
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.favorite_border,
            title: 'Sản phẩm yêu thích',
            iconColor: Colors.pinkAccent,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),

          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Hồ sơ cá nhân',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.white24),
          ),

          _buildDrawerItem(
            icon: Icons.support_agent,
            title: 'Trung tâm hỗ trợ',
            onTap: () {
              Navigator.pop(context);
              // CHUYỂN SANG TRANG HỖ TRỢ
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color textColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
          title,
          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      onTap: onTap,
    );
  }
}