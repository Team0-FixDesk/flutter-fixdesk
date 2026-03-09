import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';

class MyRepairListPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MyRepairListPage({super.key, required this.userData});

  @override
  State<MyRepairListPage> createState() => _MyRepairListPageState();
}

class _MyRepairListPageState extends State<MyRepairListPage> {
  List<dynamic> repairs = [];
  List<dynamic> filteredRepairs = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRepairs();
  }

  void searchRepair(String keyword) {
    final results = repairs.where((item) {
      final code = (item['rf_code'] ?? '').toString().toLowerCase();
      return code.contains(keyword.toLowerCase());
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

  Color _userStatusColor(String? status) {
    switch (status) {
      case 'เสร็จสิ้น':
        return Colors.green;
      case 'รอดำเนินการ':
        return Colors.orange;
      case 'กำลังดำเนินการ':
        return Colors.blue;
      case 'ยกเลิก':
        return Colors.red;
      default:
        return Colors.grey;
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

                /// TITLE
                const Text(
                  "รายการแจ้งซ่อมของฉัน",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                /// SEARCH
                Container(
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (item['rf_code'] ?? '-').toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    _formatDate(
                                      item['rf_create_at']?.toString(),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  status ?? '-',
                                  style: TextStyle(
                                    color: _userStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _userStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
