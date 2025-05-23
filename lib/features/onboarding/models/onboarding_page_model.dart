import 'package:flutter/material.dart';

/// Model for an onboarding page
class OnboardingPage {
  final String title;
  final String description;
  final String imageAsset;
  final Color backgroundColor;
  final Color textColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });
}

/// Static list of onboarding pages for the app
class OnboardingPages {
  static final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Watch Videos Anytime',
      description: 'Access our comprehensive trading education videos anywhere, anytime. Learn at your own pace, whether you\'re at home or on the go.',
      imageAsset: 'assets/images/onboarding1.png',
      backgroundColor: const Color(0xFF345DEE),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Download for Offline Access',
      description: 'Download videos to watch later without internet connection. Never miss out on valuable content, even when you\'re offline.',
      imageAsset: 'assets/images/onboarding2.png',
      backgroundColor: const Color(0xFF2845C3),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Join Our Community',
      description: 'Connect with fellow traders, share insights, and learn from each other in our thriving trading community.',
      imageAsset: 'assets/images/onboarding3.png',
      backgroundColor: const Color(0xFF1A237E),
      textColor: Colors.white,
    ),
    OnboardingPage(
      title: 'Ask Our AI Assistant',
      description: 'Get personalized help with our AI Assistant. Ask questions about trading concepts, get summaries of content, or discuss chart patterns.',
      imageAsset: 'assets/images/onboarding4.png',
      backgroundColor: const Color(0xFF0D47A1),
      textColor: Colors.white,
    ),
  ];
} 