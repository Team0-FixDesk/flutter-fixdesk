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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRepairs();
  }

  Future<void> fetchRepairs() async {
    try {
      final userId = widget.userData['us_id'];
      final data = await ApiService.getMyRepairs(userId);
      setState(() {
        repairs = data;
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
      case 'pending':      return 'รอดำเนินการ';
      case 'in_progress':  return 'กำลังดำเนินการ';
      case 'done':         return 'เสร็จสิ้น';
      case 'cancelled':    return 'ยกเลิก';
      default:             return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':     return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'done':        return Colors.green;
      case 'cancelled':   return Colors.red;
      default:            return Colors.grey;
    }
  }

  // แปลง urgency enum DB → ภาษาไทย
  String _urgencyLabel(String? urgency) {
    switch (urgency) {
      case 'low':    return 'ปกติ';
      case 'medium': return 'ด่วน';
      case 'high':   return 'ด่วนมาก';
      default:       return urgency ?? '-';
    }
  }

  IconData _urgencyIcon(String? urgency) {
    switch (urgency) {
      case 'high':   return Icons.priority_high;
      case 'medium': return Icons.warning_amber_outlined;
      default:       return Icons.access_time;
    }
  }

  Color _urgencyColor(String? urgency) {
    switch (urgency) {
      case 'high':   return Colors.red;
      case 'medium': return Colors.orange;
      default:       return Colors.grey;
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
      appBar: AppBar(
        title: const Text('รายการแจ้งซ่อมของฉัน'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              fetchRepairs();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : repairs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'ยังไม่มีรายการแจ้งซ่อม',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: repairs.length,
                  itemBuilder: (context, index) {
                    final item = repairs[index];
                    final status = item['rf_user_status']?.toString();
                    final urgency = item['rf_urgency']?.toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['rf_code']?.toString() ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                // ความเร่งด่วน (แสดงเฉพาะ medium/high)
                                if (urgency != 'low') ...[
                                  Icon(
                                    _urgencyIcon(urgency),
                                    color: _urgencyColor(urgency),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                // Badge สถานะ
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            _statusColor(status).withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (item['rf_problem'] != null)
                              Text(
                                item['rf_problem'].toString(),
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 13, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(item['rf_create_at']?.toString()),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ),
                                if (item['rf_prop_number'] != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.tag,
                                      size: 13, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['rf_prop_number'].toString(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                                const Spacer(),
                                // แสดง urgency label
                                Text(
                                  _urgencyLabel(urgency),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _urgencyColor(urgency),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}