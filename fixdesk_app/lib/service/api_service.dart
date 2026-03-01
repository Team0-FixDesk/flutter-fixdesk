import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://dekdee2.informatics.buu.ac.th:8058';

  static Dio _createDio({String? token}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    return dio;
  }

  /// ✅ Login และรับ Token
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final dio = _createDio();
      final response = await dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return {
          'token': json['token'] ?? json['access_token'] ?? '',
          'name': json['name'] ?? json['user']?['name'] ?? username,
        };
      }
      return null;
    } on DioException {
      return null;
    }
  }

  /// ✅ Logout - ล้าง token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
  }

  /// ✅ ดึง Token ที่บันทึกไว้
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ ดึงรายการแจ้งซ่อมของฉัน
  static Future<List<dynamic>> getMyRepairs(String token) async {
    try {
      final dio = _createDio(token: token);
      final response = await dio.get('/api/repair/my-list');

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return json['data'] as List<dynamic>;
      }
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${response.statusCode})');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      throw Exception('โหลดข้อมูลไม่สำเร็จ ($statusCode)');
    }
  }

  /// ✅ ส่งแจ้งซ่อม
  static Future<bool> createRepair({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final dio = _createDio(token: token);
      final response = await dio.post(
        '/api/repair',
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}