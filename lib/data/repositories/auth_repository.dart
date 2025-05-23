import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/services/firebase_service.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/data/models/user_model.dart' as model;

/// Provider for the authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthRepository(firebaseService);
});

/// Repository for handling authentication
class AuthRepository {
  final FirebaseService _firebaseService;
  
  AuthRepository(this._firebaseService);
  
  FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  /// Get the currently logged in user
  Stream<model.User?> get currentUser {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists && userDoc.data() != null) {
          // Convert Firestore data to User model
          // We're simulating this since code gen isn't run yet
          final data = userDoc.data()!;
          return model.User(
            id: firebaseUser.uid,
            email: data['email'] as String? ?? firebaseUser.email ?? '',
            name: data['name'] as String? ?? firebaseUser.displayName ?? 'User',
            avatarUrl: data['avatarUrl'] as String?,
            tier: _parseTier(data['tier']),
            subscriptionExpiry: _parseTimestamp(data['subscriptionExpiry']),
            isAdmin: data['isAdmin'] as bool? ?? false,
            createdAt: _parseTimestamp(data['createdAt']),
            lastSeen: _parseTimestamp(data['lastSeen']),
          );
        }
        
        // If user auth exists but no Firestore document yet, create one
        final newUser = model.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        
        // Store the new user in Firestore
        await _createUserDocument(newUser);
        
        return newUser;
      } catch (e, stack) {
        AppLogger.error('Error getting user data', e, stack);
        return null;
      }
    });
  }
  
  /// Register a new user with email and password
  Future<model.User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user account');
      }
      
      // Update display name
      await firebaseUser.updateDisplayName(name);
      
      // Create user in Firestore
      final newUser = model.User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      
      await _createUserDocument(newUser);
      
      return newUser;
    } catch (e, stack) {
      AppLogger.error('Error registering user', e, stack);
      rethrow;
    }
  }
  
  /// Login with email and password
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in with email: $email');
      
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      AppLogger.info('Sign in successful, user: ${result.user?.uid ?? 'null'}');
      
      // Update last seen timestamp
      final user = _auth.currentUser;
      if (user != null) {
        AppLogger.info('Updating last seen for user: ${user.uid}');
        await _firestore.collection('users').doc(user.uid).set({
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        AppLogger.info('Firestore lastSeen update completed for user: ${user.uid}');
      } else {
        AppLogger.warning('Firebase user is null after successful login');
      }
    } catch (e, stack) {
      AppLogger.error('Error logging in', e, stack);
      rethrow;
    }
  }
  
  /// Force refresh of the current user data
  Future<model.User?> refreshCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        return null;
      }
      
      final data = userDoc.data()!;
      return model.User(
        id: user.uid,
        email: data['email'] as String? ?? user.email ?? '',
        name: data['name'] as String? ?? user.displayName ?? 'User',
        avatarUrl: data['avatarUrl'] as String?,
        tier: _parseTier(data['tier']),
        subscriptionExpiry: _parseTimestamp(data['subscriptionExpiry']),
        isAdmin: data['isAdmin'] as bool? ?? false,
        createdAt: _parseTimestamp(data['createdAt']),
        lastSeen: _parseTimestamp(data['lastSeen']),
      );
    } catch (e, stack) {
      AppLogger.error('Error refreshing current user', e, stack);
      return null;
    }
  }
  
  /// Log out the current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      AppLogger.error('Error logging out', e, stack);
      rethrow;
    }
  }
  
  /// Check if user email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  
  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e, stack) {
      AppLogger.error('Error sending email verification', e, stack);
      rethrow;
    }
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stack) {
      AppLogger.error('Error sending password reset', e, stack);
      rethrow;
    }
  }
  
  /// Update the user's profile information
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      final updates = <String, dynamic>{};
      
      if (name != null) {
        await user.updateDisplayName(name);
        updates['name'] = name;
      }
      
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
        updates['avatarUrl'] = avatarUrl;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e, stack) {
      AppLogger.error('Error updating profile', e, stack);
      rethrow;
    }
  }
  
  // Helper methods
  
  /// Create a new user document in Firestore
  Future<void> _createUserDocument(model.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'avatarUrl': user.avatarUrl,
        'tier': user.tier.toString().split('.').last,
        'isAdmin': user.isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      AppLogger.error('Error creating user document', e, stack);
      rethrow;
    }
  }
  
  /// Parse subscription tier from Firestore
  model.SubscriptionTier _parseTier(dynamic value) {
    if (value == null) return model.SubscriptionTier.free;
    
    switch (value.toString().toLowerCase()) {
      case 'advanced':
        return model.SubscriptionTier.advanced;
      case 'elite':
        return model.SubscriptionTier.elite;
      default:
        return model.SubscriptionTier.free;
    }
  }
  
  /// Parse Firestore timestamp to DateTime
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    return null;
  }
} 