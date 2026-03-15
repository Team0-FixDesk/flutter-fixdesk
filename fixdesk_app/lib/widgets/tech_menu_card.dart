import 'package:flutter/material.dart';

class TechMenuCard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TechMenuCard({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "หน้าแรก",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle),
          label: "งานซ่อม",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "โปรไฟล์",
        ),
      ],
    );
  }
}