import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import '../widgets/AppHead.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login/login_page.dart';

class ReportRepairPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ReportRepairPage({super.key, required this.userData});

  @override
  State<ReportRepairPage> createState() => _ReportRepairPageState();
}

class _ReportRepairPageState extends State<ReportRepairPage> {
  final _formKey = GlobalKey<FormState>();
  final _propNumberController = TextEditingController();
  final _detailController = TextEditingController();
  final _locationDisplayController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _rooms = [];

  int? _selectedBuildingId;
  int? _selectedFloorId;
  int? _selectedRoomId;

  String? _selectedBuildingName;
  String? _selectedFloorName;
  String? _selectedRoomName;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _urgencyMap = {
    'low': 'ปกติ',
    'medium': 'ด่วน',
    'high': 'ด่วนมาก',
  };
  String? _selectedUrgency;

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
    _propNumberController.dispose();
    _detailController.dispose();
    _locationDisplayController.dispose();
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

  Future<void> _loadFloors(int buildingId, StateSetter setModalState) async {
    setModalState(() {
      _floors = [];
      _rooms = [];
      _selectedFloorId = null;
      _selectedRoomId = null;
      _selectedFloorName = null;
      _selectedRoomName = null;
    });
    try {
      final floors = await ApiService.getFloors(buildingId);
      setModalState(() => _floors = floors);
    } catch (e) {
      debugPrint('Load floors error: $e');
    }
  }

