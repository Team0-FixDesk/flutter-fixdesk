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
      repairs = (data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

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
      TechRepairListPage(userData: widget.userData),
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

          /// LIST HEADER
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "งานที่แจ้งล่าสุด",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final activeRepairs = repairs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: activeRepairs.length > 5
                            ? 5
                            : activeRepairs.length,
                        itemBuilder: (context, index) {
                          final repair = activeRepairs[index];

                          final room = repair['room'];
                          final floor = room?['floor'];
                          final building = floor?['building'];

                          return RepairItem(
                            repair: repair,
                            userData: widget.userData,
                            code: repair['rf_code'] ?? '',
                            title: repair['rf_problem'] ?? '',

                            location:
                                "${room?['room_name'] ?? '-'} "
                                "ชั้น ${floor?['fl_name'] ?? '-'} "
                                "${building?['bd_name'] ?? ''}",

                            priority: urgencyLabel(repair['rf_urgency']),
                            status: statusLabel(repair['rf_user_status']),
                            color: statusColor(repair['rf_user_status']),
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

class RepairItem extends StatelessWidget {
  final Map<String, dynamic> repair;
  final Map<String, dynamic> userData;
  final String code;
  final String title;
  final String location;
  final String? priority;
  final String status;
  final Color color;

  const RepairItem({
    super.key,
    required this.repair,
    required this.userData,
    required this.code,
    required this.title,
    required this.location,
    required this.priority,
    required this.status,
    required this.color,
  });

  Color get priorityColor {
    switch (priority) {
      case 'เร่งด่วนมาก':
        return AppTheme.urgentHigh;

      case 'เร่งด่วน':
        return AppTheme.urgentMedium;

      default:
        return AppTheme.urgentLow;
    }
  }

  Color get priorityTextColor {
    switch (priority) {
      case 'เร่งด่วนมาก':
        return Colors.red;

      case 'เร่งด่วน':
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CODE + PRIORITY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#$code",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority ?? '',
                  style: TextStyle(
                    color: priorityTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// TITLE
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          /// LOCATION
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const Divider(height: 20),

          /// STATUS + BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              repair['rf_user_status'] == 'pending'
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final success = await ApiService.acceptRepair(
                          repair['rf_id'],
                          userData['us_id'],
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("เริ่มงานแล้ว")),
                          );

                          repair['rf_user_status'] = 'in_progress';
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: const Text("เริ่มทำงาน"),
                    )
                  : repair['rf_user_status'] == 'in_progress'
                  ? OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserDetailRepairPage(repair: repair),
                          ),
                        );
                      },
                      child: const Text("ดูรายละเอียด"),
                    )
                  : Text(
                      "เสร็จสิ้น",
                      style: TextStyle(
                        color: AppTheme.doneColor,
                        fontWeight: FontWeight.bold,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
