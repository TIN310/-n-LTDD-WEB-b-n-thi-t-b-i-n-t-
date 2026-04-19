import 'package:flutter/material.dart';
import 'product.dart';
import 'detail.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Sản phẩm yêu thích'), backgroundColor: Colors.black, centerTitle: true, automaticallyImplyLeading: false),
      body: AppData.favorites.isEmpty
          ? const Center(child: Text('Bạn chưa yêu thích sản phẩm nào', style: TextStyle(color: Colors.grey)))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: AppData.favorites.length,
        itemBuilder: (context, index) {
          final product = AppData.favorites[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
              setState(() {}); // Cập nhật lại list lỡ người dùng bỏ Thích ở màn hình Detail
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover)),
                        const Positioned(top: 8, right: 8, child: Icon(Icons.favorite, color: Colors.red)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}