import 'package:flutter/material.dart';

class UserDetailRepairPage extends StatelessWidget {
  final Map<String, dynamic> repair;

  const UserDetailRepairPage({
    super.key,
    required this.repair,
  });

  String statusLabel(String? status) {
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

  @override
  Widget build(BuildContext context) {
    final status = repair['rf_user_status'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดแจ้งซ่อม"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CODE
            Text(
              repair['rf_code'] ?? '-',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// PROBLEM
            const Text(
              "หัวข้อปัญหา",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(repair['rf_problem'] ?? "-"),

            const SizedBox(height: 20),

            /// LOCATION
            const Text(
              "สถานที่",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(
              "${repair['room_name'] ?? '-'} "
              "ชั้น ${repair['fl_name'] ?? '-'} "
              "${repair['bd_name'] ?? ''}",
            ),

            const SizedBox(height: 20),

            /// STATUS
            const Text(
              "สถานะ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(
              statusLabel(status),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            const Text(
              "รายละเอียด",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(repair['rf_detail'] ?? "-"),
          ],
        ),
      ),
    );
  }
}