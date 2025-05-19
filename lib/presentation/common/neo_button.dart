import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class NeoButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const NeoButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = AppTheme.primaryAccent,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: AppTheme.primaryForeground,
            width: AppTheme.buttonBorderWidth,
          ),
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: AppTheme.primaryForeground,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        transform: _isPressed 
          ? Matrix4.translationValues(4, 4, 0)
          : Matrix4.translationValues(0, 0, 0),
        child: widget.isLoading 
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBackground,
                  strokeWidth: 3,
                ),
              ),
            )
          : Center(child: widget.child),
      ),
    ).animate().scale(
      duration: 100.ms,
      begin: const Offset(1.0, 1.0),
      end: _isPressed 
        ? const Offset(0.98, 0.98) 
        : const Offset(1.0, 1.0),
    );
  }
} 