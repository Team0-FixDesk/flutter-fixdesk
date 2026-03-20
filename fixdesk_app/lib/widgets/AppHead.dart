import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? name;
  final bool showGreeting;
  final String? title;
  final double? titleSize; // ✅ เพิ่ม

  const AppHeader({
    super.key,
    this.name,
    this.showGreeting = false,
    this.title,
    this.titleSize, // ✅ เพิ่ม
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16), // 🔥 ลดล่างนิดนึง
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
          /// TOP (LOGO + NAME)
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
            const SizedBox(height: 12), // 🔥 ลด spacing
            Text(
              title!,
              style: TextStyle(
                fontSize: titleSize ?? 16, // 🔥 ตรงนี้สำคัญ!
                fontWeight: FontWeight.bold, // 🔥 ปรับให้ modern ขึ้น
              ),
            ),
          ],
        ],
      ),
    );
  }
}