import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final int rawPrice;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    int rPrice = (json['gia'] as num?)?.toInt() ?? 0;

    String formattedPrice =
        '${rPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )} đ';

    String img =
        'https://picsum.photos/seed/${json['masp']}/500/500';

    String tenLoai = 'Chưa rõ';

    if (json['loaisanpham'] != null) {
      tenLoai =
          json['loaisanpham']['tenloai'] ?? 'Chưa rõ';
    }

    return Product(
      id: json['masp'].toString(),
      name: json['tensp'] ?? 'Sản phẩm chưa có tên',
      price: formattedPrice,
      rawPrice: rPrice,
      brand: tenLoai,
      imageUrl: img,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class OrderData {
  final String orderId;
  final List<CartItem> items;
  final int totalAmount;
  final int earnedPoints;
  final String status;
  final String paymentMethod;
  final String address;
  final String note;

  OrderData({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.earnedPoints,
    required this.status,
    required this.paymentMethod,
    required this.address,
    required this.note,
  });
}

class VoucherData {
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final int requiredPoints;

  bool isUsed;

  VoucherData({
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.requiredPoints,
    this.isUsed = false,
  });
}

class ProductReview {
  final String productId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  ProductReview({
    required this.productId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Laptop Gaming ROG Strix',
    price: '35.990.000 đ',
    rawPrice: 35990000,
    brand: 'Asus',
    imageUrl:
    'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?auto=format&fit=crop&w=500&q=80',
  ),
  Product(
    id: '2',
    name: 'Điện thoại Galaxy S24 Ultra',
    price: '29.490.000 đ',
    rawPrice: 29490000,
    brand: 'Samsung',
    imageUrl:
    'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=500&q=80',
  ),
  Product(
    id: '3',
    name: 'Tai nghe Bluetooth Chống ồn',
    price: '4.500.000 đ',
    rawPrice: 4500000,
    brand: 'Sony',
    imageUrl:
    'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=500&q=80',
  ),
  Product(
    id: '4',
    name: 'Bàn phím cơ MX',
    price: '2.100.000 đ',
    rawPrice: 2100000,
    brand: 'Logitech',
    imageUrl:
    'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=500&q=80',
  ),
  Product(
    id: '5',
    name: 'Màn hình 27 inch 4K',
    price: '12.000.000 đ',
    rawPrice: 12000000,
    brand: 'LG',
    imageUrl:
    'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=500&q=80',
  ),
];