import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../login/login_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.auth,
    required this.title,
    required this.child,
    this.showBack = false,
  });

  final AuthService auth;
  final String title;
  final Widget child;
  final bool showBack;

  Future<void> _logout(BuildContext context) async {
    await auth.logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // bg-gray-100 like PageShell
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            // If you’re already on dashboard, this is harmless.
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.asset(
              "assets/logo.jpg",
              width: 160,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          // Optional: overflow menu (like desktop nav)
          PopupMenuButton<String>(
            tooltip: "Menu",
            onSelected: (v) async {
              if (v == "dashboard") {
                Navigator.of(context).popUntil((r) => r.isFirst);
              } else if (v == "billing") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Bills & Payments page")),
                );
              } else if (v == "support") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Support page")),
                );
              } else if (v == "logout") {
                await _logout(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "dashboard", child: Text("Dashboard")),
              PopupMenuItem(value: "billing", child: Text("Bills & Payments")),
              PopupMenuItem(value: "support", child: Text("Support")),
              PopupMenuDivider(),
              PopupMenuItem(
                value: "logout",
                child: Text(
                  "Logout",
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ),
        ],
      ),

      // Drawer = your mobile dropdown menu equivalent
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                  "assets/logo.jpg",
                  width: 180,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text("Dashboard"),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text("Bills & Payments"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("TODO: Bills & Payments page"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined),
                title: const Text("Support"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("TODO: Support page")),
                  );
                },
              ),

              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _logout(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24,
        ), // like main px-6 py-10
        child: child,
      ),
    );
  }
}
