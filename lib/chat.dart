import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product.dart'; // Nạp dữ liệu sản phẩm
import 'screens/detail.dart';  // Chuyển trang chi tiết

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Danh sách sản phẩm thật tải từ Supabase
  List<Product> _realProducts = [];
  bool _isLoadingProducts = true;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Chào bạn! Mình là trợ lý ảo của 5AE. Bạn đang tìm kiếm linh kiện nào (CPU, VGA, RAM...) hay cần tư vấn gì ạ?',
      'isUser': false,
      'products': <Product>[]
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductsFromSupabase();
  }

  // Lấy dữ liệu thật từ Supabase về cho Bot học
  Future<void> _fetchProductsFromSupabase() async {
    try {
      final data = await Supabase.instance.client
          .from('sanpham')
          .select('masp, tensp, gia, loaisanpham(tenloai), hinhanhsp(urlanh)');

      if (mounted) {
        setState(() {
          _realProducts = (data as List).map((item) => Product.fromJson(item)).toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu cho bot: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    if (_isLoadingProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bot đang học dữ liệu sản phẩm, vui lòng chờ 1 giây...')),
      );
      return;
    }

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
  // BỘ NÃO TÌM KIẾM SẢN PHẨM TỪ CSDL THẬT
  // ==========================================
  Map<String, dynamic> _getBotResponse(String input) {
    String lowerInput = input.toLowerCase();

    // 1. TÌM THEO TÊN SẢN PHẨM (Ví dụ: "core i9", "rtx 4090")
    if (lowerInput.length > 2) {
      var exactMatches = _realProducts.where((p) => p.name.toLowerCase().contains(lowerInput)).toList();

      if (exactMatches.isNotEmpty) {
        // Gợi ý thêm sản phẩm cùng danh mục nếu có thể
        var suggestions = _realProducts.where((p) => p.id != exactMatches.first.id && p.brand == exactMatches.first.brand).take(2).toList();
        return {
          'text': 'Dạ, mình tìm thấy các sản phẩm phù hợp với yêu cầu của bạn. Bạn tham khảo thông tin và giá bên dưới nhé:',
          'products': [exactMatches.first, ...suggestions]
        };
      }
    }

    // 2. NHẬN DIỆN DANH MỤC LINH KIỆN
    if (lowerInput.contains('cpu') || lowerInput.contains('vi xử lý') || lowerInput.contains('intel') || lowerInput.contains('ryzen')) {
      var cpus = _realProducts.where((p) => p.name.toLowerCase().contains('cpu') || p.brand.toLowerCase().contains('cpu')).take(5).toList();
      return {
        'text': 'Dạ, đây là các mẫu CPU (Vi xử lý) mạnh mẽ nhất đang có sẵn tại 5AE ạ:',
        'products': cpus
      };
    }
    else if (lowerInput.contains('vga') || lowerInput.contains('card') || lowerInput.contains('rtx')) {
      var vgas = _realProducts.where((p) => p.name.toLowerCase().contains('vga') || p.name.toLowerCase().contains('card') || p.brand.toLowerCase().contains('vga')).take(5).toList();
      return {
        'text': 'Bạn đang build PC Gaming đúng không ạ? Mời bạn xem các dòng Card màn hình (VGA) siêu mượt này nhé:',
        'products': vgas
      };
    }
    else if (lowerInput.contains('ram') || lowerInput.contains('bộ nhớ')) {
      var rams = _realProducts.where((p) => p.name.toLowerCase().contains('ram') || p.brand.toLowerCase().contains('ram')).take(5).toList();
      return {
        'text': 'Mình xin gửi danh sách RAM đang giảm giá. Bạn nên chọn thanh RAM có bus tương thích với Mainboard nhé:',
        'products': rams
      };
    }
    else if (lowerInput.contains('main') || lowerInput.contains('bo mạch')) {
      var mains = _realProducts.where((p) => p.name.toLowerCase().contains('main') || p.brand.toLowerCase().contains('bo mạch')).take(5).toList();
      return {
        'text': 'Đây là các mẫu Mainboard (Bo mạch chủ) mới nhất, hỗ trợ tốt cho các dòng chip thế hệ mới:',
        'products': mains
      };
    }

    // 3. CÁC TỪ KHÓA TƯ VẤN CHUNG
    if (lowerInput.contains('bảo hành') || lowerInput.contains('đổi trả')) {
      return {'text': 'Tất cả linh kiện tại 5AE đều được bảo hành chính hãng từ 12-36 tháng. Lỗi 1 đổi 1 trong vòng 30 ngày đầu tiên ạ.'};
    } else if (lowerInput.contains('khuyến mãi') || lowerInput.contains('voucher')) {
      return {'text': 'Hiện tại shop đang có mã VIP15 giảm 15% cho đơn lớn. Bạn vào mục "Kho Voucher" để đổi điểm lấy mã nhé!'};
    }

    // 4. TRẢ LỜI MẶC ĐỊNH
    return {
      'text': 'Dạ, yêu cầu này mình đã ghi nhận. Sẽ có nhân viên hỗ trợ trực tiếp cho bạn nhé. Trong lúc chờ, mời bạn xem qua các linh kiện nổi bật:',
      'products': _realProducts.isNotEmpty ? _realProducts.take(3).toList() : [] // Đưa ra 3 sản phẩm đầu tiên
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
                      decoration: InputDecoration(
                          hintText: 'VD: Cần mua VGA RTX 4090...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                      icon: _isLoadingProducts
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                          : const Icon(Icons.send, color: Colors.redAccent),
                      onPressed: _sendMessage
                  ),
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
    List<Product>? products = msg['products'] as List<Product>?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
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

          if (products != null && products.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
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