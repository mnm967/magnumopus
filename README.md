# Magnum Opus - Trading Education Platform

A modern mobile application for trading education, built with Flutter, Firebase, and Riverpod.

## Overview

Magnum Opus is a comprehensive trading education platform that provides:
- Video-based courses with organized trading content
- Community interaction for traders to share insights
- AI-powered assistants for learning support
- Premium subscription tiers with exclusive content

## Tech Stack

- **Frontend**: Flutter with a clean, modern UI
- **State Management**: Riverpod (hooks_riverpod)
- **Backend**: Firebase (Authentication, Firestore, Storage, Functions)
- **AI Integration**: OpenAI for content summarization and chat assistance
- **Animations**: flutter_animate for smooth, engaging transitions

## Project Architecture

The project follows a feature-first directory structure with a clean architecture approach:

```
lib/
├── core/               # Core utilities and widgets
│   ├── services/       # Firebase and other service integrations
│   ├── theme/          # App theme and styling
│   ├── utils/          # Utility functions
│   └── widgets/        # Reusable UI components
├── data/               # Data layer
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── features/           # Feature modules
│   ├── ai_assistant/   # AI chat assistant
│   ├── auth/           # Authentication screens
│   ├── community/      # Community chat functionality
│   ├── courses/        # Course listing and playback
│   ├── home/           # Main navigation hub
│   ├── onboarding/     # First-time user experience
│   └── profile/        # User profile management
└── main.dart           # Application entry point
```

## Key Features

### Authentication
- User registration and login
- Forgot password functionality
- Profile management

### Courses
- Video-based educational content
- Categorized courses by topic
- Progress tracking
- Lesson comments and discussion

### Community
- Community chat channels
- Private and public discussions
- Tier-based channel access

### AI Assistant
- Content summarization with AI
- Trading chart analysis
- Conversational AI for learning support
- Personalized trading advice

### Subscription Tiers
- Free tier with limited access
- Advanced tier with additional features
- Elite tier with exclusive content and mentoring

## Implemented Screens

1. **Onboarding**: Introduction to app features
2. **Authentication**: Login, Register, Forgot Password
3. **Home**: Main navigation hub with bottom tabs
4. **Courses**: Course listing and categorization
5. **Course Detail**: Lessons and course information
6. **Lesson Player**: Video player and lesson content
7. **Community**: Chat channels and discussions
8. **AI Assistant**: Conversational AI support
9. **Profile**: User info and subscription management

## Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher
- Firebase project set up

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/magnumopus.git
cd magnumopus
```

2. Install dependencies
```
flutter pub get
```

3. Run the app
```
flutter run
```

## Mock Data Generation

The app includes functionality to populate Firebase with mock data for development and testing purposes. You can generate mock data in two ways:

### 1. Using the in-app button

1. Run the app
2. Navigate to the Courses screen (home screen)
3. Tap the dataset icon (📊) in the app bar
4. Wait for the confirmation message

### 2. Using the command line script

For a headless approach, you can use the provided CLI tool:

```bash
# Make the script executable (first time only)
chmod +x scripts/seed_firebase.sh

# Run the script
./scripts/seed_firebase.sh
```

Alternatively, you can run the script directly with Flutter:

```bash
flutter run -d flutter-tester --target bin/seed_data.dart
```

## Mock Data Details

The generated mock data includes:

- **Users**: 5 sample users with different subscription tiers
- **Courses**: 6 courses across 4 categories with sample lessons
- **Community**: 5 channels with sample messages
- **AI Conversations**: Sample AI chat history

## Future Improvements

- Implement video player with advanced controls
- Add real-time chat functionality
- Integrate with a payment provider for subscriptions
- Implement offline content access
- Add social sharing features
- Expand AI capabilities for more personalized learning

## License

This project is proprietary and confidential.

## Credits

Developed for One Lance B's Magnum Opus platform.
