import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import 'report_repair_page.dart';
import 'my_repair_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            MenuCard(
              icon: Icons.report_problem,
              title: 'แจ้งซ่อม',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportRepairPage(),
                  ),
                );
              },
            ),
            MenuCard(
              icon: Icons.list_alt,
              title: 'รายการแจ้งซ่อมของฉัน',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRepairListPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}