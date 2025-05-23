import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:magnumopus/core/theme/app_theme.dart';

/// A customizable card component that follows the app's design system
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final double? elevation;
  final GestureTapCallback? onTap;
  final bool animate;
  final bool isLocked;
  final Widget? lockedOverlay;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.elevation,
    this.onTap,
    this.animate = true,
    this.isLocked = false,
    this.lockedOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cardColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16.0),
          border: border ?? Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: elevation != null && elevation! > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation!,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: child,
      ),
    );

    Widget cardWidget = onTap != null
        ? InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(16.0),
            child: cardContent,
          )
        : cardContent;

    // If the card is locked, show a lock overlay
    if (isLocked) {
      cardWidget = Stack(
        children: [
          cardWidget,
          Positioned.fill(
            child: lockedOverlay ?? const _DefaultLockedOverlay(),
          ),
        ],
      );
    }

    // Apply margin
    if (margin != null) {
      cardWidget = Padding(
        padding: margin!,
        child: cardWidget,
      );
    }

    // Apply animations if enabled
    if (animate) {
      return cardWidget
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 20, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
    }

    return cardWidget;
  }
}

/// Default overlay for locked cards
class _DefaultLockedOverlay extends StatelessWidget {
  const _DefaultLockedOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              color: AppTheme.secondaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Premium Content',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 