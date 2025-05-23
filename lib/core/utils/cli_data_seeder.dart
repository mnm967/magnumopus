import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magnumopus/core/utils/mock_data_generator.dart';
import 'package:magnumopus/firebase_options.dart';

/// A command line tool for seeding Firebase with mock data
class CliDataSeeder {
  /// Initialize Firebase and populate data
  static Future<void> run() async {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('Initializing mock data generator...');
    final mockDataGenerator = MockDataGenerator(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    
    print('Generating mock data...');
    try {
      // Generate all mock data
      await mockDataGenerator.generateAllMockData();
      print('✅ Mock data successfully populated!');
    } catch (e) {
      print('❌ Error populating mock data: $e');
    }
    
    print('Completed. Press Enter to exit.');
    stdin.readLineSync();
    exit(0);
  }
}

/// Run the seeder if called directly
void main() async {
  await CliDataSeeder.run();
} 