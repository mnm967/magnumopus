import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magnumopus/data/models/community_model.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart' as user_model;

/// Utility class to generate mock data for the app
class MockDataGenerator {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MockDataGenerator({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Generate all mock data
  Future<void> generateAllMockData() async {
    await generateMockUsers();
    await generateMockCourses();
    await generateMockCommunityChannels();
    await generateMockAIConversations();
    
    // After generating all data, verify it exists
    await debugVerifyData();
  }

  /// Debug method to verify the data was properly created
  Future<void> debugVerifyData() async {
    // Check courses
    try {
      final coursesSnapshot = await _firestore.collection('courses').get();
      debugPrint('VERIFICATION - COURSES COUNT: ${coursesSnapshot.docs.length}');
      for (final doc in coursesSnapshot.docs) {
        debugPrint('VERIFICATION - COURSE: ${doc.id} - ${doc.data()['title']}');
      }
    } catch (e) {
      debugPrint('ERROR VERIFYING COURSES: $e');
    }
    
    // Check categories
    try {
      final categoriesSnapshot = await _firestore.collection('categories').get();
      debugPrint('VERIFICATION - CATEGORIES COUNT: ${categoriesSnapshot.docs.length}');
    } catch (e) {
      debugPrint('ERROR VERIFYING CATEGORIES: $e');
    }
  }

  /// Generate mock users
  Future<void> generateMockUsers() async {
    debugPrint('Generating mock users...');

    // Sample user data
    final mockUsers = [
      {
        'id': 'user1',
        'email': 'trader1@example.com',
        'name': 'Alex Thompson',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'tier': 'elite',
        'isAdmin': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 120))),
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'subscriptionExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 180))),
      },
      {
        'id': 'user2',
        'email': 'trader2@example.com',
        'name': 'Jordan Lee',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'tier': 'advanced',
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 45))),
        'subscriptionExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
      },
      {
        'id': 'user3',
        'email': 'trader3@example.com',
        'name': 'Sam Rivera',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'tier': 'free',
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'subscriptionExpiry': null,
      },
      {
        'id': 'user4',
        'email': 'trader4@example.com',
        'name': 'Taylor Morgan',
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
        'tier': 'free',
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 18))),
        'subscriptionExpiry': null,
      },
      {
        'id': 'user5',
        'email': 'trader5@example.com',
        'name': 'Casey Kim',
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
        'tier': 'advanced',
        'isAdmin': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5))),
        'subscriptionExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 120))),
      },
    ];

    // Add users to Firestore
    final usersCollection = _firestore.collection('users');
    
    for (final user in mockUsers) {
      await usersCollection.doc(user['id'] as String).set(user);
    }

    debugPrint('Generated ${mockUsers.length} mock users');
  }

  /// Generate mock courses and lessons
  Future<void> generateMockCourses() async {
    debugPrint('Generating mock courses...');

    // Create categories
    final mockCategories = [
      {
        'id': 'cat1',
        'name': 'Trading Fundamentals',
        'description': 'Essential knowledge for beginners in trading',
        'order': 1,
      },
      {
        'id': 'cat2',
        'name': 'Technical Analysis',
        'description': 'Learn how to analyze charts and identify patterns',
        'order': 2,
      },
      {
        'id': 'cat3',
        'name': 'Advanced Strategies',
        'description': 'Complex trading strategies for experienced traders',
        'order': 3,
      },
      {
        'id': 'cat4',
        'name': 'Risk Management',
        'description': 'Protect your capital with proper risk management techniques',
        'order': 4,
      },
    ];

    // Create courses
    final mockCourses = [
      {
        'id': 'course1',
        'title': 'Introduction to Trading',
        'description': 'A comprehensive introduction to financial markets and trading basics.',
        'categoryId': 'cat1',
        'tier': 'free',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 8,
        'totalDuration': 4800, // 80 minutes in seconds
        'order': 1,
        'isFeatured': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
      },
      {
        'id': 'course2',
        'title': 'Candlestick Patterns Mastery',
        'description': 'Learn to identify and interpret candlestick patterns for better trading decisions.',
        'categoryId': 'cat2',
        'tier': 'free',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1640340434855-6084b1f4901c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 12,
        'totalDuration': 7200, // 120 minutes in seconds
        'order': 2,
        'isFeatured': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 75))),
      },
      {
        'id': 'course3',
        'title': 'Support and Resistance Trading',
        'description': 'Master the art of trading support and resistance levels.',
        'categoryId': 'cat2',
        'tier': 'advanced',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 10,
        'totalDuration': 6000, // 100 minutes in seconds
        'order': 3,
        'isFeatured': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
      },
      {
        'id': 'course4',
        'title': 'Advanced Chart Patterns',
        'description': 'Recognize and trade complex chart patterns with confidence.',
        'categoryId': 'cat3',
        'tier': 'elite',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1535320903710-d993d3d77d29?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 14,
        'totalDuration': 8400, // 140 minutes in seconds
        'order': 4,
        'isFeatured': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
      },
      {
        'id': 'course5',
        'title': 'Risk Management Essentials',
        'description': 'Learn how to protect your capital and manage risk effectively.',
        'categoryId': 'cat4',
        'tier': 'advanced',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 9,
        'totalDuration': 5400, // 90 minutes in seconds
        'order': 5,
        'isFeatured': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'id': 'course6',
        'title': 'Trading Psychology',
        'description': 'Understand and master the psychological aspects of trading.',
        'categoryId': 'cat1',
        'tier': 'free',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1542744173-05336fcc7ad4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'lessonCount': 7,
        'totalDuration': 4200, // 70 minutes in seconds
        'order': 6,
        'isFeatured': false,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
      },
    ];

    // Create lessons for each course
    final Map<String, List<Map<String, dynamic>>> courseLessons = {
      'course1': [
        {
          'id': 'lesson1_1',
          'title': 'What is Trading?',
          'description': 'An introduction to the concept of trading and financial markets.',
          'videoUrl': 'https://example.com/videos/lesson1_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 600, // 10 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Slides': 'https://example.com/slides/lesson1_1.pdf',
            'Trading Glossary': 'https://example.com/resources/glossary.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
        },
        {
          'id': 'lesson1_2',
          'title': 'Types of Markets',
          'description': 'Learn about the different types of financial markets and their characteristics.',
          'videoUrl': 'https://example.com/videos/lesson1_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 540, // 9 minutes in seconds
          'order': 2,
          'freePreview': true,
          'resources': {
            'Market Types Reference': 'https://example.com/resources/market_types.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 89))),
        },
        {
          'id': 'lesson1_3',
          'title': 'Trading vs. Investing',
          'description': 'Understand the differences between trading and investing approaches.',
          'videoUrl': 'https://example.com/videos/lesson1_3.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 660, // 11 minutes in seconds
          'order': 3,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 88))),
        },
      ],
      'course2': [
        {
          'id': 'lesson2_1',
          'title': 'Introduction to Candlestick Charts',
          'description': "Learn the basics of candlestick charts and why they're valuable for traders.",
          'videoUrl': 'https://example.com/videos/lesson2_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1535320903710-d993d3d77d29?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 720, // 12 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Candlestick Patterns Cheat Sheet': 'https://example.com/resources/candlestick_cheatsheet.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 75))),
        },
        {
          'id': 'lesson2_2',
          'title': 'Basic Candlestick Patterns',
          'description': 'Identify and understand the most common candlestick patterns.',
          'videoUrl': 'https://example.com/videos/lesson2_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1535320903710-d993d3d77d29?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 780, // 13 minutes in seconds
          'order': 2,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 74))),
        },
      ],
      // Adding lessons for course3
      'course3': [
        {
          'id': 'lesson3_1',
          'title': 'Understanding Support and Resistance',
          'description': 'Learn the fundamental concepts of support and resistance in technical analysis.',
          'videoUrl': 'https://example.com/videos/lesson3_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1560221328-12fe60f83ab8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 690, // 11.5 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Support and Resistance Guide': 'https://example.com/resources/support_resistance_guide.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
        },
        {
          'id': 'lesson3_2',
          'title': 'Identifying Key Levels',
          'description': 'How to find and validate important support and resistance levels on any chart.',
          'videoUrl': 'https://example.com/videos/lesson3_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1560221328-12fe60f83ab8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 580, // 9.7 minutes in seconds
          'order': 2,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 59))),
        },
        {
          'id': 'lesson3_3',
          'title': 'Trading the Bounce',
          'description': 'Strategies for trading bounces off support and resistance levels.',
          'videoUrl': 'https://example.com/videos/lesson3_3.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1560221328-12fe60f83ab8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 750, // 12.5 minutes in seconds
          'order': 3,
          'freePreview': false,
          'resources': {
            'Trade Setups PDF': 'https://example.com/resources/bounce_setups.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 58))),
        },
      ],
      // Adding lessons for course4
      'course4': [
        {
          'id': 'lesson4_1',
          'title': 'Advanced Chart Pattern Recognition',
          'description': 'An overview of complex chart patterns and their significance.',
          'videoUrl': 'https://example.com/videos/lesson4_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 840, // 14 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Chart Patterns Reference': 'https://example.com/resources/advanced_patterns.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
        },
        {
          'id': 'lesson4_2',
          'title': 'Head and Shoulders Pattern',
          'description': 'Deep dive into the head and shoulders reversal pattern.',
          'videoUrl': 'https://example.com/videos/lesson4_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 720, // 12 minutes in seconds
          'order': 2,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 44))),
        },
        {
          'id': 'lesson4_3',
          'title': 'Cup and Handle Formation',
          'description': 'How to identify and trade the cup and handle continuation pattern.',
          'videoUrl': 'https://example.com/videos/lesson4_3.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 690, // 11.5 minutes in seconds
          'order': 3,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 43))),
        },
      ],
      // Adding lessons for course5
      'course5': [
        {
          'id': 'lesson5_1',
          'title': 'Risk Management Principles',
          'description': 'Understand the core principles of effective risk management in trading.',
          'videoUrl': 'https://example.com/videos/lesson5_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 630, // 10.5 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Risk Management Framework': 'https://example.com/resources/risk_management.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        },
        {
          'id': 'lesson5_2',
          'title': 'Position Sizing Strategies',
          'description': 'How to determine optimal position sizes for different market conditions.',
          'videoUrl': 'https://example.com/videos/lesson5_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 580, // 9.7 minutes in seconds
          'order': 2,
          'freePreview': false,
          'resources': {
            'Position Size Calculator': 'https://example.com/resources/position_calculator.xlsx',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 29))),
        },
      ],
      // Adding lessons for course6
      'course6': [
        {
          'id': 'lesson6_1',
          'title': 'The Emotional Side of Trading',
          'description': 'Understanding how emotions impact trading decisions and performance.',
          'videoUrl': 'https://example.com/videos/lesson6_1.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1542744173-05336fcc7ad4?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 570, // 9.5 minutes in seconds
          'order': 1,
          'freePreview': true,
          'resources': {
            'Trading Psychology Handbook': 'https://example.com/resources/trading_psychology.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        },
        {
          'id': 'lesson6_2',
          'title': 'Overcoming Fear and Greed',
          'description': 'Techniques to manage the two most powerful emotions in trading.',
          'videoUrl': 'https://example.com/videos/lesson6_2.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1542744173-05336fcc7ad4?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 630, // 10.5 minutes in seconds
          'order': 2,
          'freePreview': false,
          'resources': {},
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 14))),
        },
        {
          'id': 'lesson6_3',
          'title': 'Developing a Trading Journal',
          'description': 'How to create and maintain an effective trading journal to improve performance.',
          'videoUrl': 'https://example.com/videos/lesson6_3.mp4',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1542744173-05336fcc7ad4?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          'duration': 540, // 9 minutes in seconds
          'order': 3,
          'freePreview': false,
          'resources': {
            'Journal Template': 'https://example.com/resources/journal_template.pdf',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 13))),
        },
      ],
    };

    // Sample comments for lessons
    final mockComments = [
      {
        'id': 'comment1',
        'lessonId': 'lesson1_1',
        'userId': 'user2',
        'userName': 'Jordan Lee',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=2',
        'text': 'Great introduction! Really helped me understand the basics.',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
      },
      {
        'id': 'comment2',
        'lessonId': 'lesson1_1',
        'userId': 'user3',
        'userName': 'Sam Rivera',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=3',
        'text': 'I wish there was more detail about forex markets specifically.',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 28))),
      },
      {
        'id': 'comment3',
        'lessonId': 'lesson2_1',
        'userId': 'user5',
        'userName': 'Casey Kim',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=5',
        'text': "The candlestick explanations are really clear. I'm finally understanding what I'm looking at!",
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
      },
    ];

    // Add categories to Firestore
    final categoriesCollection = _firestore.collection('categories');
    for (final category in mockCategories) {
      await categoriesCollection.doc(category['id'] as String).set(category);
    }

    // Add courses to Firestore
    final coursesCollection = _firestore.collection('courses');
    for (final course in mockCourses) {
      await coursesCollection.doc(course['id'] as String).set(course);
    }

    // Add lessons to Firestore
    final lessonsCollection = _firestore.collection('lessons');
    for (final courseId in courseLessons.keys) {
      for (final lesson in courseLessons[courseId]!) {
        await lessonsCollection.doc(lesson['id'] as String).set({
          ...lesson,
          'courseId': courseId,
        });
      }
    }

    // Add comments to Firestore
    final commentsCollection = _firestore.collection('comments');
    for (final comment in mockComments) {
      await commentsCollection.doc(comment['id'] as String).set(comment);
    }

    debugPrint('Generated ${mockCategories.length} categories, ${mockCourses.length} courses, and ${mockComments.length} comments');
  }

  /// Generate mock community channels and messages
  Future<void> generateMockCommunityChannels() async {
    debugPrint('Generating mock community channels...');

    // Sample channels
    final mockChannels = [
      {
        'id': 'channel1',
        'name': 'General Discussion',
        'topic': 'Talk about anything trading related',
        'courseId': null,
        'isPrivate': false,
        'allowedTier': 'free',
        'order': 1,
        'messageCount': 45,
        'lastMessageAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
      },
      {
        'id': 'channel2',
        'name': 'Market Analysis',
        'topic': 'Share and discuss market analysis and trends',
        'courseId': null,
        'isPrivate': false,
        'allowedTier': 'advanced',
        'order': 2,
        'messageCount': 28,
        'lastMessageAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'id': 'channel3',
        'name': 'Elite Strategies',
        'topic': 'Discussion for elite members on advanced trading strategies',
        'courseId': null,
        'isPrivate': true,
        'allowedTier': 'elite',
        'order': 3,
        'messageCount': 15,
        'lastMessageAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'id': 'channel4',
        'name': 'Beginner Questions',
        'topic': 'A safe place to ask any trading questions',
        'courseId': null,
        'isPrivate': false,
        'allowedTier': 'free',
        'order': 4,
        'messageCount': 63,
        'lastMessageAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
      },
      {
        'id': 'channel5',
        'name': 'Trading Psychology',
        'topic': 'Discuss the mental aspects of trading',
        'courseId': 'course6',
        'isPrivate': false,
        'allowedTier': 'free',
        'order': 5,
        'messageCount': 19,
        'lastMessageAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
    ];

    // Sample messages
    final mockMessages = [
      {
        'id': 'msg1',
        'channelId': 'channel1',
        'userId': 'user1',
        'userName': 'Alex Thompson',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=1',
        'text': 'Welcome to the general discussion channel! Feel free to introduce yourself.',
        'type': 'system',
        'replyToMessageId': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
      },
      {
        'id': 'msg2',
        'channelId': 'channel1',
        'userId': 'user2',
        'userName': 'Jordan Lee',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=2',
        'text': "Hi everyone! I'm Jordan, been trading for about 2 years now. Looking forward to learning from you all!",
        'type': 'user',
        'replyToMessageId': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 44))),
      },
      {
        'id': 'msg3',
        'channelId': 'channel1',
        'userId': 'user3',
        'userName': 'Sam Rivera',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=3',
        'text': 'Welcome Jordan! What markets do you primarily trade?',
        'type': 'user',
        'replyToMessageId': 'msg2',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 44, hours: 2))),
      },
      {
        'id': 'msg4',
        'channelId': 'channel4',
        'userId': 'user4',
        'userName': 'Taylor Morgan',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=4',
        'text': 'Can someone explain what a stop-loss is and how to use it effectively?',
        'type': 'user',
        'replyToMessageId': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
      },
      {
        'id': 'msg5',
        'channelId': 'channel4',
        'userId': 'user5',
        'userName': 'Casey Kim',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=5',
        'text': "A stop-loss is an order to sell a security when it reaches a certain price. It's designed to limit an investor's loss on a position. For example, if you buy a stock at \$50 and set a stop-loss at \$45, your broker will sell if the price drops to \$45, limiting your loss to 10%.",
        'type': 'user',
        'replyToMessageId': 'msg4',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10, hours: 1))),
      },
      {
        'id': 'msg6',
        'channelId': 'channel2',
        'userId': 'user1',
        'userName': 'Alex Thompson',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=1',
        'text': 'Has anyone been watching the recent breakout in tech stocks? AAPL and MSFT looking strong on the daily charts.',
        'type': 'user',
        'replyToMessageId': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      },
      {
        'id': 'msg7',
        'channelId': 'channel5',
        'userId': 'bot',
        'userName': 'MagnumAI',
        'userAvatarUrl': null,
        'text': "Remember that managing emotions is key to successful trading. Don't let fear or greed drive your decisions!",
        'type': 'bot',
        'replyToMessageId': null,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
    ];

    // Add channels to Firestore
    final channelsCollection = _firestore.collection('channels');
    for (final channel in mockChannels) {
      await channelsCollection.doc(channel['id'] as String).set(channel);
    }

    // Add messages to Firestore
    final messagesCollection = _firestore.collection('messages');
    for (final message in mockMessages) {
      await messagesCollection.doc(message['id'] as String).set(message);
    }

    debugPrint('Generated ${mockChannels.length} channels and ${mockMessages.length} messages');
  }

  /// Generate mock AI conversations and messages
  Future<void> generateMockAIConversations() async {
    debugPrint('Generating mock AI conversations...');

    // Sample AI conversations
    final mockAIConversations = [
      {
        'id': 'aiconv1',
        'userId': 'user1',
        'title': 'Understanding RSI Indicator',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15, hours: 1))),
      },
      {
        'id': 'aiconv2',
        'userId': 'user2',
        'title': 'Risk Management Strategies',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 8))),
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      },
      {
        'id': 'aiconv3',
        'userId': 'user3',
        'title': 'Analyzing Chart Patterns',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5, hours: 2))),
      },
    ];

    // Sample AI messages
    final mockAIMessages = [
      // Conversation 1
      {
        'id': 'aimsg1_1',
        'conversationId': 'aiconv1',
        'isUserMessage': true,
        'content': 'Can you explain what the RSI indicator is and how to use it in trading?',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15, hours: 2))),
      },
      {
        'id': 'aimsg1_2',
        'conversationId': 'aiconv1',
        'isUserMessage': false,
        'content': "The Relative Strength Index (RSI) is a momentum oscillator that measures the speed and change of price movements. It oscillates between 0 and 100 and is typically used to identify overbought or oversold conditions in a market.\n\nTraditionally, an RSI reading above 70 indicates that an asset may be overbought (potentially overvalued), suggesting a possible price decline. Conversely, an RSI reading below 30 suggests that an asset may be oversold (potentially undervalued), indicating a possible price increase.\n\nTraders use the RSI in several ways:\n\n1. Overbought/oversold signals: Buy when RSI falls below 30 and then rises back above it; sell when RSI rises above 70 and then falls back below it.\n\n2. Divergence: When price makes a new high or low that isn't confirmed by the RSI, it could indicate a potential reversal.\n\n3. Centerline crossovers: Some traders use crosses above 50 as bullish signals and crosses below 50 as bearish signals.\n\nWould you like me to explain any of these concepts in more detail?",
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15, hours: 1, minutes: 55))),
      },
      {
        'id': 'aimsg1_3',
        'conversationId': 'aiconv1',
        'isUserMessage': true,
        'content': "That's helpful! Can you give an example of RSI divergence and how to spot it?",
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15, hours: 1, minutes: 45))),
      },
      {
        'id': 'aimsg1_4',
        'conversationId': 'aiconv1',
        'isUserMessage': false,
        'content': "RSI divergence occurs when the price movement of an asset doesn't match the movement of the RSI indicator. This mismatch can signal a potential trend reversal. There are two types of RSI divergence:\n\n1. Bearish Divergence: This happens when the price makes a new high, but the RSI fails to make a corresponding new high. This suggests weakening momentum despite rising prices, potentially signaling an upcoming downward move.\n\nExample: Imagine a stock that reaches \$100, with an RSI of 75. The price then dips to \$95 before rising to \$105 (a new high). However, the RSI only reaches 70 on this new price high (lower than the previous RSI high of 75). This bearish divergence suggests the uptrend may be losing strength.\n\n2. Bullish Divergence: This occurs when the price makes a new low, but the RSI doesn't make a corresponding new low. This suggests increasing momentum despite falling prices, potentially signaling an upcoming upward move.\n\nExample: A stock drops to \$50 with an RSI of 25. The price rebounds to \$55, then falls to \$48 (a new low). However, the RSI only falls to 28 (higher than the previous RSI low of 25). This bullish divergence suggests the downtrend may be losing strength.\n\nTo spot divergence effectively:\n- Look for established trends first\n- Compare price peaks/troughs with corresponding RSI peaks/troughs\n- Confirm the signal with other indicators or price action\n- Be aware that divergence is more reliable in ranging markets than in strongly trending ones\n\nWould you like me to show how this might look on a chart?",
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15, hours: 1))),
      },

      // Conversation 2
      {
        'id': 'aimsg2_1',
        'conversationId': 'aiconv2',
        'isUserMessage': true,
        'content': 'What are some effective risk management strategies for a beginner trader?',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 8))),
      }
    ];

    // Add AI conversations to Firestore
    final aiConversationsCollection = _firestore.collection('ai_conversations');
    for (final conversation in mockAIConversations) {
      await aiConversationsCollection.doc(conversation['id'] as String).set(conversation);
    }

    // Add AI messages to Firestore
    final aiMessagesCollection = _firestore.collection('ai_messages');
    for (final message in mockAIMessages) {
      await aiMessagesCollection.doc(message['id'] as String).set(message);
    }

    debugPrint('Generated ${mockAIConversations.length} AI conversations and ${mockAIMessages.length} AI messages');
  }
} 