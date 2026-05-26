

import 'package:booktoplay_webapp/service/authservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileLoging extends StatefulWidget {
  const MobileLoging({super.key});

  @override
  State<MobileLoging> createState() => _MobileLogingState();
}

class _MobileLogingState extends State<MobileLoging> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  bool loading = false;
  bool _obscureText = true; // For password visibility toggle

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- SignIn Logic ---

  Future<void> _handleSignIn() async {
    if (_formkey.currentState!.validate()) {
      setState(() => loading = true);

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      final user = await _authService.signInWithEmailAndPassword(email, password);

      if (mounted) {
        setState(() => loading = false);
        if (user == null) {
          _showError('Invalid email or password. Please try again.');
        } else {
           context.go('/');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI Section ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Form(
        key: _formkey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.5, -0.5),
              radius: 1.5,
              colors: [Color(0x1A00D9A3), Color(0xFF0A0A0B)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(colors: [Color(0xFF00D9A3), Color(0xFF7B61FF)]),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Book2Play', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Welcome back', style: TextStyle(color: Colors.white54)),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B1B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Email"),
          _buildTextField(
            hint: "your@email.com",
            icon: Icons.email_outlined,
            controller: _emailController,
            validator: (val) => val!.isEmpty ? 'Enter an email' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel("Password"),
          _buildTextField(
            hint: "Enter your password",
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
          ),
          const SizedBox(height: 10),
        
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

 

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9A3),
          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign In", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                ],
              ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      );

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1A1F1F),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white24, size: 20),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D9A3), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}