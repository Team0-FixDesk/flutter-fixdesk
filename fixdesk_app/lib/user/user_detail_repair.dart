import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/AppHead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login/login_page.dart';

class UserDetailRepairPage extends StatefulWidget {
  final Map<String, dynamic> repair;
  final int currentTabIndex;
  final Map<String, dynamic>? userData;

  const UserDetailRepairPage({
    super.key,
    required this.repair,
    this.currentTabIndex = 1,
    this.userData,
  });

  @override
  State<UserDetailRepairPage> createState() => _UserDetailRepairPageState();
}

class _UserDetailRepairPageState extends State<UserDetailRepairPage> {
  static const String _repairImageBucket = 'repair-images';

  late final Map<String, dynamic> repair;
  bool isAcceptingRepair = false;

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  @override
  void initState() {
    super.initState();
    repair = Map<String, dynamic>.from(widget.repair);
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'done':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status ?? '-';
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'done':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String urgencyLabel(String? urgency) {
    switch (urgency) {
      case 'high':
        return 'เร่งด่วนมาก';
      case 'medium':
        return 'เร่งด่วน';
      case 'low':
        return 'ปกติ';
      default:
        return urgency ?? '-';
    }
  }

  Color urgencyColor(String? urgency) {
    switch (urgency) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color urgencyBackgroundColor(String? urgency) {
    switch (urgency) {
      case 'high':
        return const Color(0xFFF8D7DA);
      case 'medium':
        return const Color(0xFFFCE8C3);
      case 'low':
        return const Color(0xFFD1F3E0);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  List<String> extractImageUrls() {
    final raw = repair['rf_image'];
    debugPrint('[FixDesk] rf_image raw value: $raw (${raw.runtimeType})');
    final urls = _normalizeImageValue(raw);
    debugPrint('[FixDesk] resolved image URLs: $urls');
    return urls;
  }

  List<String> _normalizeImageValue(dynamic value) {
    if (value == null) return const [];

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return const [];

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _normalizeImageValue(decoded);
        } catch (_) {
          // Fall through to plain string parsing.
        }
      }

      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .map(_resolveImageSource)
            .where((item) => item.isNotEmpty)
            .toList();
      }

      final resolved = _resolveImageSource(trimmed);
      return resolved.isEmpty ? const [] : [resolved];
    }

    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .map(_resolveImageSource)
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String _resolveImageSource(String value) {
    final normalizedValue = value.trim().replaceAll('\\', '/');
    if (normalizedValue.isEmpty) {
      return '';
    }

    if (normalizedValue.startsWith('http://') ||
        normalizedValue.startsWith('https://') ||
        normalizedValue.startsWith('assets/')) {
      return normalizedValue;
    }

    final bucketMarker = '$_repairImageBucket/';
    final bucketIndex = normalizedValue.indexOf(bucketMarker);
    final storagePath = bucketIndex >= 0
        ? normalizedValue.substring(bucketIndex + bucketMarker.length)
        : normalizedValue.startsWith('/')
        ? normalizedValue.substring(1)
        : normalizedValue;

    if (storagePath.isEmpty) {
      return '';
    }

    return Supabase.instance.client.storage
        .from(_repairImageBucket)
        .getPublicUrl(storagePath);
  }

  String locationLabel() {
    final roomData = repair['room'];
    final floorData = roomData is Map ? roomData['floor'] : null;
    final buildingData = floorData is Map ? floorData['building'] : null;

    final building =
        (buildingData is Map
                ? buildingData['bd_name'] ?? ''
                : repair['bd_name'] ?? '')
            .toString()
            .trim();
    final floor =
        (floorData is Map
                ? floorData['fl_name'] ?? ''
                : repair['fl_name'] ?? '')
            .toString()
            .trim();
    final room =
        (roomData is Map
                ? roomData['room_name'] ?? ''
                : repair['room_name'] ?? '')
            .toString()
            .trim();

    final parts = <String>[];
    if (building.isNotEmpty) parts.add(building);
    if (floor.isNotEmpty) parts.add('ชั้น $floor');
    if (room.isNotEmpty) parts.add(room);

    return parts.isEmpty ? '-' : parts.join(' ');
  }

  int currentStepIndex(String? status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'in_progress':
        return 1;
      case 'done':
        return 2;
      default:
        return 0;
    }
  }

