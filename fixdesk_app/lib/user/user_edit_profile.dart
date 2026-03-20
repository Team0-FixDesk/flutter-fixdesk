import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../component/profile_inputField.dart';
import '../widgets/AppHead.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  late TextEditingController usernameController;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  late FocusNode passwordFocus;
  late FocusNode confirmFocus;

  String get firstName => widget.userData['us_first_name_th'] ?? '';

  /// format เบอร์โทรตอนโหลดหน้า
  String formatPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) return phone;

    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(
      text: widget.userData['us_user_name'],
    );

    nameController = TextEditingController(
      text: widget.userData['us_first_name_th'],
    );

    surnameController = TextEditingController(
      text: widget.userData['us_last_name_th'],
    );

    /// format เบอร์โทรตั้งแต่โหลดหน้า
    phoneController = TextEditingController(
      text: formatPhone(widget.userData['us_phone'] ?? ''),
    );

    passwordController = TextEditingController(text: "**********");
    confirmPasswordController = TextEditingController(text: "**********");

    passwordFocus = FocusNode();
    confirmFocus = FocusNode();

    /// clear placeholder เมื่อ focus
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus && passwordController.text == "**********") {
        passwordController.clear();
      }
    });

    confirmFocus.addListener(() {
      if (confirmFocus.hasFocus &&
          confirmPasswordController.text == "**********") {
        confirmPasswordController.clear();
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    String firstName = nameController.text.trim();
    String lastName = surnameController.text.trim();

    /// เอา dash ออกก่อนตรวจ
    String phone = phoneController.text.replaceAll('-', '').trim();

    String password = passwordController.text.trim();
    String confirm = confirmPasswordController.text.trim();

    /// ตรวจเบอร์โทร 10 ตัว
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เบอร์โทรศัพท์ต้องมี 10 หลัก")),
      );
      return;
    }

    Map<String, dynamic> updateData = {
      'us_first_name_th': firstName,
      'us_last_name_th': lastName,
      'us_phone': phone,
    };

    /// ถ้ามีการเปลี่ยน password
    if (password.isNotEmpty && password != "**********") {
      if (password != confirm) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
        return;
      }

      updateData['us_user_pass'] = password;
    }

    await supabase
        .from('users')
        .update(updateData)
        .eq('us_id', widget.userData['us_id']);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("แก้ไขข้อมูลสำเร็จ")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade100,
        child: SafeArea(
          child: Column(
            children: [
              /// HEADER
              AppHeader(name: firstName, showGreeting: false),
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
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "แก้ไขโปรไฟล์",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "แก้ไขโปรไฟล์",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

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
                                controller: usernameController,
                                enabled: false,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "ชื่อ",
                                controller: nameController,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "นามสกุล",
                                controller: surnameController,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "เบอร์โทรศัพท์",
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  PhoneNumberFormatter(),
                                ],
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "รหัสผ่าน",
                                controller: passwordController,
                                isPassword: true,
                                focusNode: passwordFocus,
                              ),

                              const SizedBox(height: 16),

                              ProfileInputField(
                                label: "ยืนยันรหัสผ่าน",
                                controller: confirmPasswordController,
                                isPassword: true,
                                focusNode: confirmFocus,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E48D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "ยืนยันการเปลี่ยน",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

/// format เบอร์โทร
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
