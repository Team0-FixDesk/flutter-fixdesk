import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool enabled;
  final FocusNode? focusNode;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.enabled = true,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// LABEL
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 6),

        /// ช่อง input
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,

          style: const TextStyle(
            fontSize: 16,
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}