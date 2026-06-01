import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================
// CÁC LỚP DỮ LIỆU (MODELS)
// ==========================================

class Product {
  final String id;
  final String name;
  final String price;
  final int rawPrice; // Lưu giá trị số (VD: 35990000) để dễ tính toán
  final String imageUrl;
  final String brand;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rawPrice,
    required this.imageUrl,
    required this.brand,
  });
}

// Lớp lưu trữ 1 Item trong Giỏ hàng
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// Lớp lưu trữ Đơn hàng trong Lịch sử
class OrderData {
  final String orderId;
  final List<CartItem> items;
  final int totalAmount;
  final int earnedPoints;
  final String status;
  final String paymentMethod;
  final String address; // ĐÃ THÊM: Địa chỉ giao hàng
  final String note;    // ĐÃ THÊM: Ghi chú đơn hàng

  OrderData({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.earnedPoints,
    required this.status,
    required this.paymentMethod,
    required this.address, // Yêu cầu biến này
    required this.note,    // Yêu cầu biến này
  });
}

// ==========================================
// BỘ NHỚ TẠM CỦA ỨNG DỤNG (GLOBAL STATE)
// ==========================================
class AppData {
  static List<Product> favorites = [];
  static List<CartItem> cart = [];
  static List<OrderData> history = [];

  // Thông tin User & Điểm
  static int currentPoints = 0;
  static int lifetimePoints = 0;

  // Lưu phần trăm Voucher đang áp dụng (Mặc định là 0)
  static double appliedVoucherPercent = 0.0;

  static String get userTier {
    if (lifetimePoints >= 50000) return 'Kim cương';
    if (lifetimePoints >= 20000) return 'VIP';
    if (lifetimePoints >= 5000) return 'Thân thiết';
    return 'Khách hàng';
  }

  static double get tierMultiplier {
    if (lifetimePoints >= 50000) return 2.0;
    if (lifetimePoints >= 20000) return 1.5;
    if (lifetimePoints >= 5000) return 1.2;
    return 1.0;
  }

  static double get discountPercent {
    if (lifetimePoints >= 50000) return 0.12;
    if (lifetimePoints >= 20000) return 0.08;
    if (lifetimePoints >= 5000) return 0.05;
    return 0.0;
  }

  // ĐÃ SỬA: Tính toán tiền ship 30k cứng và trừ thêm Voucher + Gửi lên Supabase
  static Future<void> processCheckout(String paymentMethod, String address, String note) async {
    if (cart.isEmpty) return;

    int subtotal = cart.fold(0, (sum, item) => sum + (item.product.rawPrice * item.quantity));

    int shippingFee = 30000; // Cố định ship 30k
    int tierDiscountAmount = (subtotal * discountPercent).round();
    int voucherDiscountAmount = (subtotal * appliedVoucherPercent).round();

    // Thành tiền = Tạm tính - Ưu đãi hạng - Voucher + Phí Ship
    int finalTotal = subtotal - tierDiscountAmount - voucherDiscountAmount + shippingFee;

    int earnedPoints = ((finalTotal / 10000).floor() * tierMultiplier).round();
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    history.insert(0, OrderData(
      orderId: orderId,
      items: List.from(cart),
      totalAmount: finalTotal,
      earnedPoints: earnedPoints,
      status: 'Chờ xác nhận',
      paymentMethod: paymentMethod,
      address: address,
      note: note,
    ));

    try {
      await Supabase.instance.client.from('orders').insert({
        'id': orderId,
        'user_id': Supabase.instance.client.auth.currentUser?.id ?? 'guest',
        'status': 'Chờ xác nhận',
        'total_price': finalTotal,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Lỗi lưu đơn hàng lên Supabase: $e');
    }

    currentPoints += earnedPoints;
    lifetimePoints += earnedPoints;

    cart.clear();
    appliedVoucherPercent = 0.0; // Reset lại voucher sau khi thanh toán xong
  }
}

// ==========================================
// DỮ LIỆU MẪU (MOCK DATA)
// ==========================================
final List<Product> mockProducts = [
  Product(id: '1', name: 'Laptop Gaming ROG Strix', price: '35.990.000 đ', rawPrice: 35990000, brand: 'Asus', imageUrl: 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?auto=format&fit=crop&w=500&q=80'),
  Product(id: '2', name: 'Điện thoại Galaxy S24 Ultra', price: '29.490.000 đ', rawPrice: 29490000, brand: 'Samsung', imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=500&q=80'),
  Product(id: '3', name: 'Tai nghe Bluetooth Chống ồn', price: '4.500.000 đ', rawPrice: 4500000, brand: 'Sony', imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=500&q=80'),
  Product(id: '4', name: 'Bàn phím cơ MX', price: '2.100.000 đ', rawPrice: 2100000, brand: 'Logitech', imageUrl: 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=500&q=80'),
  Product(id: '5', name: 'Màn hình 27inch 4K', price: '12.000.000 đ', rawPrice: 12000000, brand: 'LG', imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=500&q=80'),
];