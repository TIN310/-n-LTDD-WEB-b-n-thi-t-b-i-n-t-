import 'package:flutter/material.dart';
import 'product.dart';
import 'cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool get isFavorite => AppData.favorites.any((p) => p.id == widget.product.id);

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        AppData.favorites.removeWhere((p) => p.id == widget.product.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bỏ yêu thích')));
      } else {
        AppData.favorites.add(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào yêu thích'), backgroundColor: Colors.pinkAccent));
      }
    });
  }

  void addToCart() {
    var existingItem = AppData.cart.where((item) => item.product.id == widget.product.id).firstOrNull;
    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      AppData.cart.add(CartItem(product: widget.product));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã thêm ${widget.product.name} vào giỏ!'),
      backgroundColor: Colors.green,
      action: SnackBarAction(label: 'Xem giỏ', textColor: Colors.white, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 400, width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    child: Image.network(widget.product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(top: 50, left: 16, child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.5), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)))),
                Positioned(top: 50, right: 16, child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.5), child: IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red), onPressed: toggleFavorite))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.product.price, style: const TextStyle(color: Colors.redAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  const Text('Mô tả sản phẩm', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Sản phẩm ${widget.product.name} chính hãng của thương hiệu ${widget.product.brand}.', style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[900],
        child: Row(
          children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: addToCart, child: const Text('THÊM VÀO GIỎ / MUA NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}