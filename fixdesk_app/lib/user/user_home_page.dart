import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import '../widgets/AppHead.dart';
import '../widgets/menu_card.dart';
import 'user_report_repair_page.dart';
import 'user_my_repair_list_page.dart';
import 'user_my_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

String urgencyLabel(String? urgency) {
  switch (urgency) {
    case 'high':
      return 'เร่งด่วนมาก';
    case 'medium':
      return 'เร่งด่วน';
    default:
      return 'ปกติ';
  }
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  List<Map<String, dynamic>> repairs = [];
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final data = await ApiService.getMyRepairs(
        widget.userData['us_id'] ?? '',
      );

      if (!mounted) return;

      setState(() {
        repairs = data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        repairs = [];
        isLoadingStats = false;
      });
    }
  }

  int get total => repairs.length;

  int get pending => repairs
      .where(
        (r) =>
            r['rf_user_status'] == 'pending' ||
            r['rf_user_status'] == 'รอดำเนินการ',
      )
      .length;

  int get done => repairs
      .where(
        (r) =>
            r['rf_user_status'] == 'done' || r['rf_user_status'] == 'เสร็จสิ้น',
      )
      .length;

  String get firstName => widget.userData['us_first_name_th'] ?? '';

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'done':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'done':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      MyRepairListPage(
        userData: widget.userData,
        onTabSelected: (index) {
          setState(() => currentIndex = index);
        },
      ),
      ProfilePage(userData: widget.userData),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      floatingActionButton: FloatingActionButton(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportRepairPage(userData: widget.userData),
            ),
          );
          loadStats();
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: MenuCard(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }

  /// DASHBOARD
  Widget dashboard() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Column(
          children: [
            /// ✅ แสดง greeting เฉพาะหน้านี้
            AppHeader(
              name: firstName,
              showGreeting: true,
              onLogout: () async {
                /// 🔥 1. logout supabase
                await Supabase.instance.client.auth.signOut();

                /// 🔥 2. กัน widget พัง
                if (!context.mounted) return;

                /// 🔥 3. ล้าง stack + กลับ login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
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
                    child: StatCard(
                      "รอดำเนินการ",
                      pending.toString(),
                      Icons.handyman,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      "เสร็จสิ้น",
                      done.toString(),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "รายการล่าสุด",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : repairs.isEmpty
                  ? const Center(
                      child: Text(
                        "ยังไม่มีรายการแจ้งซ่อม",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: repairs.length > 5 ? 5 : repairs.length,
                      itemBuilder: (context, index) {
                        final repair = repairs[index];

                        final room = repair['room'];
                        final floor = room?['floor'];
                        final building = floor?['building'];

                        return RepairItem(
                          repair: repair,
                          code: repair['rf_code'] ?? '',
                          currentTabIndex: currentIndex,
                          userData: widget.userData,
                          title: repair['rf_problem'] ?? '-',
                          location:
                              "${room?['room_name'] ?? '-'} ชั้น ${floor?['fl_name'] ?? '-'} ${building?['bd_name'] ?? ''}",
                          priority: urgencyLabel(repair['rf_urgency']),
                          status: _statusLabel(
                            repair['rf_user_status'] as String?,
                          ),
                          color: _statusColor(
                            repair['rf_user_status'] as String?,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
