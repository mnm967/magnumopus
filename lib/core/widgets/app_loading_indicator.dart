import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:magnumopus/core/theme/app_theme.dart';

/// Loading indicator types available in the app
enum LoadingIndicatorType {
  circular,
  linear,
  pulse,
}

/// A customizable loading indicator that follows the app's design system
class AppLoadingIndicator extends StatelessWidget {
  final LoadingIndicatorType type;
  final Color? color;
  final double size;
  final double strokeWidth;
  final String? message;
  final bool overlay;
  final double? value; // For determinate progress (0.0 to 1.0)

  const AppLoadingIndicator({
    super.key,
    this.type = LoadingIndicatorType.circular,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.message,
    this.overlay = false,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? AppTheme.primaryColor;
    
    Widget indicator;
    
    switch (type) {
      case LoadingIndicatorType.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        );
        
      case LoadingIndicatorType.linear:
        indicator = SizedBox(
          width: double.infinity,
          height: 4.0,
          child: LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
          ),
        );
        
      case LoadingIndicatorType.pulse:
        indicator = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: indicatorColor,
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .fadeOut(
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
    }
    
    // If a message is provided, show below the indicator
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppTheme.primaryTextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // If overlay is true, show as a centered overlay on the parent widget
    if (overlay) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: indicator,
        ),
      );
    }
    
    return Center(child: indicator);
  }
}

/// Extension to easily show loading overlays on any widget
extension LoadingOverlayExtension on Widget {
  Widget withLoadingOverlay({
    required bool isLoading,
    Color? backgroundColor,
    Color? indicatorColor,
    String? message,
  }) {
    return Stack(
      children: [
        this,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withOpacity(0.5),
              child: AppLoadingIndicator(
                color: indicatorColor,
                message: message,
                overlay: true,
              ),
            ),
          ),
      ],
    );
  }
} 