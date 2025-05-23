import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:magnumopus/core/theme/app_theme.dart';

/// Button styles available in the app
enum AppButtonStyle {
  primary,
  secondary,
  outline,
  text,
}

/// A customizable button component that follows the app's design system
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 48.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    // Define the button's content
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: _getContentColor(isDisabled)),
        if ((isLoading || icon != null) && label.isNotEmpty)
          const SizedBox(width: 8),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: _getContentColor(isDisabled),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
      ],
    );

    // Apply animations to the button content
    buttonChild = buttonChild.animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 1.5.seconds,
      color: _getShimmerColor(),
    ).animate(target: isLoading ? 1 : 0);

    // Determine the button style based on the provided style enum
    return _buildButton(buttonChild, isDisabled, context);
  }

  Widget _buildButton(Widget child, bool isDisabled, BuildContext context) {
    // Determine the button's appearance based on the style
    switch (style) {
      case AppButtonStyle.primary:
        return _buildElevatedButton(
          child,
          isDisabled,
          AppTheme.primaryColor,
          Colors.white,
        );
      case AppButtonStyle.secondary:
        return _buildElevatedButton(
          child,
          isDisabled,
          AppTheme.secondaryColor,
          Colors.white,
        );
      case AppButtonStyle.outline:
        return _buildOutlinedButton(child, isDisabled);
      case AppButtonStyle.text:
        return _buildTextButton(child, isDisabled);
    }
  }

  Widget _buildElevatedButton(
    Widget child,
    bool isDisabled,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.3),
          disabledForegroundColor: foregroundColor.withOpacity(0.5),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: child,
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .moveY(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildOutlinedButton(Widget child, bool isDisabled) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(
            color: isDisabled
                ? AppTheme.primaryColor.withOpacity(0.3)
                : AppTheme.primaryColor,
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: child,
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 300.ms);
  }

  Widget _buildTextButton(Widget child, bool isDisabled) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: child,
      ),
    ).animate()
        .fadeIn(duration: 300.ms);
  }

  Color _getContentColor(bool isDisabled) {
    switch (style) {
      case AppButtonStyle.primary:
      case AppButtonStyle.secondary:
        return isDisabled ? Colors.white.withOpacity(0.5) : Colors.white;
      case AppButtonStyle.outline:
      case AppButtonStyle.text:
        return isDisabled
            ? AppTheme.primaryColor.withOpacity(0.5)
            : AppTheme.primaryColor;
    }
  }

  Color _getProgressColor() {
    switch (style) {
      case AppButtonStyle.primary:
      case AppButtonStyle.secondary:
        return Colors.white;
      case AppButtonStyle.outline:
      case AppButtonStyle.text:
        return AppTheme.primaryColor;
    }
  }

  Color _getShimmerColor() {
    switch (style) {
      case AppButtonStyle.primary:
        return Colors.white.withOpacity(0.4);
      case AppButtonStyle.secondary:
        return Colors.white.withOpacity(0.4);
      case AppButtonStyle.outline:
      case AppButtonStyle.text:
        return AppTheme.primaryColor.withOpacity(0.4);
    }
  }
} 