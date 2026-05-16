import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondaryPink, Color(0xFFC2185B)],
            begin: Alignment.topRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Icon(
              Icons.person_add_alt_1,
              size: 80,
              color: AppColors.white,
            ),
            const Text(
              'Aramıza Katıl',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildInput(_nameController, 'Ad Soyad', Icons.person),
                      const SizedBox(height: 20),
                      _buildInput(_emailController, 'E-posta', Icons.email),
                      const SizedBox(height: 20),
                      _buildInput(
                        _passwordController,
                        'Şifre',
                        Icons.lock,
                        isPass: true,
                      ),
                      const SizedBox(height: 40),
                      _buildRegButton(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Zaten hesabım var',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildRegButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'KAYIT OL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (success)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
  }
}
