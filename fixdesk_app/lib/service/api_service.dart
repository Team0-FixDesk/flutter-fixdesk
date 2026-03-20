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
    String username,
    String password,
  ) async {
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
          'rf_detail, rf_user_status, rf_urgency, rf_room_id, '
          'rf_create_at, rf_update_at',
        )
        .eq('rf_us_id', userId)
        .order('rf_create_at', ascending: false)
        .limit(30);

    final repairs = List<Map<String, dynamic>>.from(data);
    final roomIds = repairs
        .map((item) => item['rf_room_id'])
        .whereType<int>()
        .toSet()
        .toList();

    if (roomIds.isEmpty) {
      return repairs;
    }

    final roomsResponse = await Supabase.instance.client
        .from('room')
        .select('room_id, room_name, room_fl_id')
        .inFilter('room_id', roomIds);

    final rooms = List<Map<String, dynamic>>.from(roomsResponse);
    final roomsById = <int, Map<String, dynamic>>{
      for (final room in rooms)
        if (room['room_id'] is int) room['room_id'] as int: room,
    };

    final floorIds = rooms
        .map((room) => room['room_fl_id'])
        .whereType<int>()
        .toSet()
        .toList();

    final floorsResponse = floorIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await Supabase.instance.client
                .from('floor')
                .select('fl_id, fl_name, fl_bd_id')
                .inFilter('fl_id', floorIds),
          );

    final floorsById = <int, Map<String, dynamic>>{
      for (final floor in floorsResponse)
        if (floor['fl_id'] is int) floor['fl_id'] as int: floor,
    };

    final buildingIds = floorsResponse
        .map((floor) => floor['fl_bd_id'])
        .whereType<int>()
        .toSet()
        .toList();

    final buildingsResponse = buildingIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await Supabase.instance.client
                .from('building')
                .select('bd_id, bd_name')
                .inFilter('bd_id', buildingIds),
          );

    final buildingsById = <int, Map<String, dynamic>>{
      for (final building in buildingsResponse)
        if (building['bd_id'] is int) building['bd_id'] as int: building,
    };

    for (final repair in repairs) {
      final roomId = repair['rf_room_id'];
      if (roomId is! int) {
        continue;
      }

      final room = roomsById[roomId];
      if (room == null) {
        continue;
      }

      final floorId = room['room_fl_id'];
      final floor = floorId is int ? floorsById[floorId] : null;
      final buildingId = floor?['fl_bd_id'];
      final building = buildingId is int ? buildingsById[buildingId] : null;

      repair['room_name'] = room['room_name'];
      repair['fl_name'] = floor?['fl_name'];
      repair['bd_name'] = building?['bd_name'];
    }

    return repairs;
  }

  /// สร้างรายการแจ้งซ่อม
  static Future<bool> createRepair({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await Supabase.instance.client.from('repair_form').insert(payload);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// อัปเดตสถานะรายการแจ้งซ่อม
  static Future<bool> updateRepairStatus({
    required int repairId,
    required String status,
  }) async {
    try {
      await Supabase.instance.client
          .from('repair_form')
          .update({
            'rf_user_status': status,
            'rf_update_at': DateTime.now().toIso8601String(),
          })
          .eq('rf_id', repairId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ดึงรายการอาคารทั้งหมด
  static Future<List<Map<String, dynamic>>> getBuildings() async {
    final data = await Supabase.instance.client
        .from('building')
        .select('bd_id, bd_name')
        .order('bd_id');
    return List<Map<String, dynamic>>.from(data);
  }

  /// ดึงรายการชั้นตามอาคาร
  static Future<List<Map<String, dynamic>>> getFloors(int buildingId) async {
    final data = await Supabase.instance.client
        .from('floor')
        .select('fl_id, fl_name')
        .eq('fl_bd_id', buildingId)
        .order('fl_id');
    return List<Map<String, dynamic>>.from(data);
  }

  /// ดึงรายการห้องตามชั้น
  static Future<List<Map<String, dynamic>>> getRooms(int floorId) async {
    final data = await Supabase.instance.client
        .from('room')
        .select('room_id, room_name')
        .eq('room_fl_id', floorId)
        .order('room_id');
    return List<Map<String, dynamic>>.from(data);
  }
}
