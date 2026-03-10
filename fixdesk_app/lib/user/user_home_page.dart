import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import 'user_report_repair_page.dart';
import 'user_my_repair_list_page.dart';
import 'user_my_profile.dart';
import 'user_detail_repair.dart';

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
    loadStats(); // ← ต้องเรียกตรงนี้
  }

  Future<void> loadStats() async {
    try {
      final data = await ApiService.getMyRepairs(widget.userData['us_id']);

      if (!mounted) return;

      setState(() {
        repairs = (data as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        repairs = <Map<String, dynamic>>[];
        isLoadingStats = false;
      });
    }
  }

  /// ใส่ตรงนี้
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

  String get fullName {
    final first = widget.userData['us_first_name_th'] ?? '';
    final last = widget.userData['us_last_name_th'] ?? '';
    return '$first $last';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';

    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year + 543} '
          '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

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
        return const Color(0xFFF59E0B); // ส้ม
      case 'in_progress':
        return const Color(0xFF3B82F6); // น้ำเงิน
      case 'done':
        return const Color(0xFF22C55E); // เขียว
      case 'cancelled':
        return const Color(0xFFEF4444); // แดง
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboard(),
      MyRepairListPage(userData: widget.userData),
      ProfilePage(userData: widget.userData),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      /// ปุ่ม +
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

          loadStats(); // refresh dashboard
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
    return Container(
      color: Colors.grey.shade100,
      child: SafeArea(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/LOGO.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
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
                    child: StatCard(
                      "รอดำเนินการ",
                      pending.toString(),
                      Icons.handyman,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      "ดำเนินการเสร็จสิ้น",
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
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: repairs.length > 5 ? 5 : repairs.length,
                      itemBuilder: (context, index) {
                        final repair = repairs[index];

                        return RepairItem(
                          repair: repair,
                          code: repair['rf_code'] ?? '',

                          /// ดึงจาก "หัวข้อเรื่อง"
                          title: repair['rf_problem'] ?? '-',

                          /// ดึงจาก "สถานที่"
                          location:
                              "${repair['room_name'] ?? '-'}  "
                              "ชั้น ${repair['fl_name'] ?? '-'}  "
                              "${repair['bd_name'] ?? ''}",

                          /// ดึงจาก "ความเร่งด่วน"
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

class RepairItem extends StatelessWidget {
  final Map<String, dynamic> repair;
  final String code;
  final String title;
  final String location;
  final String priority;
  final String status;
  final Color color;

  const RepairItem({
    super.key,
    required this.repair,
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
        return const Color(0xFFF8D7DA);
      case 'เร่งด่วน':
        return const Color(0xFFFCE8C3);
      default:
        return const Color(0xFFD1F3E0);
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
                  priority,
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

              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailRepairPage(repair: repair),
                    ),
                  );
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
                  child: const Text(
                    "ดูรายละเอียด",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
