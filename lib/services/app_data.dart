import 'package:supabase_flutter/supabase_flutter.dart';
import '../product.dart';

class AppData {
  static List<Product> favorites = [];
  static List<CartItem> cart = [];
  static List<OrderData> history = [];

  static int currentPoints = 0;
  static int lifetimePoints = 0;

  static double appliedVoucherPercent = 0.0;
  static String appliedVoucherCode = '';

  static List<VoucherData> myVouchers = [];

  static List<VoucherData> availableVouchers = [
    VoucherData(
      code: 'SALE5',
      title: 'Voucher 5%',
      description: 'Giảm tối đa 50.000đ',
      discountPercent: 0.05,
      requiredPoints: 100,
    ),
    VoucherData(
      code: 'SALE10',
      title: 'Voucher 10%',
      description: 'Giảm tối đa 100.000đ cho đơn từ 500.000đ',
      discountPercent: 0.10,
      requiredPoints: 250,
    ),
    VoucherData(
      code: 'VIP15',
      title: 'Voucher VIP 15%',
      description: 'Ưu đãi dành cho khách VIP',
      discountPercent: 0.15,
      requiredPoints: 500,
    ),
    VoucherData(
      code: 'DIAMOND20',
      title: 'Voucher Kim Cương 20%',
      description: 'Giảm tối đa 300.000đ',
      discountPercent: 0.20,
      requiredPoints: 1000,
    ),
    VoucherData(
      code: 'SUPER25',
      title: 'Super Sale 25%',
      description: 'Khuyến mãi cuối tuần',
      discountPercent: 0.25,
      requiredPoints: 1500,
    ),
    VoucherData(
      code: 'MEGA30',
      title: 'Mega Voucher 30%',
      description: 'Ưu đãi đặc biệt số lượng có hạn',
      discountPercent: 0.30,
      requiredPoints: 2500,
    ),
    VoucherData(
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Giảm 30.000đ phí ship',
      discountPercent: 0.03,
      requiredPoints: 80,
    ),
    VoucherData(
      code: 'FLASH40',
      title: 'Flash Sale 40%',
      description: 'Voucher hiếm chỉ dành cho VIP',
      discountPercent: 0.40,
      requiredPoints: 5000,
    ),
  ];

  static List<ProductReview> reviews = [];

  static String get userTier {
    if (lifetimePoints >= 100000) return 'Kim Cương';
    if (lifetimePoints >= 50000) return 'Bạch Kim';
    if (lifetimePoints >= 20000) return 'VIP';
    if (lifetimePoints >= 5000) return 'Thân Thiết';
    return 'Thành Viên';
  }

  static double get tierMultiplier {
    if (lifetimePoints >= 100000) return 3.0;
    if (lifetimePoints >= 50000) return 2.0;
    if (lifetimePoints >= 20000) return 1.5;
    if (lifetimePoints >= 5000) return 1.2;
    return 1.0;
  }

  static double get discountPercent {
    if (lifetimePoints >= 100000) return 0.20;
    if (lifetimePoints >= 50000) return 0.15;
    if (lifetimePoints >= 20000) return 0.10;
    if (lifetimePoints >= 5000) return 0.05;
    return 0.0;
  }

  static int get nextTierTarget {
    if (lifetimePoints < 5000) return 5000;
    if (lifetimePoints < 20000) return 20000;
    if (lifetimePoints < 50000) return 50000;
    if (lifetimePoints < 100000) return 100000;
    return 100000;
  }

  static double get tierProgress {
    if (nextTierTarget == 0) return 1.0;
    double progress = lifetimePoints / nextTierTarget;
    if (progress > 1.0) return 1.0;
    return progress;
  }

