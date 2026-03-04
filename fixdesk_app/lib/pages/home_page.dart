import 'package:flutter/material.dart';
import 'login_page.dart';
import 'my_repair_list_page.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomePage({super.key, required this.userData});

  String get fullNameTh {
    final first = userData['us_first_name_th'] ?? '';
    final last = userData['us_last_name_th'] ?? '';
    return '$first $last'.trim();
  }

  String get fullNameEn {
    final first = userData['us_first_name_en'] ?? '';
    final last = userData['us_last_name_en'] ?? '';
    return '$first $last'.trim();
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixDesk System'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade700,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 32, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullNameTh.isNotEmpty ? fullNameTh : fullNameEn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (userData['us_department'] != null)
                        Text(
                          userData['us_department'],
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _MenuCard(
                    icon: Icons.add_circle_outline,
                    label: 'แจ้งซ่อมใหม่',
                    color: Colors.blue.shade600,
                    onTap: () {
                      // TODO: navigate to create repair page
                    },
                  ),
                  _MenuCard(
                    icon: Icons.list_alt,
                    label: 'รายการแจ้งซ่อมของฉัน',
                    color: Colors.orange.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MyRepairListPage(userData: userData),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    icon: Icons.history,
                    label: 'ประวัติการซ่อม',
                    color: Colors.green.shade600,
                    onTap: () {
                      // TODO: navigate to history page
                    },
                  ),
                  _MenuCard(
                    icon: Icons.person_outline,
                    label: 'ข้อมูลของฉัน',
                    color: Colors.purple.shade500,
                    onTap: () {
                      // TODO: navigate to profile page
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}