  Future<void> _loadRooms(int floorId, StateSetter setModalState) async {
    setModalState(() {
      _rooms = [];
      _selectedRoomId = null;
      _selectedRoomName = null;
    });
    try {
      final rooms = await ApiService.getRooms(floorId);
      setModalState(() => _rooms = rooms);
    } catch (e) {
      debugPrint('Load rooms error: $e');
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เลือกสถานที่',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedBuildingId,
                    decoration: _modalInputDecoration(
                      'เลือกอาคาร',
                      Icons.domain,
                    ),
                    items: _buildings.map((b) {
                      return DropdownMenuItem<int>(
                        value: b['bd_id'] as int,
                        child: Text(b['bd_name']?.toString() ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedBuildingId = val;
                        _selectedBuildingName = _buildings.firstWhere(
                          (b) => b['bd_id'] == val,
                        )['bd_name'];
                      });
                      if (val != null) _loadFloors(val, setModalState);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedFloorId,
                    decoration: _modalInputDecoration(
                      'เลือกชั้น',
                      Icons.layers_outlined,
                    ),
                    items: _floors.map((f) {
                      return DropdownMenuItem<int>(
                        value: f['fl_id'] as int,
                        child: Text(f['fl_name']?.toString() ?? '-'),
                      );
                    }).toList(),
                    onChanged: _selectedBuildingId == null
                        ? null
                        : (val) {
                            setModalState(() {
                              _selectedFloorId = val;
                              _selectedFloorName = _floors.firstWhere(
                                (f) => f['fl_id'] == val,
                              )['fl_name'];
                            });
                            if (val != null) _loadRooms(val, setModalState);
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedRoomId,
                    decoration: _modalInputDecoration(
                      'เลือกห้อง',
                      Icons.meeting_room_outlined,
                    ),
                    items: _rooms.map((r) {
                      return DropdownMenuItem<int>(
                        value: r['room_id'] as int,
                        child: Text(r['room_name']?.toString() ?? '-'),
                      );
                    }).toList(),
                    onChanged: _selectedFloorId == null
                        ? null
                        : (val) {
                            setModalState(() {
                              _selectedRoomId = val;
                              _selectedRoomName = _rooms.firstWhere(
                                (r) => r['room_id'] == val,
                              )['room_name'];
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedRoomId != null
                          ? () {
                              setState(() {
                                _locationDisplayController.text =
                                    'อาคาร $_selectedBuildingName ชั้น $_selectedFloorName ห้อง $_selectedRoomName';
                              });
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _modalInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  String _generateCode() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final rand = (now.millisecondsSinceEpoch % 100000).toString().padLeft(
      5,
      '0',
    );
    return 'RF-$date-$rand';
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera, // 📸 กล้อง
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = 'repair_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final supabase = Supabase.instance.client;

      /// ✅ upload
      await supabase.storage.from('repair-images').upload(fileName, image);

      /// ✅ สร้าง URL เอง (สำคัญมาก)
      final publicUrl = supabase.storage
          .from('repair-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoomId == null) {
      _showError('กรุณาเลือกสถานที่ (อาคาร / ห้อง)');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = widget.userData['us_id'];

      /// 🔥 STEP 1: upload รูปก่อน
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      /// 🔥 STEP 2: สร้าง payload
      final payload = {
        'rf_code': _generateCode(),
        'rf_us_id': userId,
        'rf_phone': _phoneController.text.trim(),
        'rf_prop_number': _propNumberController.text.trim().isEmpty
            ? null
            : _propNumberController.text.trim(),
        'rf_problem': _propNumberController.text.trim(),
        'rf_detail': _detailController.text.trim(),
        'rf_room_id': _selectedRoomId,
        'rf_urgency': _selectedUrgency ?? 'low',
        'rf_user_status': 'pending',

        /// 🔥 จุดสำคัญ (เพิ่มตรงนี้)
        'rf_image': imageUrl,
      };

      /// 🔥 STEP 3: ยิง API
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
                Text('ส่งข้อมูลแจ้งซ่อมสำเร็จ'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        _showError('ส่งข้อมูลแจ้งซ่อมไม่สำเร็จ กรุณาลองใหม่');
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

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey.shade400, size: 22)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ HEADER (เหมือนทุกหน้า)
            AppHeader(
              showGreeting: true,
              onLogout: () async {
                await Supabase.instance.client.auth.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),

            /// 🔙 BACK + TITLE
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    "แจ้งซ่อมด่วน",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            /// CONTENT
            Expanded(
              child: _isLoadingDropdowns
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ---- Header ----
                            const Text(
                              'กรอกข้อมูลการแจ้งซ่อม',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // 🔥 เปลี่ยน
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ระบุรายละเอียดปัญหาที่พบเพื่อให้เจ้าหน้าที่เข้าดำเนินการ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// ---- Card 1 ----
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    'ชื่ออุปกรณ์ / หมายเลขครุภัณฑ์',
                                    isRequired: true,
                                  ),
                                  TextFormField(
                                    controller: _propNumberController,
                                    decoration: _inputDecoration(
                                      hint: 'ระบุอุปกรณ์ที่ชำรุด',
                                      prefixIcon: Icons.inventory_2_outlined,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'กรุณาระบุอุปกรณ์'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildLabel(
                                    'สถานที่ (อาคาร / ห้อง)',
                                    isRequired: true,
                                  ),
                                  TextFormField(
                                    controller: _locationDisplayController,
                                    readOnly: true,
                                    onTap: _showLocationPicker,
                                    decoration: _inputDecoration(
                                      hint: 'เช่น อาคาร A ชั้น 2 ห้อง 201',
                                      prefixIcon: Icons.location_on_outlined,
                                    ),
                                    validator: (v) => _selectedRoomId == null
                                        ? 'กรุณาเลือกสถานที่'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildLabel('ความเร่งด่วน'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedUrgency,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'เลือกความเร่งด่วน',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.blue.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    items: _urgencyMap.entries.map((entry) {
                                      return DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedUrgency = val),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ---- Card 2 ----
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    'รายละเอียดปัญหา',
                                    isRequired: true,
                                  ),
                                  TextFormField(
                                    controller: _detailController,
                                    maxLines: 4,
                                    decoration: _inputDecoration(
                                      hint: 'อธิบายอาการเสียเบื้องต้น...',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'กรุณาระบุรายละเอียดปัญหา'
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ---- Card 3 ----
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('รูปภาพประกอบ'),
                                  InkWell(
                                    onTap: _pickImage,
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _selectedImage!,
                                              width: double.infinity,
                                              height: 160,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CustomPaint(
                                            painter: _DashedRectPainter(
                                              color: const Color(0xFFCBD5E1),
                                              strokeWidth: 1.5,
                                              gap: 5.0,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 30,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFEFF6FF,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: Color(0xFF2563EB),
                                                      size: 28,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    'แตะเพื่อเพิ่มรูปภาพ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// ---- Submit ----
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submit,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined, size: 20),
                                label: Text(
                                  _isSubmitting
                                      ? 'กำลังส่ง...'
                                      : 'ส่งข้อมูลแจ้งซ่อม',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600, // 🔥
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// ---- Cancel ----
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF64748B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: const Color(0xFF475569),
                                ),
                                child: const Text(
                                  'ยกเลิก',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600, // 🔥
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// คลาสสำหรับวาดเส้นประรอบกล่องอัปโหลดรูปภาพ
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    Path dashedPath = Path();
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
