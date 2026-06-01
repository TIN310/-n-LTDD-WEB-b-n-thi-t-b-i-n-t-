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

    // Ảnh mặc định nếu sản phẩm không có ảnh
    String img = 'https://picsum.photos/seed/${json['masp']}/500/500';

    // Lấy ảnh thật từ bảng hinhanhsp (Supabase sẽ trả về dạng List)
    if (json['hinhanhsp'] != null && json['hinhanhsp'] is List && (json['hinhanhsp'] as List).isNotEmpty) {
      String urlAnh = (json['hinhanhsp'] as List)[0]['urlanh']?.toString() ?? '';
      if (urlAnh.isNotEmpty) {
        // LƯU Ý: Nếu ảnh trong CSDL chỉ là tên file (vd: sp1.jpg),
        // bạn cần nối thêm đường dẫn Storage của Supabase vào đây.
        // Ví dụ: img = 'https://yuirveasmxdzngbijwaa.supabase.co/storage/v1/object/public/TenBucketCuaBan/$urlAnh';

        // Tạm thời nếu trong SQL của bạn là link thì gán luôn:
        // img = urlAnh;
      }
    }

    String tenLoai = 'Chưa rõ';
    if (json['loaisanpham'] != null) {
      tenLoai = json['loaisanpham']['tenloai'] ?? 'Chưa rõ';
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