import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NeoCardVariant {
  standard,
  header,
}

class NeoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final NeoCardVariant variant;
  final String? headerTitle;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  
  const NeoCard({
    Key? key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.variant = NeoCardVariant.standard,
    this.headerTitle,
    this.headerLeading,
    this.headerTrailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.primaryBackground,
          border: Border.all(
            color: borderColor ?? AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryForeground.withOpacity(0.7),
              offset: const Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (variant == NeoCardVariant.header) _buildHeader(context),
            Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryAccent,
        border: Border(
          bottom: BorderSide(
            color: borderColor ?? AppTheme.primaryForeground,
            width: AppTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          if (headerLeading != null) ...[
            headerLeading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              headerTitle ?? '',
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (headerTrailing != null) ...[
            const SizedBox(width: 12),
            headerTrailing!,
          ],
        ],
      ),
    );
  }
}

class NeoCardWithHeader extends StatelessWidget {
  final String title;
  final Widget body;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? headerColor;
  final Color? headerTextColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double offset;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NeoCardWithHeader({
    super.key,
    required this.title,
    required this.body,
    this.backgroundColor,
    this.borderColor,
    this.headerColor,
    this.headerTextColor,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.offset = 4.0,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppTheme.primaryBackground;
    final Color brdColor = borderColor ?? AppTheme.primaryForeground;
    final Color hdrColor = headerColor ?? AppTheme.primaryAccent;
    final Color hdrTextColor = headerTextColor ?? AppTheme.primaryBackground;
    
    final Widget cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: brdColor,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: brdColor,
            offset: Offset(offset, offset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hdrColor,
              border: Border(
                bottom: BorderSide(
                  color: brdColor,
                  width: AppTheme.borderWidth,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: hdrTextColor,
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: padding,
              child: body,
            ),
          ),
        ],
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }
    
    return cardWidget;
  }
} 