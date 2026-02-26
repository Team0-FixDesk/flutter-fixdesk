import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';

class ReportRepairPage extends StatefulWidget {
  const ReportRepairPage({super.key});

  @override
  State<ReportRepairPage> createState() => _ReportRepairPageState();
}

class _ReportRepairPageState extends State<ReportRepairPage> {
  final subjectController = TextEditingController();
  final detailController = TextEditingController();

  final String token = 'PUT_REAL_TOKEN_HERE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งซ่อม')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'หัวข้อแจ้งซ่อม',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด / สาเหตุ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('ส่งแจ้งซ่อม'),
                onPressed: () async {
                  final payload = {
                    "subject": subjectController.text,
                    "phone": "0913451223",
                    "department": "องค์การบริหารส่วนจังหวัดชลบุรี",
                    "category_id": 1,
                    "detail": detailController.text,
                    "building_id": 1,
                    "floor_id": 1,
                    "room_id": 1,
                  };

                  final success = await ApiService.createRepair(
                    token: token,
                    payload: payload,
                  );

                  if (success) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ส่งไม่สำเร็จ')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}