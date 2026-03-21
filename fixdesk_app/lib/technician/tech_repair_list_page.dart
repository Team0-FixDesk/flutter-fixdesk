import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../user/user_detail_repair.dart';
import 'tech_detail_repair.dart';
import '../widgets/AppHead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login/login_page.dart';

class TechRepairListPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final ValueChanged<int>? onTabSelected;

  const TechRepairListPage({
    super.key,
    required this.userData,
    this.onTabSelected,
  });

  @override
  State<TechRepairListPage> createState() => _TechRepairListPageState();
}

class _TechRepairListPageState extends State<TechRepairListPage> {
  List<dynamic> repairs = [];
  List<dynamic> filteredRepairs = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String selectedStatus = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    fetchRepairs();
  }

  void searchRepair(String keyword) {
    final results = repairs.where((item) {
      final code = (item['rf_code'] ?? '').toString().toLowerCase();
      final status = item['rf_user_status'] ?? '';

      bool matchKeyword = code.contains(keyword.toLowerCase());

      bool matchStatus =
          selectedStatus == 'ทั้งหมด' || _statusLabel(status) == selectedStatus;

      return matchKeyword && matchStatus;
    }).toList();

    setState(() {
      filteredRepairs = results;
    });
  }

  Future<void> fetchRepairs() async {
    try {
      final data = await ApiService.getAllRepairs();

      setState(() {
        repairs = data;
        filteredRepairs = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Supabase error: $e');
      setState(() {
        repairs = [];
        isLoading = false;
      });
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
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _urgencyLabel(String? urgency) {
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
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SafeArea(
        // ✅ เพิ่มตรงนี้
        child: Column(
          children: [
            /// ✅ แก้ตรงนี้ (ใช้ title แทน)
            AppHeader(
              title: "รายการแจ้งซ่อมของฉัน",
              titleSize: 18,
              onLogout: () async {
                await Supabase.instance.client.auth.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            
            /// SEARCH + FILTER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xfff3f4f6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: searchRepair,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "ค้นหาด้วยรหัสใบแจ้งซ่อม...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff3f4f6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'ทั้งหมด',
                          child: Text('สถานะ'),
                        ),
                        DropdownMenuItem(
                          value: 'รอดำเนินการ',
                          child: Text('รอดำเนินการ'),
                        ),
                        DropdownMenuItem(
                          value: 'กำลังดำเนินการ',
                          child: Text('กำลังดำเนินการ'),
                        ),
                        DropdownMenuItem(
                          value: 'เสร็จสิ้น',
                          child: Text('เสร็จสิ้น'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                        searchRepair(searchController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRepairs.isEmpty
                  ? const Center(
                      child: Text(
                        'ยังไม่มีรายการแจ้งซ่อม',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredRepairs.length,
                      itemBuilder: (context, index) {
                        final item = filteredRepairs[index];
                        final status = item['rf_user_status']?.toString();

                        final room = item['room'];
                        final floor = room?['floor'];
                        final building = floor?['building'];

                        return RepairItem(
                          code: item['rf_code'] ?? '',
                          title: item['rf_problem'] ?? '-',
                          location:
                              "${room?['room_name'] ?? '-'} ชั้น ${floor?['fl_name'] ?? '-'} ${building?['bd_name'] ?? ''}",
                          priority: _urgencyLabel(item['rf_urgency']),
                          status: _statusLabel(status),
                          color: _statusColor(status),
                          currentTabIndex: 1,
                          // onTabSelected: widget.onTabSelected,
                          repair: item,
                        );
                      },
                    ),
            ),
          ),

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRepairs.isEmpty
                ? Center(
                    child: Text(
                      'ไม่มีงาน',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRepairs.length,
                    itemBuilder: (context, index) {
                      final item = filteredRepairs[index];
                      final status = item['rf_user_status']?.toString();

                      final room = item['room'];
                      final floor = room?['floor'];
                      final building = floor?['building'];

                      return RepairItem(
                        code: item['rf_code'] ?? '',
                        title: item['rf_problem'] ?? '-',
                        location:
                            "${room?['room_name'] ?? '-'} ชั้น ${floor?['fl_name'] ?? '-'} ${building?['bd_name'] ?? ''}",
                        priority: _urgencyLabel(item['rf_urgency']),
                        status: _statusLabel(status),
                        color: _statusColor(status),
                        currentTabIndex: 1,
                        userData: widget.userData,
                        onAfterDetailClosed: fetchRepairs,
                        onTabSelected: widget.onTabSelected,
                        repair: item,
                      );
                    },
                  ),
          ),
        ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class RepairItem extends StatelessWidget {
  final String code;
  final String title;
  final String location;
  final String priority;
  final String status;
  final Color color;
  final int currentTabIndex;
  final Map<String, dynamic> userData;
  final Future<void> Function()? onAfterDetailClosed;
  final ValueChanged<int>? onTabSelected;
  final Map<String, dynamic> repair;

  const RepairItem({
    super.key,
    required this.code,
    required this.title,
    required this.location,
    required this.priority,
    required this.status,
    required this.color,
    required this.currentTabIndex,
    required this.userData,
    this.onAfterDetailClosed,
    this.onTabSelected,
    required this.repair,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#$code", style: const TextStyle(color: Colors.grey)),
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

          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(location, style: const TextStyle(color: Colors.grey)),

          const Divider(),

          /// STATUS + BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),

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
