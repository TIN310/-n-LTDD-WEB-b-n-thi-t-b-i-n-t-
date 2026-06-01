import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Home.dart';
//
// import 'staff_dashboard.dart';

// ==========================================
// MÀN HÌNH ĐĂNG NHẬP (2 TAB)
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "ELECTRO STORE",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
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
  bool _isLoading = false;

  // [SỬA] Xóa StreamSubscription OAuth - chuyển sang _navigateByRole()
  // để tránh conflict với _login() và xử lý role đúng cách
  StreamSubscription<AuthState>? _authSubscription;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // [SỬA] Listener chỉ dùng cho OAuth (Google/Facebook)
    // Đọc role từ DB trước khi điều hướng
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        final user = data.session?.user;
        if (user == null) return;
        await _navigateByRole(user.id);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // [MỚI] Hàm dùng chung: đọc vaitro từ DB rồi điều hướng
  Future<void> _navigateByRole(String userId) async {
    try {
      // Lấy email từ session hiện tại
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      if (userEmail == null) return;

      // [SỬA] Query bằng email thay vì id
      final data = await Supabase.instance.client
          .from('nguoidung')
          .select('vaitro')
          .eq('email', userEmail)  // ← đổi từ 'id' sang 'email'
          .single();

      final String roleFromDB = data['vaitro'] ?? 'User';

      // [SỬA] Kiểm tra: tab "Nhân viên" chỉ cho tài khoản Staff đăng nhập
      if (widget.role == "Nhân viên" && roleFromDB != "Staff") {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản này không có quyền nhân viên!'),
            backgroundColor: Colors.red,
          ),
        );
        await Supabase.instance.client.auth.signOut();
        return;
      }

      if (!mounted) return;

      // [SỬA] Điều hướng theo role thay vì luôn về HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => roleFromDB == "Staff"
              ? const HomeScreen() //TODO: chuyển thành hàm của staff_dashboard
              : const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kiểm tra quyền: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      await Supabase.instance.client.auth.signOut();
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang xác thực...')),
        );

        final AuthResponse res =
            await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (res.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // [SỬA] Dùng _navigateByRole thay vì navigate thẳng
          await _navigateByRole(res.user!.id);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'electrostore://login-callback/',
      );
      // Điều hướng sẽ được xử lý bởi _authSubscription listener
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi Google: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginFacebook() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'electrostore://login-callback/',
      );
      // Điều hướng sẽ được xử lý bởi _authSubscription listener
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi Facebook: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                child: const Icon(
                  Icons.electrical_services_rounded,
                  size: 80,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Đăng nhập ${widget.role}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email, color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // [GIỮ NGUYÊN] Field mã nhân viên cho tab Staff
              if (isStaff) ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Mã nhân viên",
                    prefixIcon: const Icon(Icons.badge, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập mã nhân viên' : null,
                ),
                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock, color: Colors.red),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty)
                        ? 'Vui lòng nhập mật khẩu'
                        : null,
              ),

              const SizedBox(height: 30),

              // [SỬA] Thêm loading indicator khi đang xử lý
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.red)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "ĐĂNG NHẬP",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // [GIỮ NGUYÊN] Chỉ hiện OAuth cho tab Người dùng
              if (!isStaff) ...[
                const Text(
                  "Hoặc đăng nhập bằng",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      Icons.g_mobiledata,
                      Colors.white,
                      'Google',
                      _loginGoogle,
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      Icons.facebook,
                      Colors.blue,
                      'Facebook',
                      _loginFacebook,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // [SỬA] Ẩn nút đăng ký ở tab Nhân viên
              if (!isStaff)
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(role: widget.role),
                    ),
                  ),
                  child: const Text(
                    "Chưa có tài khoản? Đăng ký ngay",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    Color color,
    String name,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
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
      appBar: AppBar(
        title: Text("Đăng ký ${role.toLowerCase()}"),
        backgroundColor: Colors.black,
      ),
      body: RegisterForm(role: role),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final String role;
  const RegisterForm({super.key, required this.role});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tạo tài khoản...')),
        );

        // Bước 1: Tạo tài khoản trên Supabase Auth
        final AuthResponse res =
            await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (res.user != null) {
          String roleToSave = widget.role == "Nhân viên" ? "Staff" : "User";

          // Bước 2: Lưu thông tin vào bảng nguoidung
          // [SỬA] Thêm 'id' để liên kết với Supabase Auth
          // [SỬA] Xóa 'matkhau' - không lưu mật khẩu plaintext
          await Supabase.instance.client.from('nguoidung').insert({
            'id': res.user!.id,
            'hoten': _nameController.text.trim(),
            'vaitro': roleToSave,
            'taikhoan': _emailController.text.trim().split('@')[0],
            'email': _emailController.text.trim(),
            'sdt': _phoneController.text.trim(),
            'ngaytao': DateTime.now().toIso8601String(),
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo tài khoản thành công! Đang đăng nhập...'),
              backgroundColor: Colors.green,
            ),
          );

          // [SỬA] Điều hướng theo role thay vì luôn về HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => roleToSave == "Staff"
                  ? const HomeScreen() // TODO: chuyển thành hàm của staff_dashboard
                  : const HomeScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng ký: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
              const Text(
                "Tạo tài khoản mới",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  prefixIcon: const Icon(Icons.person, color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email, color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập Email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(val)) {
                    return 'Email không đúng định dạng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: const Icon(Icons.phone, color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Vui lòng nhập SĐT';
                  if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$')
                      .hasMatch(val)) {
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  String pattern =
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
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
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.red),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _isObscureConfirm = !_isObscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (val != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // [SỬA] Thêm loading indicator khi đang xử lý
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.red)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _register,
                      child: const Text(
                        "ĐĂNG KÝ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Đã có tài khoản? Quay lại đăng nhập",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
