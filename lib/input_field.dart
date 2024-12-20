import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final Icon icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool obscureText;
  final bool isPassword;
  final Function()? onVisibilityToggle;

  InputField({
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.obscureText = false,
    this.isPassword = false,
    this.onVisibilityToggle,  Function(dynamic value)? onSaved,  Future<void> Function()? onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword ? obscureText : false,
        decoration: InputDecoration(
          icon: icon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hint,
          fillColor: Colors.grey[50],
          filled: true,
          suffixIcon: isPassword
              ? IconButton(
            onPressed: onVisibilityToggle,
            icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          )
              : null,
        ),
      ),
    );
  }
}
