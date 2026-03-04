import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static Future<void> initSupabase() async {
    await Supabase.initialize(
      url: 'https://zokyojxouidgentyjonr.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpva3lvanhvdWlkZ2VudHlqb25yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTI0NzksImV4cCI6MjA4NzY4ODQ3OX0.talylYsvoL3VRGH3Wltl7RaXnU9dRn-3zD6MCcchoP0',
    );
  }

  /// Login ผ่าน Supabase ตาราง users
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final result = await Supabase.instance.client
        .from('users')
        .select(
          'us_id, us_user_name, us_first_name_th, us_last_name_th, '
          'us_first_name_en, us_last_name_en, us_phone, '
          'us_department, us_role_id, us_tt_id',
        )
        .eq('us_user_name', username)
        .eq('us_user_pass', password)
        .maybeSingle();

    return result;
  }

  /// ดึงรายการแจ้งซ่อมของ user
  static Future<List<dynamic>> getMyRepairs(int userId) async {
    final data = await Supabase.instance.client
        .from('repair_form')
        .select(
          'rf_id, rf_code, rf_phone, rf_prop_number, rf_problem, '
          'rf_detail, rf_user_status, rf_urgency, '
          'rf_create_at, rf_update_at',
        )
        .eq('rf_us_id', userId)
        .order('rf_create_at', ascending: false)
        .limit(30);

    return data;
  }
}