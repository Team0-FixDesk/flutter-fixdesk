import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://dekdee2.informatics.buu.ac.th:8058';

  /// ✅ ดึงรายการแจ้งซ่อมของฉัน (API จริง)
  static Future<List<dynamic>> getMyRepairs(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/repair/my-list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ← จากที่เห็นใน console ระบบคุณ
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }
  }

  /// ✅ ส่งแจ้งซ่อม (API จริง)
  static Future<bool> createRepair({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/repair'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }
}