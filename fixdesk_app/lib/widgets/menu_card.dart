import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MenuCard({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // เพิ่มเส้นขอบด้านบนบางๆ ให้เหมือนในรูป
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3366FF), // สีน้ำเงินตามรูป
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0, // ทำให้ดูแบนราบสไตล์ Minimal
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.grid_view_rounded), // ไอคอนหน้าแรกที่ใกล้เคียงที่สุด
            ),
            label: "หน้าแรก",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.list_alt_rounded), // เปลี่ยนเป็นไอคอนรายการ
            ),
            label: "รายการ",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline_rounded), // ไอคอนโปรไฟล์แบบเส้น
            ),
            label: "โปรไฟล์",
          ),
        ],
      ),
    );
  }
}