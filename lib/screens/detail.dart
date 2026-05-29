import 'package:flutter/material.dart';
import '../product.dart';
import '../cart.dart';
import '../models/model_comments.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Biến trạng thái để tạo hiệu ứng loading
  bool _isAddingToCart = false;

  bool get isFavorite =>
      AppData.favorites.any((p) => p.id == widget.product.id);

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        AppData.favorites.removeWhere((p) => p.id == widget.product.id);
        _showSmoothSnackBar('Đã bỏ yêu thích', Icons.heart_broken, Colors.grey);
      } else {
        AppData.favorites.add(widget.product);
        _showSmoothSnackBar(
          'Đã thêm vào yêu thích',
          Icons.favorite,
          Colors.pinkAccent,
        );
      }
    });
  }

  // Hàm Add To Cart mới: Có độ trễ mô phỏng mượt mà
  Future<void> addToCart() async {
    // Bật trạng thái loading
    setState(() {
      _isAddingToCart = true;
    });

    // Giả lập thời gian xử lý của hệ thống (0.5 giây)
    await Future.delayed(const Duration(milliseconds: 500));

    // Thêm vào giỏ
    var existingItem = AppData.cart
        .where((item) => item.product.id == widget.product.id)
        .firstOrNull;
    setState(() {
      if (existingItem != null) {
        existingItem.quantity++;
      } else {
        AppData.cart.add(CartItem(product: widget.product));
      }
      _isAddingToCart = false; // Tắt loading
    });

    // Hiển thị thông báo thành công
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm ${widget.product.name} vào giỏ!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating, // Thông báo nổi mượt mà
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ), // Bo góc
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
      ),
    );
  }

  // Hàm tái sử dụng để hiển thị SnackBar mượt cho các tác vụ khác
  void _showSmoothSnackBar(String message, IconData icon, Color iconColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Cuộn nảy mượt mà
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      // Thêm AnimatedSwitcher để icon tim nảy lên khi bấm
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(
                            isFavorite,
                          ), // Bắt buộc phải có key để nhận diện sự thay đổi
                          color: isFavorite ? Colors.pinkAccent : Colors.white,
                        ),
                      ),
                      onPressed: toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Tên sản phẩm
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //Giá sản phẩm
                  const SizedBox(height: 10),
                  Text(
                    widget.product.price,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //Mô tả sản phẩm
                  const SizedBox(height: 25),
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  //Hãng sản phẩm
                  const SizedBox(height: 10),
                  Text(
                    'Sản phẩm ${widget.product.name} chính hãng của thương hiệu ${widget.product.brand}.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  //Bình luận
                  const SizedBox(height: 30),
                  // Comment title
                  const Text(
                    'Bình luận',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Comment list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sampleComment.length,
                    itemBuilder: (context, index) {
                      final comment = sampleComment[index];

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(comment.username[0]),
                          ),
                          title: Text(
                            comment.username,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                comment.text,
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${comment.timestamp.day}/${comment.timestamp.month}/${comment.timestamp.year}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[900],
        child: Row(
          children: [

            //cart button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ), // Bo tròn nút
                ),
                onPressed: _isAddingToCart
                    ? null
                    : addToCart, // Khóa nút khi đang loading
                child: _isAddingToCart
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ) // Hiện vòng xoay loading
                    : const Text(
                        'THÊM VÀO GIỎ / MUA NGAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
