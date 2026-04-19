import 'package:flutter/material.dart';
import 'Home.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("ELECTRO STORE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Người dùng"),
              Tab(icon: Icon(Icons.admin_panel_settings), text: "Nhân viên"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginForm(role: "Người dùng"),
            LoginForm(role: "Nhân viên"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// FORM ĐĂNG NHẬP
// ==========================================
class LoginForm extends StatefulWidget {
  final String role;
  const LoginForm({super.key, required this.role});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  // MÔ PHỎNG LUỒNG ĐĂNG NHẬP MẠNG XÃ HỘI & BẮT NHẬP SĐT
  void _handleSocialLogin(String providerName) {
    // 1. GỌI API GOOGLE/FACEBOOK Ở ĐÂY (Giả lập là đã lấy được thông tin email, tên)

    // 2. HIỂN THỊ BẢNG YÊU CẦU NHẬP SĐT ĐỂ HOÀN TẤT HỒ SƠ
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc phải nhập, không cho bấm ra ngoài tắt
      builder: (BuildContext dialogContext) {
        final phoneFormKey = GlobalKey<FormState>();
        final phoneController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Hoàn tất đăng nhập $providerName', style: const TextStyle(color: Colors.white)),
          content: Form(
            key: phoneFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vui lòng cung cấp số điện thoại để bảo vệ tài khoản và nhận thông báo giao hàng.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    prefixIcon: const Icon(Icons.phone, color: Colors.red),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập SĐT';
                    if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$').hasMatch(val)) {
                      return 'SĐT không hợp lệ (VD: 0912345678)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Hủy bỏ
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (phoneFormKey.currentState!.validate()) {
                  // Đã nhập đúng -> Đóng Dialog & Chuyển vào Home
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Liên kết SĐT thành công!'), backgroundColor: Colors.green),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                }
              },
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isStaff = widget.role == "Nhân viên";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14),
                child: const Icon(Icons.electrical_services_rounded, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 10),
              Text("Đăng nhập ${widget.role}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email / Số điện thoại", prefixIcon: const Icon(Icons.email, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email hoặc số điện thoại';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (isStaff) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: "Mã nhân viên", prefixIcon: const Icon(Icons.badge, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập mã nhân viên' : null,
                ),
                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    prefixIcon: const Icon(Icons.lock, color: Colors.red),
                    suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscure = !_isObscure)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
                onPressed: _login,
                child: const Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              const Text("Hoặc đăng nhập bằng", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.g_mobiledata, Colors.white, 'Google'),
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.facebook, Colors.blue, 'Facebook'),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(role: widget.role))),
                child: const Text("Chưa có tài khoản? Đăng ký ngay", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, String name) {
    return InkWell(
      onTap: () => _handleSocialLogin(name), // Gọi hàm xử lý Social Login
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.3))),
        child: Icon(icon, size: 35, color: color),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH & FORM ĐĂNG KÝ
// ==========================================
class RegisterScreen extends StatelessWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký ${role.toLowerCase()}"), backgroundColor: Colors.black),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isObscureConfirm = true;

  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản thành công! Đang đăng nhập...'), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.red),
              const SizedBox(height: 10),
              const Text("Tạo tài khoản mới", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              TextFormField(
                decoration: InputDecoration(labelText: "Họ và tên", prefixIcon: const Icon(Icons.person, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không đúng định dạng';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // TRƯỜNG NHẬP SỐ ĐIỆN THOẠI MỚI THÊM
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Số điện thoại", prefixIcon: const Icon(Icons.phone, color: Colors.red), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập SĐT';
                  // Kiểm tra SĐT nhà mạng VN (10 số, bắt đầu bằng 03, 05, 07, 08, 09)
                  if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$').hasMatch(val)) {
                    return 'SĐT không hợp lệ (VD: 0912345678)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock, color: Colors.red),
                  suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscure = !_isObscure)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                  if (!RegExp(pattern).hasMatch(val)) {
                    return 'Mật khẩu phải >= 8 ký tự, có chữ hoa, thường, số và ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.red),
                  suffixIcon: IconButton(icon: Icon(_isObscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscureConfirm = !_isObscureConfirm)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (val != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
                onPressed: _register,
                child: const Text("ĐĂNG KÝ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đã có tài khoản? Quay lại đăng nhập", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}