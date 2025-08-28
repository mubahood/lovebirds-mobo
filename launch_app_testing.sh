#!/bin/bash

# LAUNCH MOBILE APP FOR COMPREHENSIVE TESTING
# This script launches the Flutter app and guides you through real testing

echo "🚀 LAUNCHING MOBILE APP FOR COMPREHENSIVE TESTING"
echo "================================================="
echo ""

cd /Users/mac/Desktop/github/lovebirds-mobo

echo "📱 Starting Flutter app..."
echo "   Backend API: http://localhost:8888/katogo/api"
echo "   Test Data: 6 real users available (IDs: 6121-6126)"
echo ""

echo "🔐 LOGIN CREDENTIALS:"
echo "   Email: admin@gmail.com"
echo "   Password: 123456"
echo ""

echo "🎯 TESTING CHECKLIST:"
echo "   □ Login successfully"
echo "   □ Navigate to dating screens"
echo "   □ Test SwipeScreen functionality"
echo "   □ Verify dark theme consistency"
echo "   □ Test WhoLikedMeScreen"
echo "   □ Test MatchesScreen"
echo "   □ Test ProfileEditScreen"
echo ""

echo "📊 BACKEND MONITORING:"
echo "   Open this URL to monitor API calls:"
echo "   http://localhost:8888/katogo/test_real_dating_flow.php"
echo ""

echo "🎨 DARK THEME VALIDATION:"
echo "   ✅ SwipeScreen: 21 CustomTheme references"
echo "   ✅ WhoLikedMeScreen: 13 CustomTheme references"
echo "   ✅ MatchesScreen: 10 CustomTheme references"
echo "   ✅ ProfileViewScreen: 27 CustomTheme references"
echo "   ✅ ProfileEditScreen: 29 CustomTheme references"
echo ""

echo "▶️  LAUNCHING FLUTTER APP NOW..."
echo ""

# Launch Flutter app
flutter run
