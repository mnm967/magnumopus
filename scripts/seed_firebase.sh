#!/bin/bash

# Script to run the Firebase data seeder

echo "================================================"
echo "  Wizard Gift Firebase Data Seeder"
echo "================================================"
echo ""

# Navigate to project root (if script is run from scripts directory)
if [[ $PWD == */scripts ]]; then
    cd ..
fi

# Run the seeder
echo "Running data seeder..."
flutter run -d flutter-tester --target bin/seed_data.dart

echo ""
echo "Script completed. Check output for results." 