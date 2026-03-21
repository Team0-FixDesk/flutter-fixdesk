import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? name;
  final bool showGreeting;
  final String? title;
  final double? titleSize;
  final VoidCallback? onLogout; // ✅ เพิ่ม

  const AppHeader({
    super.key,
    this.name,
    this.showGreeting = false,
    this.title,
    this.titleSize,
    this.onLogout, // ✅ เพิ่ม
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔵 TOP (LOGO + NAME + LOGOUT)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// LEFT (LOGO + NAME)
              Row(
                children: [
                  Image.asset('assets/images/LOGO.png', width: 32),
                  const SizedBox(width: 10),
                  Text(
                    "FixDesk",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              /// RIGHT (LOGOUT BUTTON)
              if (onLogout != null)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onLogout,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      size: 20,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ),

          /// Greeting (Dashboard)
          if (showGreeting && name != null) ...[
            const SizedBox(height: 14),
            Text(
              "สวัสดี คุณ$name",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          /// Title (List / Profile)
          if (title != null) ...[
            const SizedBox(height: 12),
            Text(
              title!,
              style: TextStyle(
                fontSize: titleSize ?? 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}