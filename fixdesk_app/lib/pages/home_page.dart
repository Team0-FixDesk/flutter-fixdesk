import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import 'report_repair_page.dart';
import 'my_repair_list_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  List repairs = [];
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final data = await ApiService.getMyRepairs(widget.userData['us_id']);

    setState(() {
      repairs = data;
      isLoadingStats = false;
    });
  }

  /// ใส่ตรงนี้
  int get total => repairs.length;

  int get pending =>
      repairs.where((r) => r['rf_user_status'] == 'รอดำเนินการ').length;

  int get done =>
      repairs.where((r) => r['rf_user_status'] == 'เสร็จสิ้น').length;

  String get fullName {
    final first = widget.userData['us_first_name_th'] ?? '';
    final last = widget.userData['us_last_name_th'] ?? '';
    return '$first $last';
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      MyRepairListPage(userData: widget.userData),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      /// ปุ่ม +
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportRepairPage(userData: widget.userData)),
          );
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /// Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "หน้าแรก",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "รายการ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "โปรไฟล์",
          ),
        ],
      ),
    );
  }

  /// DASHBOARD
  Widget dashboard() {
    return SafeArea(
      child: Column(
        children: [
          /// HEADER
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.build,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "FixDesk",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "สวัสดีคุณ$fullName",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "ยินดีต้อนรับสู่ FixDesk",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// STATS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    "ทั้งหมด",
                    total.toString(),
                    Icons.insert_drive_file,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard("รอซ่อม", pending.toString(), Icons.handyman),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    "เสร็จแล้ว",
                    done.toString(),
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// LIST HEADER
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "รายการล่าสุด",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// LIST
          Expanded(
            child: FutureBuilder(
              future: ApiService.getMyRepairs(widget.userData['us_id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final repairs = snapshot.data as List;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: repairs.length > 3 ? 3 : repairs.length,
                  itemBuilder: (context, index) {
                    final repair = repairs[index];

                    return RepairItem(
                      title: repair['rf_problem'] ?? '',
                      subtitle: repair['rf_create_at'] ?? '',
                      status: repair['rf_user_status'] ?? '',
                      color: repair['rf_user_status'] == 'เสร็จสิ้น'
                          ? Colors.green
                          : Colors.orange,
                      icon: Icons.build,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard(this.title, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),

            const SizedBox(height: 6),

            Text(title, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RepairItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color color;
  final IconData icon;

  const RepairItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person, size: 32, color: Colors.blue.shade700),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PROFILE PAGE
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("หน้าโปรไฟล์"));
  }
}
