import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class NeoLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;
  final String? message;

  const NeoLoader({
    super.key,
    this.color,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final Color loaderColor = color ?? AppTheme.primaryAccent;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppTheme.primaryBackground,
              border: Border.all(
                color: AppTheme.primaryForeground,
                width: strokeWidth,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(strokeWidth),
              child: _AnimatedSquare(color: loaderColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: AppTheme.primaryForeground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedSquare extends StatelessWidget {
  final Color color;

  const _AnimatedSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        // First animation: Grow and rotate
        ScaleEffect(
          duration: 500.ms,
          begin: const Offset(0.1, 0.1),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeInOut,
        ),
        RotateEffect(
          duration: 500.ms,
          begin: 0,
          end: 0.25,
          curve: Curves.easeInOut,
        ),
        // Second animation: Shrink and rotate
        ScaleEffect(
          duration: 500.ms,
          delay: 500.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.1, 0.1),
          curve: Curves.easeInOut,
        ),
        RotateEffect(
          duration: 500.ms,
          delay: 500.ms,
          begin: 0.25,
          end: 0.5,
          curve: Curves.easeInOut,
        ),
        // Loop the animation
        CustomEffect(
          duration: 0.ms,
          delay: 1000.ms,
          builder: (_, value, child) => child!,
          begin: 0,
          end: 1,
        ),
      ],
      autoPlay: true,
      onComplete: (controller) => controller.repeat(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: AppTheme.primaryForeground,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class NeoPageLoader extends StatelessWidget {
  final String? message;

  const NeoPageLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.primaryBackground.withOpacity(0.7),
      child: NeoLoader(
        message: message,
      ),
    );
  }
}

class NeoButtonLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const NeoButtonLoader({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color loaderColor = color ?? AppTheme.primaryBackground;
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: loaderColor,
        strokeWidth: 3,
      ),
    );
  }
} 