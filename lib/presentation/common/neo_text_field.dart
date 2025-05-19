import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NeoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool autoFocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  
  const NeoTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.autoFocus = false,
    this.focusNode,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'RobotoMono'),
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      autofocus: autoFocus,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'RobotoMono',
          color: AppTheme.primaryForeground.withOpacity(0.5),
        ),
        errorText: errorText,
        errorStyle: const TextStyle(fontFamily: 'RobotoMono'),
        filled: true,
        fillColor: AppTheme.primaryBackground,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        
        // Neo-brutalist style
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
          borderRadius: BorderRadius.zero, // Sharp corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.primaryAccent,
            width: AppTheme.borderWidth,
          ),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
          borderRadius: BorderRadius.zero,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.primaryAccent,
            width: AppTheme.borderWidth,
          ),
          borderRadius: BorderRadius.zero,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.primaryAccent,
            width: AppTheme.borderWidth,
          ),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
} 