  bool get isTechnician {
    final roleId = widget.userData?['us_role_id'];
    if (roleId == 2 || roleId == '2') {
      return true;
    }

    final rawRole =
        widget.userData?['role'] ??
        widget.userData?['us_role_name'] ??
        widget.userData?['user_role'];
    if (rawRole == null) {
      return false;
    }

    final normalizedRole = rawRole.toString().trim().toLowerCase();
    return normalizedRole == 'technician' || normalizedRole == 'ช่าง';
  }

  bool get canAcceptRepair {
    final status = repair['rf_user_status']?.toString();
    return nextStatus(status) != null;
  }

  String? nextStatus(String? status) {
    switch (status) {
      case null:
      case '':
      case 'pending':
        return 'in_progress';
      case 'in_progress':
        return 'done';
      default:
        return null;
    }
  }

  String actionSuccessMessage(String? status) {
    switch (status) {
      case 'in_progress':
        return 'รับงานซ่อมเรียบร้อยแล้ว';
      case 'done':
        return 'เสร็จสิ้นงานเรียบร้อยแล้ว';
      default:
        return 'อัปเดตสถานะเรียบร้อยแล้ว';
    }
  }

  Future<void> acceptRepair() async {
    if (!canAcceptRepair || isAcceptingRepair) {
      return;
    }

    final currentStatus = repair['rf_user_status']?.toString();
    final targetStatus = nextStatus(currentStatus);
    if (targetStatus == null) {
      return;
    }

    final repairId = _asInt(repair['rf_id']);
    if (repairId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบรหัสรายการแจ้งซ่อม')));
      return;
    }

    final technicianId =
        _asInt(widget.userData?['us_tt_id']) ??
        _asInt(widget.userData?['us_id']);
    if (currentStatus == 'pending' && technicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลช่างสำหรับรับงาน')),
      );
      return;
    }

    setState(() {
      isAcceptingRepair = true;
    });

    final success = switch (targetStatus) {
      'in_progress' => await ApiService.acceptRepair(repairId, technicianId!),
      'done' => await ApiService.finishRepair(repairId),
      _ => await ApiService.updateRepairStatus(
        repairId: repairId,
        status: targetStatus,
      ),
    };

    if (!mounted) {
      return;
    }

