import 'package:flutter/material.dart';

class TechDetailRepairPage extends StatelessWidget {
  final Map<String, dynamic> repair;

  const TechDetailRepairPage({super.key, required this.repair});

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
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = repair['room'];
    final floor = room?['floor'];
    final building = floor?['building'];

    final location =
        "${room?['room_name'] ?? '-'} "
        "ชั้น ${floor?['fl_name'] ?? '-'} "
        "${building?['bd_name'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดงานซ่อม"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PROBLEM
            Text(
              repair['rf_problem'] ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// CODE
            Text("รหัสงาน: ${repair['rf_code'] ?? '-'}"),

            const SizedBox(height: 10),

            /// LOCATION
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Text(location),
              ],
            ),

            const SizedBox(height: 10),

            /// STATUS
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: statusColor(repair['rf_user_status']),
                ),

                const SizedBox(width: 6),

                Text(
                  statusLabel(repair['rf_user_status']),
                  style: TextStyle(
                    color: statusColor(repair['rf_user_status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: update status
                },
                child: const Text("รับงาน"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}