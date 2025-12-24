import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Colors.grey.shade500) 
                : null,
          ),
        ),
      ],
    );
  }
}
