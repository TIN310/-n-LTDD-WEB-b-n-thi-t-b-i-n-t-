import 'package:flutter/material.dart';
import '../product.dart';
import '../cart.dart';
import '../services/app_data.dart';
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAddingToCart = false;

  double selectedRating = 5;
  final TextEditingController commentController =
  TextEditingController();

  bool get isFavorite =>
      AppData.favorites.any((p) => p.id == widget.product.id);

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        AppData.favorites.removeWhere(
              (p) => p.id == widget.product.id,
        );

        _showSmoothSnackBar(
          'Đã bỏ yêu thích',
          Icons.heart_broken,
          Colors.grey,
        );
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

  Future<void> addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    AppData.addToCart(widget.product);

    setState(() {
      _isAddingToCart = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm ${widget.product.name} vào giỏ!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void submitReview() {
    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập bình luận trước khi gửi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AppData.addReview(
      productId: widget.product.id,
      userName: 'Khách hàng',
      comment: commentController.text.trim(),
      rating: selectedRating,
    );

    commentController.clear();

    setState(() {
      selectedRating = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gửi đánh giá thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSmoothSnackBar(
      String message,
      IconData icon,
      Color iconColor,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildRatingStars(
      double rating, {
        double size = 18,
        bool interactive = false,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          bool active = index < rating;

          return GestureDetector(
            onTap: interactive
                ? () {
              setState(() {
                selectedRating = (index + 1).toDouble();
              });
            }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                active ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: size,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Viết đánh giá của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'Chọn sao:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              _buildRatingStars(
                selectedRating,
                size: 28,
                interactive: true,
              ),
              const SizedBox(width: 8),
              Text(
                selectedRating.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nhập bình luận về sản phẩm...',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: submitReview,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              label: const Text(
                'Gửi đánh giá',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    final reviews =
    AppData.getReviewsByProduct(widget.product.id);

    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: Colors.grey[700],
              size: 45,
            ),
            const SizedBox(height: 10),
            const Text(
              'Chưa có đánh giá nào',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Hãy là người đầu tiên đánh giá sản phẩm này.',
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

    return Column(
      children: reviews.map((review) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'K',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        _buildRatingStars(
                          review.rating,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      review.comment,
                      style: TextStyle(
                        color: Colors.grey[300],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSummary() {
    final average =
    AppData.getAverageRating(widget.product.id);

    final count =
    AppData.getReviewCount(widget.product.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 32,
          ),

          const SizedBox(width: 10),

          Text(
            average.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 8),

          _buildRatingStars(
            average,
            size: 17,
          ),

          const Spacer(),

          Text(
            '$count đánh giá',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewCount =
    AppData.getReviewCount(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
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
                    borderRadius:
                    const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 55,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Positioned(
                  top: 50,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor:
                    Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                  ),
                ),

                Positioned(
                  top: 50,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor:
                    Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration:
                        const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey<bool>(isFavorite),
                          color: isFavorite
                              ? Colors.pinkAccent
                              : Colors.white,
                        ),
                      ),
                      onPressed: toggleFavorite,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.product.price,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildRatingStars(
                        AppData.getAverageRating(
                          widget.product.id,
                        ),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reviewCount == 0
                            ? 'Chưa có đánh giá'
                            : '${AppData.getAverageRating(widget.product.id).toStringAsFixed(1)} / 5 ($reviewCount đánh giá)',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Sản phẩm ${widget.product.name} chính hãng của thương hiệu ${widget.product.brand}. '
                        'Thiết kế hiện đại, hiệu năng ổn định, phù hợp cho học tập, làm việc và giải trí.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Đánh giá & Bình luận',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildRatingSummary(),

                  const SizedBox(height: 14),

                  _buildReviewForm(),

                  const SizedBox(height: 18),

                  _buildReviewList(),

                  const SizedBox(height: 80),
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
            Expanded(
              child: ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                _isAddingToCart ? null : addToCart,
                child: _isAddingToCart
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
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