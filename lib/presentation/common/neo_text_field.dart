import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NeoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const NeoTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.backgroundColor ?? 
        AppTheme.primaryBackground;
    final Color brdColor = widget.borderColor ?? 
        (_isFocused ? AppTheme.primaryAccent : AppTheme.primaryForeground);
    final Color txtColor = widget.textColor ?? 
        AppTheme.primaryForeground;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: brdColor,
          width: AppTheme.borderWidth,
        ),
        boxShadow: _isFocused
            ? []
            : [
                BoxShadow(
                  color: AppTheme.primaryForeground,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        style: TextStyle(
          fontFamily: 'RobotoMono',
          color: txtColor,
          fontSize: 16,
        ),
        cursorColor: AppTheme.primaryAccent,
        cursorWidth: 2.0,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          labelStyle: TextStyle(
            fontFamily: 'RobotoMono',
            color: Colors.grey.shade700,
          ),
          hintStyle: TextStyle(
            fontFamily: 'RobotoMono',
            color: Colors.grey.shade500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 16,
          ),
          border: InputBorder.none,
          counter: widget.maxLength != null
              ? Container()
              : null, // Hide counter if maxLength is provided
        ),
      ),
    );
  }
} 