import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixdesk_app/service/api_service.dart';

class MyRepairListPage extends StatefulWidget {
  const MyRepairListPage({super.key});

  @override
  State<MyRepairListPage> createState() => _MyRepairListPageState();
}

class _MyRepairListPageState extends State<MyRepairListPage> {
  Future<List<dynamic>>? _repairs;

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    setState(() {
      _repairs = ApiService.getMyRepairs(token);
    });
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
      appBar: AppBar(
        title: const Text('รายการแจ้งซ่อมของฉัน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRepairs,
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _repairs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'เกิดข้อผิดพลาด\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadRepairs,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('ยังไม่มีรายการแจ้งซ่อม',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final status = item['status_name'] ?? '-';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor(status).withOpacity(0.15),
                    child: Icon(Icons.build, color: statusColor(status)),
                  ),
                  title: Text(
                    item['repair_no'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['detail'] ?? ''),
                  trailing: Chip(
                    label: Text(
                      status,
                      style: TextStyle(
                        color: statusColor(status),
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: statusColor(status).withOpacity(0.15),
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