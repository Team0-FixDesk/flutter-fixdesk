import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../user/user_detail_repair.dart';
import 'tech_repair_list_page.dart';
import 'tech_my_profile.dart';
import '../theme/app_theme.dart';

class TechnicianHomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TechnicianHomePage({super.key, required this.userData});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  List<Map<String, dynamic>> repairs = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadRepairs();
  }

  Future<void> loadRepairs() async {
    final data = await ApiService.getAllRepairs();

    if (!mounted) return;

    setState(() {
      repairs = data.map((e) => Map<String, dynamic>.from(e)).toList();

      repairs.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['rf_create_at'] ?? '') ?? DateTime(2000);
        final dateB =
            DateTime.tryParse(b['rf_create_at'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      isLoading = false;
    });
  }

  int get total => repairs.length;
  int get pending =>
      repairs.where((r) => r['rf_user_status'] == 'pending').length;
  int get inProgress =>
      repairs.where((r) => r['rf_user_status'] == 'in_progress').length;
  int get done => repairs.where((r) => r['rf_user_status'] == 'done').length;

  String get fullName {
    return "${widget.userData['us_first_name_th']} ${widget.userData['us_last_name_th']}";
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'done':
        return 'เสร็จสิ้น';
      default:
        return '-';
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'pending':
        return AppTheme.pendingColor;
      case 'in_progress':
        return AppTheme.progressColor;
      case 'done':
        return AppTheme.doneColor;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      techDashboard(),
      TechRepairListPage(
        userData: widget.userData,
        onTabSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      TechMyProfile(userData: widget.userData),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "โปรไฟล์"),
        ],
      ),
    );
  }

  Widget techDashboard() {
    return SafeArea(
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/LOGO.png', width: 40),
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

                const SizedBox(height: 20),

                Text(
                  "สวัสดีคุณ $fullName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "Dashboard สำหรับช่าง",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// STAT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard("ทั้งหมด", total.toString(), Icons.build),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    "รอดำเนินการ",
                    pending.toString(),
                    Icons.access_time,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    "กำลังดำเนินการ",
                    inProgress.toString(),
                    Icons.handyman,
                  ),
                ),
                const SizedBox(width: 8),
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

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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
                        title: repair['rf_problem'] ?? '',
                        location:
                            "${room?['room_name'] ?? '-'} ชั้น ${floor?['fl_name'] ?? '-'} ${building?['bd_name'] ?? ''}",
                        priority: urgencyLabel(repair['rf_urgency']),
                        status: statusLabel(repair['rf_user_status']),
                        color: statusColor(repair['rf_user_status']),
                        userData: widget.userData,
                        currentTabIndex: currentIndex,
                        onAfterDetailClosed: loadRepairs,
                        onTabSelected: (selectedTab) {
                          setState(() {
                            currentIndex = selectedTab;
                          });
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

class RepairItem extends StatelessWidget {
  final Map<String, dynamic> repair;
  final String code;
  final String title;
  final String location;
  final String? priority;
  final String status;
  final Color color;
  final Map<String, dynamic> userData;
  final int currentTabIndex;
  final Future<void> Function()? onAfterDetailClosed;
  final ValueChanged<int>? onTabSelected;

  const RepairItem({
    super.key,
    required this.repair,
    required this.code,
    required this.title,
    required this.location,
    required this.priority,
    required this.status,
    required this.color,
    required this.userData,
    required this.currentTabIndex,
    this.onAfterDetailClosed,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("#$code", style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 6),

          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 6),

          Text(location, style: const TextStyle(color: Colors.grey)),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: color)),

              InkWell(
                onTap: () async {
                  final selectedTab = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailRepairPage(
                        repair: repair,
                        currentTabIndex: currentTabIndex,
                        userData: userData,
                      ),
                    ),
                  );

                  await onAfterDetailClosed?.call();

                  if (!context.mounted || selectedTab == null) {
                    return;
                  }

                  onTabSelected?.call(selectedTab);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("ดูรายละเอียด"),
                ),
              ),
            ],
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