    setState(() {
      isAcceptingRepair = false;
      if (success) {
        repair['rf_user_status'] = targetStatus;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? actionSuccessMessage(targetStatus)
              : 'ไม่สามารถอัปเดตสถานะได้',
        ),
      ),
    );
  }

  String technicianButtonLabel(String? status) {
    switch (status) {
      case 'in_progress':
        return 'เสร็จสิ้นงาน';
      case 'done':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return 'รับงานซ่อม';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = repair['rf_user_status']?.toString();
    final urgency = repair['rf_urgency']?.toString();
    final images = extractImageUrls();
    final statusAccentColor = statusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                /// 🔵 HEADER (โลโก้ + FixDesk)
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
                        onTap: () =>
                            Navigator.of(context).pop(widget.currentTabIndex),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: const Text(
                          "รายละเอียดแจ้งซ่อม",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// 🔥 ADD CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: urgencyBackgroundColor(urgency),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          urgencyLabel(urgency),
                          style: TextStyle(
                            color: urgencyColor(urgency),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusCard(
                      currentStep: currentStepIndex(status),
                      accentColor: statusAccentColor,
                      isCancelled: status == 'cancelled',
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'ข้อมูลแจ้งซ่อม',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.inventory_2_outlined,
                            label: 'อุปกรณ์',
                            value: (repair['rf_problem'] ?? '-').toString(),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'สถานที่',
                            value: locationLabel(),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _DetailRow(
                            icon: Icons.description_outlined,
                            label: 'รายละเอียดอาการเสีย',
                            value: (repair['rf_detail'] ?? '-').toString(),
                            isMultiline: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'รูปภาพ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (images.isEmpty)
                      Container(
                        width: double.infinity,
                        height: 128,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'ไม่มีรูป',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final imageUrl in images)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RepairImagePreview(imageUrl: imageUrl),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTechnician)
            SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canAcceptRepair && !isAcceptingRepair
                        ? acceptRepair
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isAcceptingRepair
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            technicianButtonLabel(status),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          BottomNavigationBar(
            currentIndex: widget.currentTabIndex,
            onTap: (index) {
              Navigator.of(context).pop(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: 'หน้าแรก',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'รายการ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'โปรไฟล์',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final int currentStep;
  final Color accentColor;
  final bool isCancelled;

  const _StatusCard({
    required this.currentStep,
    required this.accentColor,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final firstColor = isCancelled ? const Color(0xFF3B82F6) : accentColor;
    final secondColor = !isCancelled && currentStep >= 1
        ? accentColor
        : const Color(0xFFE2E8F0);
    final thirdColor = isCancelled
        ? const Color(0xFFEF4444)
        : currentStep >= 2
        ? accentColor
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถานะงาน',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineStep(
                icon: Icons.check_rounded,
                label: 'รับเรื่องแล้ว',
                backgroundColor: firstColor,
                iconColor: Colors.white,
                textColor: firstColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    height: 2,
                    color: !isCancelled && currentStep >= 1
                        ? accentColor
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              _TimelineStep(
                icon: Icons.build_rounded,
                label: 'กำลังดำเนินการ',
                backgroundColor: secondColor,
                iconColor: !isCancelled && currentStep >= 1
                    ? Colors.white
                    : const Color(0xFF94A3B8),
                textColor: !isCancelled && currentStep >= 1
                    ? accentColor
                    : const Color(0xFF94A3B8),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    height: 2,
                    color: isCancelled || currentStep >= 2
                        ? thirdColor
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              _TimelineStep(
                icon: isCancelled
                    ? Icons.close_rounded
                    : Icons.done_all_rounded,
                label: isCancelled ? 'ยกเลิก' : 'เสร็จสิ้น',
                backgroundColor: thirdColor,
                iconColor: isCancelled || currentStep >= 2
                    ? Colors.white
                    : const Color(0xFF94A3B8),
                textColor: isCancelled || currentStep >= 2
                    ? thirdColor
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultiline;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E48D1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairImagePreview extends StatefulWidget {
  final String imageUrl;

  const _RepairImagePreview({required this.imageUrl});

  @override
  State<_RepairImagePreview> createState() => _RepairImagePreviewState();
}

class _RepairImagePreviewState extends State<_RepairImagePreview> {
  static const String _bucket = 'repair-images';

  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _useFallbackNetwork = false;

  bool get _isNetworkUrl =>
      widget.imageUrl.startsWith('http://') ||
      widget.imageUrl.startsWith('https://');

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// Extract the storage file path from either a full URL or a relative path.
  String? _extractStoragePath() {
    final url = widget.imageUrl.trim().replaceAll('\\', '/');
    if (url.isEmpty) return null;

    final marker = '$_bucket/';
    final idx = url.indexOf(marker);
    if (idx >= 0) return url.substring(idx + marker.length);

    // Already a plain filename / relative path.
    if (!url.startsWith('http') && !url.startsWith('assets/')) return url;

    return null;
  }

  Future<void> _loadImage() async {
    final storagePath = _extractStoragePath();
    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        final bytes = await Supabase.instance.client.storage
            .from(_bucket)
            .download(storagePath);
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('[FixDesk] Supabase storage download failed: $e');
      }
    }

    // Fallback: let Image.network try the URL directly.
    if (mounted) {
      setState(() {
        _useFallbackNetwork = true;
        _isLoading = false;
      });
    }
  }

  void _showFullScreen(BuildContext context, {Uint8List? bytes, String? url}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.contain)
                    : Image.network(url!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_imageBytes != null) {
          _showFullScreen(context, bytes: _imageBytes);
        } else if (_isNetworkUrl) {
          _showFullScreen(context, url: widget.imageUrl);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 180,
          color: const Color(0xFFE5E7EB),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Successfully downloaded via Supabase SDK.
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }

    // Fallback: try Image.network with the original URL.
    if (_useFallbackNetwork && _isNetworkUrl) {
      return Image.network(
        widget.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    if (widget.imageUrl.startsWith('assets/')) {
      return Image.asset(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }

    return const _ImageFallback();
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      alignment: Alignment.center,
      child: const Text(
        'ไม่สามารถแสดงรูปภาพได้',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
