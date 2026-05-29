import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Trung Tâm Hỗ Trợ'), backgroundColor: Colors.black, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.support_agent, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Center(child: Text('Chúng tôi có thể giúp gì cho bạn?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          _buildContactCard(Icons.chat, 'Chat với CSKH', 'Phản hồi trong 5 phút', Colors.blue),
          _buildContactCard(Icons.phone_in_talk, 'Gọi Hotline', '1800 xxxx (Miễn phí)', Colors.green),
          _buildContactCard(Icons.email, 'Gửi Email', 'support@electro.com', Colors.orange),
          const SizedBox(height: 20),
          const Text('Câu hỏi thường gặp (FAQ)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildFAQItem('Làm sao để đổi trả sản phẩm?'),
          _buildFAQItem('Thời gian bảo hành là bao lâu?'),
          _buildFAQItem('Phương thức thanh toán nào được chấp nhận?'),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String sub, Color color) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return ExpansionTile(
      collapsedIconColor: Colors.white,
      iconColor: Colors.red,
      title: Text(question, style: const TextStyle(color: Colors.white70)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Đây là câu trả lời mẫu cho câu hỏi: $question. Chúng tôi luôn sẵn sàng hỗ trợ bạn tốt nhất.', style: const TextStyle(color: Colors.grey)),
        )
      ],
    );
  }
}