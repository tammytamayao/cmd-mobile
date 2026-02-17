import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget infoCard({
      required String title,
      required String body,
      IconData? icon,
      String? emoji,
      VoidCallback? onTap,
    }) {
      final content = Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB), // gray-50
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (emoji != null)
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                if (icon != null)
                  Icon(icon, size: 18, color: const Color(0xFF111827)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFF374151), // gray-700
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

      if (onTap == null) return content;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Support Center",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We’re working hard to bring you a full-featured support portal.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),

                // Cards
                infoCard(
                  emoji: "📞",
                  title: "Customer Hotline",
                  body: "Call us at: 0928 735 9757 / 0917 869 4611",
                  onTap: () {
                    // Optional: implement tap-to-call later
                    // final uri = Uri.parse("tel:09287359757");
                    // launchUrl(uri);
                  },
                ),
                const SizedBox(height: 12),
                infoCard(
                  emoji: "✉️",
                  title: "Email Support",
                  body: "Send us an email at: support@cmdcable.com",
                  onTap: () {
                    // Optional: implement email launch later
                    // final uri = Uri(
                    //   scheme: "mailto",
                    //   path: "support@cmdcable.com",
                    // );
                    // launchUrl(uri);
                  },
                ),
                const SizedBox(height: 12),
                infoCard(
                  emoji: "🕒",
                  title: "Operating Hours",
                  body: "Monday – Saturday: 8:00 AM – 5:00 PM",
                ),

                const SizedBox(height: 18),
                const Text(
                  "New features will be rolling out soon! Thank you.",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
