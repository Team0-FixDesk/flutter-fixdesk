import 'package:flutter/material.dart';
import '../component/profile_inputField.dart';
import 'tech_edit_profile.dart';

class TechMyProfile extends StatelessWidget {
  final Map<String, dynamic> userData;

  const TechMyProfile({super.key, required this.userData});

  String get firstName => userData['us_first_name_th'] ?? '';
  String get lastName => userData['us_last_name_th'] ?? '';
  String get userName => userData['us_user_name'] ?? '';
  String get phone => formatPhone(userData['us_phone'] ?? '');

  /// format phone 088-888-8888
  static String formatPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) return phone;

    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade100,
        child: SafeArea(
          child: Column(
            children: [

              /// ================= HEADER =================
              Container(
                padding: const EdgeInsets.fromLTRB(12, 20, 20, 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Image.asset(
                          'assets/images/LOGO.png',
                          width: 40,
                          height: 40,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "FixDesk",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "สวัสดี คุณ$firstName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "ยินดีต้อนรับสู่ FixDesk",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= CONTENT =================
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "โปรไฟล์",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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

                              ProfileInputField(
                                label: "ชื่อผู้ใช้งาน",
                                controller: TextEditingController(text: userName),
                                enabled: false,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "ชื่อ",
                                controller: TextEditingController(text: firstName),
                                enabled: false,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "นามสกุล",
                                controller: TextEditingController(text: lastName),
                                enabled: false,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "เบอร์โทรศัพท์",
                                controller: TextEditingController(text: phone),
                                enabled: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TechEditProfilePage(userData: userData),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFF64748B),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "แก้ไขโปรไฟล์",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
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
      ),
    );
  }
}