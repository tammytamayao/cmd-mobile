import 'package:cmd_mobile/billing/billing_history_page.dart.dart';
import 'package:flutter/material.dart';

import 'dashboard/dashboard_page.dart';
import 'services/auth_service.dart';
import 'support/support_page.dart'; // ✅ new file

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  int index = 0;

  String _titleForIndex(int i) {
    switch (i) {
      case 1:
        return "Bills & Payments";
      case 2:
        return "Support";
      default:
        return "Dashboard";
    }
  }

  Future<void> _logout() async {
    await widget.auth.logout();
    if (!mounted) return;

    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(auth: widget.auth),
      BillingHistoryPage(auth: widget.auth),
      const SupportPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // gray-100
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset("assets/logo.jpg", height: 24, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text(
              _titleForIndex(index),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF6B7280),
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Bills",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            label: "Support",
          ),
        ],
      ),
    );
  }
}
