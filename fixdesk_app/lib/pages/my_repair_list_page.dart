import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';

class MyRepairListPage extends StatefulWidget {
  const MyRepairListPage({super.key});

  @override
  State<MyRepairListPage> createState() => _MyRepairListPageState();
}

class _MyRepairListPageState extends State<MyRepairListPage> {
  late Future<List<dynamic>> repairs;

  // 🔥 ใส่ token จริงจากระบบ (ตอนนี้ hardcode ไปก่อน)
  final String token = 'PUT_REAL_TOKEN_HERE';

  @override
  void initState() {
    super.initState();
    repairs = ApiService.getMyRepairs(token);
  }

  Color statusColor(String status) {
    switch (status) {
      case 'ดำเนินการเสร็จสิ้น':
        return Colors.green;
      case 'รอดำเนินการ':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายการแจ้งซ่อมของฉัน')),
      body: FutureBuilder<List<dynamic>>(
        future: repairs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(item['repair_no']),
                  subtitle: Text(item['detail'] ?? ''),
                  trailing: Chip(
                    label: Text(item['status_name']),
                    backgroundColor:
                        statusColor(item['status_name']).withOpacity(0.2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}