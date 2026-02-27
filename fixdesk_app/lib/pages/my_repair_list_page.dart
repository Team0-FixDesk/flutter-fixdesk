import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyRepairListPage extends StatefulWidget {
  const MyRepairListPage({super.key});

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
      final data = await Supabase.instance.client
          .from('repair_form')
          .select()
          
          .limit(20);

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : repairs.isEmpty
              ? const Center(child: Text('ยังไม่มีข้อมูลรายการซ่อม'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: repairs.length,
                  itemBuilder: (context, index) {
                    final item = repairs[index];
                    debugPrint('Row $index: $item'); // ดู column จริงใน console
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          item['rf_id']?.toString() ??
                          item['id']?.toString() ?? '-',
                        ),
                        subtitle: Text(
                          item['rf_code']?.toString() ??
                          item['code']?.toString() ?? '',
                        ),
                        trailing: Chip(
                          label: Text(
                            item['status_name']?.toString() ??
                            item['status']?.toString() ?? '-',
                          ),
                          backgroundColor: statusColor(
                            item['status_name']?.toString() ??
                            item['status']?.toString() ?? '-',
                          ).withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}