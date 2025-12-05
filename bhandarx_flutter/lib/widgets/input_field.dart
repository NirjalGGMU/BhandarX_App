// lib/widgets/input_field.dart

import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isPassword;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}