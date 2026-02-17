import 'package:cmd_mobile/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'components/identity_field.dart';
import 'components/password_field.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final serialCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  late final TokenStorage _tokenStorage;
  late final ApiClient _api;
  late final AuthService _auth;

  bool showPassword = false;
  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _api = ApiClient(tokenStorage: _tokenStorage);
    _auth = AuthService(api: _api, tokenStorage: _tokenStorage);
  }

  bool get canSubmit {
    if (loading) return false;
    if (serialCtrl.text.trim().isEmpty) return false;
    if (passwordCtrl.text.trim().isEmpty) return false;
    return true;
  }

  @override
  void dispose() {
    serialCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  String? validateInputs() {
    if (serialCtrl.text.trim().isEmpty) return "Subscriber Number is required.";
    if (passwordCtrl.text.trim().isEmpty) return "Password is required.";
    return null;
  }

  Future<void> onSubmit() async {
    setState(() => err = null);

    final msg = validateInputs();
    if (msg != null) {
      setState(() => err = msg);
      return;
    }

    setState(() => loading = true);

    try {
      final result = await _auth.loginSubscriber(
        serialNumber: serialCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      // Optional (useful for first-time testing): verify token works
      await _auth.me();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, ${result.subscriber.firstName}!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on ApiException catch (e) {
      setState(() => err = e.message);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // rounded-2xl
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ), // gray-100
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/logo.jpg",
                      width: 160,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    IdentityField(serialController: serialCtrl),
                    const SizedBox(height: 12),

                    PasswordField(
                      controller: passwordCtrl,
                      show: showPassword,
                      onToggleShow: () =>
                          setState(() => showPassword = !showPassword),
                    ),

                    if (err != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          err!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFDC2626), // red-600
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 44, // h-11
                      child: ElevatedButton(
                        onPressed: canSubmit ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // blue-600
                          disabledBackgroundColor: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // rounded-lg
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          loading ? "Logging in..." : "Log In",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
