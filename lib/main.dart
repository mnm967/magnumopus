import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/services/firebase_service.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/features/onboarding/presentation/onboarding_screen.dart';
import 'package:magnumopus/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:magnumopus/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:magnumopus/data/models/course_model.dart'; // Import Lesson model
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:magnumopus/services/download_service.dart';
import 'package:magnumopus/services/openai_service.dart';
import 'package:magnumopus/core/utils/env.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  final firebaseService = await FirebaseService.init();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Register Hive Adapters
  Hive.registerAdapter(LessonAdapter()); // Register LessonAdapter
  
  // Open Hive boxes
  await Hive.openBox<Lesson>('downloaded_lessons'); // Open box for lessons
  await Hive.openBox<Map>('download_progress'); // Open box for progress tracking
  
  // Initialize FlutterDownloader
  await FlutterDownloader.initialize(
    debug: true, // Set to false in production
    ignoreSsl: true, // Add this for development if needed
  );
  
  // Create and initialize the DownloadService
  final downloadService = DownloadService();
  await downloadService.initialize();
  
  // Initialize OpenAI with API key from environment
  OpenAIService.initialize(Env.openAIApiKey);
  
  // Run the app with ProviderScope to enable Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override the firebaseServiceProvider with the initialized instance
        firebaseServiceProvider.overrideWithValue(firebaseService),
        // Override the downloadServiceProvider with the initialized instance
        downloadServiceProvider.overrideWithValue(downloadService),
      ],
      child: const MagnumOpusApp(),
    ),
  );
}

/// The main app widget
class MagnumOpusApp extends ConsumerWidget {
  const MagnumOpusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if onboarding is complete
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    
    return MaterialApp(
      title: 'Wizard Gift',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Use the global navigator key
      home: onboardingCompleted ? AppRoutes.getHomeScreen() : const OnboardingScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

/// A splash screen for the app
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 60,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // App name
            const Text(
              'Wizard Gift',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trading Education Platform',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
