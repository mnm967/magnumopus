import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/firebase_options.dart';

/// Provider for Firebase service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  throw UnimplementedError('Firebase Service must be initialized first');
});

/// A service that encapsulates all Firebase-related functionality
class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseFunctions functions;
  final FirebaseMessaging messaging;

  FirebaseService({
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.functions,
    required this.messaging,
  });

  /// Initialize Firebase and return a FirebaseService
  static Future<FirebaseService> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      final functions = FirebaseFunctions.instance;
      final messaging = FirebaseMessaging.instance;

      // Setup persistence for better offline experience
      // await firestore.enablePersistence(
      //   const PersistenceSettings(synchronizeTabs: true),
      // );
      firestore.settings = const Settings(persistenceEnabled: true);

      // Request notification permissions (iOS only, Android doesn't need this)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      AppLogger.info('Firebase services initialized successfully');

      return FirebaseService(
        auth: auth,
        firestore: firestore,
        storage: storage,
        functions: functions,
        messaging: messaging,
      );
    } catch (e, stack) {
      AppLogger.error('Error initializing Firebase', e, stack);
      rethrow;
    }
  }

  /// Check if a user is currently signed in
  bool get isUserSignedIn => auth.currentUser != null;

  /// Get the current user
  User? get currentUser => auth.currentUser;

  /// Get a Firestore collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  /// Get a Firestore document reference
  DocumentReference<Map<String, dynamic>> document(String path) {
    return firestore.doc(path);
  }

  /// Get a Storage reference
  Reference storageRef(String path) {
    return storage.ref(path);
  }

  /// Call a cloud function
  Future<dynamic> callFunction(String name, [Map<String, dynamic>? parameters]) async {
    try {
      final callable = functions.httpsCallable(name);
      final result = await callable.call(parameters ?? {});
      return result.data;
    } catch (e, stack) {
      AppLogger.error('Error calling function $name', e, stack);
      rethrow;
    }
  }

  /// Subscribe to a Firebase Messaging topic
  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
    AppLogger.info('Subscribed to FCM topic: $topic');
  }

  /// Unsubscribe from a Firebase Messaging topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
    AppLogger.info('Unsubscribed from FCM topic: $topic');
  }
} 