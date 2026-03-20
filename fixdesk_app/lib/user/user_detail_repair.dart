import 'package:flutter/material.dart';
import 'package:fixdesk_app/service/api_service.dart';

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
  late final Map<String, dynamic> repair;
  bool isAcceptingRepair = false;

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
    final possibleKeys = [
      'rf_images',
      'images',
      'rf_image_urls',
      'rf_image_url',
      'rf_photo_urls',
      'rf_photo_url',
      'rf_photos',
      'photo_urls',
      'photo_url',
      'image_urls',
      'image_url',
    ];

    for (final key in possibleKeys) {
      final value = repair[key];
      final urls = _normalizeImageValue(value);
      if (urls.isNotEmpty) {
        return urls;
      }
    }

    return const [];
  }

  List<String> _normalizeImageValue(dynamic value) {
    if (value == null) return const [];

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return const [];

      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      return [trimmed];
    }

    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String locationLabel() {
    final building = (repair['bd_name'] ?? '').toString().trim();
    final floor = (repair['fl_name'] ?? '').toString().trim();
    final room = (repair['room_name'] ?? '').toString().trim();

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
    final rawRole =
        widget.userData?['role'] ??
        widget.userData?['us_role_name'] ??
        widget.userData?['user_role'] ??
        widget.userData?['us_role_id'];
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
        return 'เสร็จสิ้นงานเรียบร้อยแล้ว';
      default:
        return 'รับงานซ่อมเรียบร้อยแล้ว';
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

    final repairId = repair['rf_id'];
    if (repairId is! int) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบรหัสรายการแจ้งซ่อม')));
      return;
    }

    setState(() {
      isAcceptingRepair = true;
    });

    final success = await ApiService.updateRepairStatus(
      repairId: repairId,
      status: targetStatus,
    );

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
    final chipColor = urgencyColor(urgency);
    final chipBackgroundColor = urgencyBackgroundColor(urgency);
    final statusAccentColor = statusColor(status);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/LOGO.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FixDesk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 22,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'รายละเอียดแจ้งซ่อม',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#${repair['rf_code'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: chipBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          urgencyLabel(urgency),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: chipColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                        fontSize: 18,
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
                            color: Colors.black.withOpacity(.05),
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
                              color: Colors.black.withOpacity(.05),
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
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final imageUrl in images)
                            _RepairImageTile(imageUrl: imageUrl),
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
            color: Colors.black.withOpacity(.05),
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

class _RepairImageTile extends StatelessWidget {
  final String imageUrl;

  const _RepairImageTile({required this.imageUrl});

  bool get isNetworkImage {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        height: 128,
        color: const Color(0xFFE5E7EB),
        child: isNetworkImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ImageFallback();
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              )
            : imageUrl.startsWith('assets/')
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ImageFallback();
                },
              )
            : const _ImageFallback(),
      ),
    );
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
