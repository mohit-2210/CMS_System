import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/pages/admin_dashboard.dart';
import 'package:cms/pages/admin_registration_screen.dart';

@NowaGenerated()
class LoginScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

@NowaGenerated()
class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _validatePhone(String phone) {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be exactly 10 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();
    if (!_validatePhone(phone)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final authService = AuthService.of(context);
    final result = await authService.login(phone);
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
    final action = result['action'];
    
    // Both Super Admin and Regular Admin go to the SAME AdminDashboard
    // The difference is that Super Admin will see the drawer icon
    if (action == 'super_admin_dashboard' || action == 'admin_dashboard') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else if (action == 'rejected') {
      // Rejected admin can still see dashboard but with limited access
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Access Rejected'),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
              },
              child: const Text('Open Dashboard'),
            ),
          ],
        ),
      );
    } else if (action == 'pending') {
      // Pending admin - show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (action == 'register') {
      // New user - navigate to registration
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminRegistrationScreen(phone: phone),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf1fb),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xff003a78),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.construction,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Construction Site\nManagement System',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xff0a2342),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your phone number to continue',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff607286),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter 10 digit phone number',
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: const Color(0xffe7edf4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff003a78),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}