  static String formatMoney(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )} đ';
  }

  static int getCartSubtotal() {
    return cart.fold(
      0,
          (sum, item) => sum + item.product.rawPrice * item.quantity,
    );
  }

  static int getShippingFee() {
    if (cart.isEmpty) return 0;
    return 30000;
  }

  static int getTierDiscountAmount() {
    return (getCartSubtotal() * discountPercent).round();
  }

  static int getVoucherDiscountAmount() {
    return (getCartSubtotal() * appliedVoucherPercent).round();
  }

  static int getFinalTotal() {
    return getCartSubtotal() -
        getTierDiscountAmount() -
        getVoucherDiscountAmount() +
        getShippingFee();
  }

  static int calculateEarnedPoints(int totalAmount) {
    return ((totalAmount / 10000).floor() * tierMultiplier).round();
  }

  static void addToCart(Product product) {
    final index = cart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(
        CartItem(product: product),
      );
    }
  }

  static void removeFromCart(Product product) {
    cart.removeWhere(
          (item) => item.product.id == product.id,
    );
  }

  static void increaseQuantity(Product product) {
    final index = cart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      cart[index].quantity++;
    }
  }

  static void decreaseQuantity(Product product) {
    final index = cart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    }
  }

  static bool isFavorite(Product product) {
    return favorites.any(
          (item) => item.id == product.id,
    );
  }

  static void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      favorites.removeWhere(
            (item) => item.id == product.id,
      );
    } else {
      favorites.add(product);
    }
  }

  static bool exchangeVoucher(VoucherData voucher) {
    if (currentPoints < voucher.requiredPoints) {
      return false;
    }

    currentPoints -= voucher.requiredPoints;

    myVouchers.add(
      VoucherData(
        code: voucher.code,
        title: voucher.title,
        description: voucher.description,
        discountPercent: voucher.discountPercent,
        requiredPoints: voucher.requiredPoints,
      ),
    );

    return true;
  }

  static void applyVoucher(VoucherData voucher) {
    if (voucher.isUsed) return;

    appliedVoucherPercent = voucher.discountPercent;
    appliedVoucherCode = voucher.code;
  }

  static void applyVoucherByCode(String code) {
    final voucher = availableVouchers.firstWhere(
          (item) => item.code.toUpperCase() == code.toUpperCase(),
      orElse: () => VoucherData(
        code: '',
        title: '',
        description: '',
        discountPercent: 0,
        requiredPoints: 0,
      ),
    );

    if (voucher.code.isEmpty) return;

    appliedVoucherPercent = voucher.discountPercent;
    appliedVoucherCode = voucher.code;
  }

  static void removeVoucher() {
    appliedVoucherPercent = 0.0;
    appliedVoucherCode = '';
  }

  static Future<void> processCheckout(
      String paymentMethod,
      String address,
      String note,
      ) async {
    if (cart.isEmpty) return;

    int subtotal = getCartSubtotal();
    int shippingFee = getShippingFee();
    int tierDiscountAmount = getTierDiscountAmount();
    int voucherDiscountAmount = getVoucherDiscountAmount();
    int finalTotal = getFinalTotal();
    int earnedPoints = calculateEarnedPoints(finalTotal);

    String newOrderId =
        'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final supabase = Supabase.instance.client;

    await supabase.from('don_hang').insert({
      'ma_don_hang': newOrderId,
      'tong_tien': subtotal,
      'giam_gia': tierDiscountAmount + voucherDiscountAmount,
      'phi_ship': shippingFee,
      'thanh_tien': finalTotal,
      'diem_thu_duoc': earnedPoints,
      'trang_thai': 'Chờ xác nhận',
      'phuong_thuc_tt': paymentMethod,
      'dia_chi': address,
      'ghi_chu': note,
      'ngay_tao': DateTime.now().toIso8601String(),
    });

    history.insert(
      0,
      OrderData(
        orderId: newOrderId,
        items: List<CartItem>.from(cart),
        totalAmount: finalTotal,
        earnedPoints: earnedPoints,
        status: 'Chờ xác nhận',
        paymentMethod: paymentMethod,
        address: address,
        note: note,
      ),
    );

    currentPoints += earnedPoints;
    lifetimePoints += earnedPoints;

    for (var voucher in myVouchers) {
      if (voucher.code == appliedVoucherCode) {
        voucher.isUsed = true;
      }
    }

    cart.clear();
    removeVoucher();
  }

  static void addReview({
    required String productId,
    required String userName,
    required String comment,
    required double rating,
  }) {
    reviews.insert(
      0,
      ProductReview(
        productId: productId,
        userName: userName,
        comment: comment,
        rating: rating,
        createdAt: DateTime.now(),
      ),
    );
  }

  static List<ProductReview> getReviewsByProduct(String productId) {
    return reviews.where((e) => e.productId == productId).toList();
  }

  static double getAverageRating(String productId) {
    final productReviews = getReviewsByProduct(productId);

    if (productReviews.isEmpty) return 0;

    double total = 0;

    for (var review in productReviews) {
      total += review.rating;
    }

    return total / productReviews.length;
  }

  static int getReviewCount(String productId) {
    return getReviewsByProduct(productId).length;
  }

  static int get totalSpent {
    return history.fold(
      0,
          (sum, order) => sum + order.totalAmount,
    );
  }

  static int get totalOrders {
    return history.length;
  }

  static int get availableVoucherCount {
    return myVouchers.where((voucher) => !voucher.isUsed).length;
  }
}