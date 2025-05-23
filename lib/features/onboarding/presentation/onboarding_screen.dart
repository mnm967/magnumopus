import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/features/auth/presentation/login_screen.dart';
import 'package:magnumopus/features/onboarding/models/onboarding_page_model.dart';

/// Provider to track onboarding state
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
final currentOnboardingPageProvider = StateProvider<int>((ref) => 0);

/// The onboarding screen shown when users first open the app
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentOnboardingPageProvider);
    final pageController = PageController(initialPage: currentPage);
    
    return Scaffold(
      body: Stack(
        children: [
          // PageView for the onboarding pages
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              ref.read(currentOnboardingPageProvider.notifier).state = index;
            },
            itemCount: OnboardingPages.pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageView(
                page: OnboardingPages.pages[index],
                isActive: index == currentPage,
              );
            },
          ),
          
          // Bottom navigation and indicators
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      OnboardingPages.pages.length,
                      (index) => _buildPageIndicator(index == currentPage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      if (currentPage < OnboardingPages.pages.length - 1)
                        AppButton(
                          label: 'Skip',
                          style: AppButtonStyle.text,
                          onPressed: () => _completeOnboarding(context, ref),
                        ),
                      
                      const Spacer(),
                      
                      // Next or Get Started button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: currentPage < OnboardingPages.pages.length - 1
                            ? AppButton(
                                key: const ValueKey('next'),
                                label: 'Next',
                                style: AppButtonStyle.primary,
                                onPressed: () {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              )
                            : AppButton(
                                key: const ValueKey('getStarted'),
                                label: 'Get Started',
                                style: AppButtonStyle.primary,
                                onPressed: () => _completeOnboarding(context, ref),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(
              delay: 400.ms,
            ).slideY(
              begin: 1.0,
              end: 0.0,
              duration: 500.ms,
              curve: Curves.easeOutQuad,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build a single page indicator dot
  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  // Handle the completion of onboarding
  void _completeOnboarding(BuildContext context, WidgetRef ref) {
    ref.read(onboardingCompletedProvider.notifier).state = true;
    
    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

/// Widget for a single onboarding page
class OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;
  final bool isActive;
  
  const OnboardingPageView({
    super.key,
    required this.page,
    this.isActive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      color: page.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Safe area at the top
          const SizedBox(height: 40),
          
          // Image 
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                page.imageAsset,
                fit: BoxFit.contain,
                width: screenSize.width * 0.5,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback widget if image fails to load
                  return Icon(
                    Icons.image_not_supported_outlined,
                    size: 100,
                    color: page.textColor.withOpacity(0.5),
                  );
                },
              ),
            ),
          ).animate(
            target: isActive ? 1 : 0,
          ).slideX(
            begin: 0.1,
            end: 0.0,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ).fadeIn(
            duration: 500.ms,
          ),
          
          // Text content
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    style: TextStyle(
                      color: page.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    page.description,
                    style: TextStyle(
                      color: page.textColor.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate(
            target: isActive ? 1 : 0,
          ).slideY(
            begin: 0.1,
            end: 0.0,
            duration: 500.ms,
            delay: 200.ms,
            curve: Curves.easeOutQuad,
          ).fadeIn(
            duration: 500.ms,
            delay: 200.ms,
          ),
          
          // Bottom space for navigation controls
          SizedBox(height: screenSize.height * 0.15),
        ],
      ),
    );
  }
} 