import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileInputField extends StatefulWidget {
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
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),

        const SizedBox(height: 6),

        /// INPUT
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? obscure : false,
          enabled: widget.enabled,
          focusNode: widget.focusNode,

          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            prefixIcon: widget.isPassword
                ? const Icon(Icons.lock_outline)
                : null,

            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1E48D1),
                width: 1.5,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
