import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final int rawPrice; // Thêm giá trị số nguyên để dễ tính toán
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

  OrderData({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.earnedPoints,
    required this.status,
    required this.paymentMethod,
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
  static int currentPoints = 0; // Điểm có thể dùng
  static int lifetimePoints = 0; // Điểm xét hạng

  // Lấy thông tin Cấp bậc hiện tại
  static String get userTier {
    if (lifetimePoints >= 50000) return 'Kim cương';
    if (lifetimePoints >= 20000) return 'VIP';
    if (lifetimePoints >= 5000) return 'Thân thiết';
    return 'Khách hàng';
  }

  // Lấy Hệ số nhân điểm
  static double get tierMultiplier {
    if (lifetimePoints >= 50000) return 2.0;
    if (lifetimePoints >= 20000) return 1.5;
    if (lifetimePoints >= 5000) return 1.2;
    return 1.0;
  }

  // Lấy % Giảm giá theo hạng
  static double get discountPercent {
    if (lifetimePoints >= 50000) return 0.12; // 12%
    if (lifetimePoints >= 20000) return 0.08; // 8%
    if (lifetimePoints >= 5000) return 0.05;  // 5%
    return 0.0; // 0%
  }

  // Hàm thanh toán & Cộng điểm
  static void processCheckout(String paymentMethod) {
    if (cart.isEmpty) return;

    int subtotal = cart.fold(0, (sum, item) => sum + (item.product.rawPrice * item.quantity));
    int finalTotal = (subtotal * (1 - discountPercent)).round();

    // Tính điểm: (Tổng tiền / 10.000) * Hệ số
    int earnedPoints = ((finalTotal / 10000).floor() * tierMultiplier).round();

    // Lưu Lịch sử
    history.insert(0, OrderData(
      orderId: 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(cart),
      totalAmount: finalTotal,
      earnedPoints: earnedPoints,
      status: 'Chờ xác nhận',
      paymentMethod: paymentMethod,
    ));

    // Cộng điểm
    currentPoints += earnedPoints;
    lifetimePoints += earnedPoints;

    // Xóa giỏ hàng
    cart.clear();
  }
}

// Cập nhật Dữ liệu mẫu (Thêm rawPrice)
final List<Product> mockProducts = [
  Product(id: '1', name: 'Laptop Gaming ROG Strix', price: '35.990.000 đ', rawPrice: 35990000, brand: 'Asus', imageUrl: 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?auto=format&fit=crop&w=500&q=80'),
  Product(id: '2', name: 'Điện thoại Galaxy S24 Ultra', price: '29.490.000 đ', rawPrice: 29490000, brand: 'Samsung', imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=500&q=80'),
  Product(id: '3', name: 'Tai nghe Bluetooth Chống ồn', price: '4.500.000 đ', rawPrice: 4500000, brand: 'Sony', imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=500&q=80'),
  Product(id: '4', name: 'Bàn phím cơ MX', price: '2.100.000 đ', rawPrice: 2100000, brand: 'Logitech', imageUrl: 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=500&q=80'),
  Product(id: '5', name: 'Màn hình 27inch 4K', price: '12.000.000 đ', rawPrice: 12000000, brand: 'LG', imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=500&q=80'),
];