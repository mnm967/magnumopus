import 'package:magnumopus/core/utils/cli_data_seeder.dart';

/// Entry point for the data seeder CLI
void main() async {
  print('🚀 Wizard Gift Firebase Data Seeder');
  print('====================================');
  
  await CliDataSeeder.run();
} 