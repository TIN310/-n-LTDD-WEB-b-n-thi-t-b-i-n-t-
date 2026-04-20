import 'package:flutter/material.dart';
import 'product.dart'; // Nạp dữ liệu sản phẩm
import 'detail.dart';  // Để bấm vào sản phẩm thì chuyển sang trang chi tiết

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Danh sách tin nhắn giờ đây hỗ trợ chứa cả List sản phẩm
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Chào bạn! Mình là trợ lý ảo của 5AE. Bạn đang tìm kiếm sản phẩm nào hay cần tư vấn gì ạ?',
      'isUser': false,
      'products': <Product>[] // Khởi tạo rỗng
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userText = _messageController.text.trim();

    setState(() {
      _messages.add({'text': userText, 'isUser': true, 'products': <Product>[]});
    });

    _messageController.clear();
    _scrollToBottom();

    // Giả lập AI đang suy nghĩ
    Future.delayed(const Duration(seconds: 1), () {
      Map<String, dynamic> botReply = _getBotResponse(userText);
      setState(() {
        _messages.add({
          'text': botReply['text'],
          'isUser': false,
          'products': botReply['products'] ?? <Product>[]
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================
  // BỘ NÃO TÌM KIẾM SẢN PHẨM CỦA CHATBOT
  // ==========================================
  Map<String, dynamic> _getBotResponse(String input) {
    String lowerInput = input.toLowerCase();

    // 1. KIỂM TRA XEM CÓ TÌM TÊN 1 SẢN PHẨM CỤ THỂ KHÔNG (Ví dụ: "iphone 15", "rog strix")
    // Dùng độ dài > 3 để tránh việc gõ chữ "a", "đi" mà nó cũng tìm
    if (lowerInput.length > 3) {
      var exactMatches = mockProducts.where((p) => p.name.toLowerCase().contains(lowerInput)).toList();

      if (exactMatches.isNotEmpty && exactMatches.length == 1) {
        // Gợi ý thêm sản phẩm cùng hãng
        var suggestions = mockProducts.where((p) => p.id != exactMatches.first.id && p.brand == exactMatches.first.brand).take(2).toList();
        return {
          'text': 'Dạ, đây là thông tin chi tiết của ${exactMatches.first.name} giá ${exactMatches.first.price}. \n\nSản phẩm này đang được bảo hành 12 tháng. Mình cũng gợi ý thêm vài mẫu cùng hãng cho bạn tham khảo nhé:',
          'products': [exactMatches.first, ...suggestions]
        };
      }
    }

    // 2. KIỂM TRA TỪ KHÓA DANH MỤC SẢN PHẨM
    if (lowerInput.contains('laptop') || lowerInput.contains('máy tính')) {
      // Ưu tiên hiển thị ngẫu nhiên hoặc lấy 5 sản phẩm đầu tiên làm "Bán chạy"
      var laptops = mockProducts.where((p) => p.name.toLowerCase().contains('laptop') || p.name.toLowerCase().contains('macbook')).take(5).toList();
      return {
        'text': 'Dạ, đây là Top các mẫu Laptop đang bán chạy nhất tại 5AE kèm cấu hình chi tiết ạ:',
        'products': laptops
      };
    }
    else if (lowerInput.contains('điện thoại') || lowerInput.contains('smartphone') || lowerInput.contains('iphone')) {
      var phones = mockProducts.where((p) => p.name.toLowerCase().contains('điện thoại') || p.name.toLowerCase().contains('iphone')).take(5).toList();
      return {
        'text': 'Mình gửi bạn danh sách Điện thoại đang có ưu đãi tốt nhất hôm nay nhé:',
        'products': phones
      };
    }

    // 3. CÁC TỪ KHÓA TƯ VẤN CHUNG
    if (lowerInput.contains('bảo hành') || lowerInput.contains('đổi trả')) {
      return {'text': 'Tất cả sản phẩm tại 5AE đều được bảo hành chính hãng từ 12-24 tháng. Lỗi 1 đổi 1 trong vòng 30 ngày đầu tiên ạ.'};
    } else if (lowerInput.contains('khuyến mãi') || lowerInput.contains('voucher')) {
      return {'text': 'Hiện tại shop đang có mã giảm giá 50% cho thiết bị Gaming và Freeship mọi đơn. Bạn vào mục "Kho Voucher" để lấy mã nhé!'};
    }

    // 4. TRẢ LỜI MẶC ĐỊNH KHI KHÔNG HIỂU
    return {
      'text': 'Dạ, thông tin này mình đã ghi nhận. Sẽ có nhân viên CSKH trực tiếp trả lời bạn trong ít phút nữa nhé. Trong lúc chờ, bạn xem qua các sản phẩm nổi bật của shop nha:',
      'products': mockProducts.take(3).toList() // Đưa ra 3 sản phẩm random
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          children: [
            CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.support_agent, color: Colors.white)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trợ lý 5AE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Luôn sẵn sàng hỗ trợ', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[900], border: Border(top: BorderSide(color: Colors.grey[800]!))),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.image_outlined, color: Colors.grey), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Nhập tên sản phẩm cần tìm...', hintStyle: TextStyle(color: Colors.grey[600]), border: InputBorder.none),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send, color: Colors.redAccent), onPressed: _sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN HIỂN THỊ TIN NHẮN & SẢN PHẨM
  // ==========================================
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'];
    String text = msg['text'];
    List<Product>? products = msg['products'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 1. Bong bóng chữ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? Colors.red.withOpacity(0.9) : Colors.grey[800],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
              ),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          ),

          // 2. Nếu Bot có gửi kèm Sản phẩm thì hiển thị thanh trượt ngang
          if (products != null && products.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 220, // Chiều cao thẻ sản phẩm trong chat
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildChatProductCard(product);
                },
              ),
            )
          ]
        ],
      ),
    );
  }

  // Giao diện Thẻ sản phẩm bên trong khung chat
  Widget _buildChatProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(product.imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 100, color: Colors.grey, child: const Icon(Icons.image))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(product.price, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  const Text('Xem chi tiết >', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}