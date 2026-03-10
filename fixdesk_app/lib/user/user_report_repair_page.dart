import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';

class ReportRepairPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ReportRepairPage({super.key, required this.userData});

  @override
  State<ReportRepairPage> createState() => _ReportRepairPageState();
}

class _ReportRepairPageState extends State<ReportRepairPage> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _detailController = TextEditingController();
  final _propNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _rooms = [];

  int? _selectedBuildingId;
  int? _selectedFloorId;
  int? _selectedRoomId;

  // key = ค่า enum จริงใน DB, value = ชื่อแสดงผลภาษาไทย
  final Map<String, String> _urgencyMap = {
    'low': 'ปกติ',
    'medium': 'ด่วน',
    'high': 'ด่วนมาก',
  };
  String _selectedUrgency = 'low'; // ส่งค่า DB จริง

  bool _isLoadingDropdowns = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.userData['us_phone'] ?? '';
    _loadBuildings();
  }

  @override
  void dispose() {
    _problemController.dispose();
    _detailController.dispose();
    _propNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    try {
      final buildings = await ApiService.getBuildings();
      setState(() {
        _buildings = buildings;
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      setState(() => _isLoadingDropdowns = false);
    }
  }

  Future<void> _loadFloors(int buildingId) async {
    setState(() {
      _floors = [];
      _rooms = [];
      _selectedFloorId = null;
      _selectedRoomId = null;
    });
    try {
      final floors = await ApiService.getFloors(buildingId);
      setState(() => _floors = floors);
    } catch (e) {
      debugPrint('Load floors error: $e');
    }
  }

  Future<void> _loadRooms(int floorId) async {
    setState(() {
      _rooms = [];
      _selectedRoomId = null;
    });
    try {
      final rooms = await ApiService.getRooms(floorId);
      setState(() => _rooms = rooms);
    } catch (e) {
      debugPrint('Load rooms error: $e');
    }
  }

  /// สร้าง rf_code อัตโนมัติ (NOT NULL) เช่น RF-20260307-83421
  String _generateCode() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final rand = (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'RF-$date-$rand';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      _showError('กรุณาเลือกอาคาร ชั้น และห้อง');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = widget.userData['us_id'];
      final payload = {
        'rf_code': _generateCode(),       // NOT NULL — สร้างอัตโนมัติ
        'rf_us_id': userId,
        'rf_phone': _phoneController.text.trim(),
        'rf_prop_number': _propNumberController.text.trim().isEmpty
            ? null
            : _propNumberController.text.trim(),
        'rf_problem': _problemController.text.trim(),
        'rf_detail': _detailController.text.trim().isEmpty
            ? null
            : _detailController.text.trim(),
        'rf_room_id': _selectedRoomId,
        'rf_urgency': _selectedUrgency,   // low / medium / high
        'rf_user_status': 'pending',      // enum: pending
      };

      final success = await ApiService.createRepair(
        token: '',
        payload: payload,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('ส่งแจ้งซ่อมสำเร็จ'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        _showError('ส่งแจ้งซ่อมไม่สำเร็จ กรุณาลองใหม่');
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('แจ้งซ่อมใหม่'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- ข้อมูลผู้แจ้ง ----
                    _SectionHeader(label: 'ข้อมูลผู้แจ้ง', icon: Icons.person_outline),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: () {
                                final th =
                                    '${widget.userData['us_first_name_th'] ?? ''} ${widget.userData['us_last_name_th'] ?? ''}'
                                        .trim();
                                if (th.isNotEmpty) return th;
                                return '${widget.userData['us_first_name_en'] ?? ''} ${widget.userData['us_last_name_en'] ?? ''}'
                                    .trim();
                              }(),
                              readOnly: true,
                              decoration:
                                  _inputDecoration('ชื่อ-นามสกุล', Icons.badge_outlined),
                            ),
                            const SizedBox(height: 12),
                            if (widget.userData['us_department'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TextFormField(
                                  initialValue: widget.userData['us_department'],
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                      'หน่วยงาน / แผนก', Icons.apartment),
                                ),
                              ),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                'เบอร์โทรติดต่อ *',
                                Icons.phone_outlined,
                                hint: 'กรอกเบอร์โทรติดต่อ',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'กรุณากรอกเบอร์โทร'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- สถานที่ ----
                    _SectionHeader(label: 'สถานที่', icon: Icons.location_on_outlined),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              value: _selectedBuildingId,
                              decoration: _inputDecoration('อาคาร *', Icons.domain),
                              hint: const Text('เลือกอาคาร'),
                              isExpanded: true,
                              items: _buildings
                                  .map((b) => DropdownMenuItem<int>(
                                        value: b['bd_id'] as int,
                                        child: Text(b['bd_name']?.toString() ?? '-'),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() => _selectedBuildingId = val);
                                if (val != null) _loadFloors(val);
                              },
                              validator: (v) => v == null ? 'กรุณาเลือกอาคาร' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedFloorId,
                              decoration:
                                  _inputDecoration('ชั้น *', Icons.stairs_outlined),
                              hint: Text(_selectedBuildingId == null
                                  ? 'เลือกอาคารก่อน'
                                  : 'เลือกชั้น'),
                              isExpanded: true,
                              items: _floors
                                  .map((f) => DropdownMenuItem<int>(
                                        value: f['fl_id'] as int,
                                        child: Text(f['fl_name']?.toString() ?? '-'),
                                      ))
                                  .toList(),
                              onChanged: _selectedBuildingId == null
                                  ? null
                                  : (val) {
                                      setState(() => _selectedFloorId = val);
                                      if (val != null) _loadRooms(val);
                                    },
                              validator: (v) => v == null ? 'กรุณาเลือกชั้น' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedRoomId,
                              decoration: _inputDecoration(
                                  'ห้อง *', Icons.meeting_room_outlined),
                              hint: Text(_selectedFloorId == null
                                  ? 'เลือกชั้นก่อน'
                                  : 'เลือกห้อง'),
                              isExpanded: true,
                              items: _rooms
                                  .map((r) => DropdownMenuItem<int>(
                                        value: r['room_id'] as int,
                                        child: Text(r['room_name']?.toString() ?? '-'),
                                      ))
                                  .toList(),
                              onChanged: _selectedFloorId == null
                                  ? null
                                  : (val) => setState(() => _selectedRoomId = val),
                              validator: (v) => v == null ? 'กรุณาเลือกห้อง' : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- รายละเอียดปัญหา ----
                    _SectionHeader(
                        label: 'รายละเอียดปัญหา',
                        icon: Icons.report_problem_outlined),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _problemController,
                              decoration: _inputDecoration(
                                'หัวข้อปัญหา *',
                                Icons.title,
                                hint: 'เช่น เครื่องคอมพิวเตอร์ไม่ติด',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'กรุณากรอกหัวข้อปัญหา'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _detailController,
                              maxLines: 4,
                              decoration: _inputDecoration(
                                'รายละเอียดเพิ่มเติม',
                                Icons.description_outlined,
                                hint: 'อธิบายปัญหาอย่างละเอียด (ถ้ามี)',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _propNumberController,
                              decoration: _inputDecoration(
                                'หมายเลขครุภัณฑ์',
                                Icons.tag,
                                hint: 'กรอกหมายเลขครุภัณฑ์ (ถ้ามี)',
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Dropdown ความเร่งด่วน
                            // value = low/medium/high (ค่า DB จริง)
                            // แสดงผล = ปกติ/ด่วน/ด่วนมาก
                            DropdownButtonFormField<String>(
                              value: _selectedUrgency,
                              decoration:
                                  _inputDecoration('ความเร่งด่วน *', Icons.speed),
                              isExpanded: true,
                              items: _urgencyMap.entries.map((entry) {
                                final dbVal = entry.key;
                                final label = entry.value;
                                return DropdownMenuItem<String>(
                                  value: dbVal,
                                  child: Row(
                                    children: [
                                      Icon(
                                        dbVal == 'high'
                                            ? Icons.priority_high
                                            : dbVal == 'medium'
                                                ? Icons.warning_amber_outlined
                                                : Icons.access_time,
                                        size: 18,
                                        color: dbVal == 'high'
                                            ? Colors.red
                                            : dbVal == 'medium'
                                                ? Colors.orange
                                                : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(label),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedUrgency = val ?? 'low'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting ? 'กำลังส่ง...' : 'ส่งแจ้งซ่อม',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }
}