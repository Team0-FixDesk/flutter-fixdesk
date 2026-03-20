import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import 'user_detail_repair.dart';

class MyRepairListPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final ValueChanged<int>? onTabSelected;

  const MyRepairListPage({
    super.key,
    required this.userData,
    this.onTabSelected,
  });

  @override
  State<MyRepairListPage> createState() => _MyRepairListPageState();
}

class _MyRepairListPageState extends State<MyRepairListPage> {
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
      final userId = widget.userData['us_id'];
      final data = await ApiService.getMyRepairs(userId);

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

  // แปลง enum DB → ภาษาไทย
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

  // แปลง urgency enum DB → ภาษาไทย
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year + 543}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),

      body: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FIXDESK BAR
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

                /// TITLE
                const Text(
                  "รายการแจ้งซ่อมของฉัน",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                /// SEARCH
                Row(
                  children: [
                    /// SEARCH
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

                    /// STATUS FILTER
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
                            value: 'ดำเนินการเสร็จสิ้น',
                            child: Text('ดำเนินการเสร็จสิ้น'),
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
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRepairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มีรายการแจ้งซ่อม',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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
                            "${room?['room_name'] ?? '-'} "
                            "ชั้น ${floor?['fl_name'] ?? '-'} "
                            "${building?['bd_name'] ?? ''}",
                        priority: _urgencyLabel(item['rf_urgency']),
                        status: _statusLabel(status),
                        color: _statusColor(status),
                        currentTabIndex: 1,
                        onTabSelected: widget.onTabSelected,
                        repair: item,
                      );
                    },
                  ),
          ),
        ],
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

          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

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
                onTap: () async {
                  final selectedTab = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailRepairPage(
                        repair: repair,
                        currentTabIndex: currentTabIndex,
                      ),
                    ),
                  );

                  if (selectedTab != null) {
                    onTabSelected?.call(selectedTab);
                  }
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
