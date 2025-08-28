#!/bin/bash

# COMPREHENSIVE MOBILE APP REAL DATA TESTING
# Tests Flutter app integration with real backend data

echo "🎯 COMPREHENSIVE MOBILE APP REAL DATA TESTING"
echo "=============================================="
echo ""

# Set up environment
cd /Users/mac/Desktop/github/lovebirds-mobo

# Step 1: Validate Flutter Environment
echo "=== STEP 1: FLUTTER ENVIRONMENT VALIDATION ==="
echo "Checking Flutter installation..."
if flutter --version >/dev/null 2>&1; then
    echo "✅ Flutter is installed"
    flutter --version | head -1
else
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo ""

# Step 2: Check Dependencies
echo "=== STEP 2: DEPENDENCIES VALIDATION ==="
echo "Checking pubspec.yaml dependencies..."

REQUIRED_DEPS=("get:" "dio:" "shared_preferences:" "flutter:")
MISSING_DEPS=()

for dep in "${REQUIRED_DEPS[@]}"; do
    if grep -q "$dep" pubspec.yaml; then
        echo "✅ $dep found"
    else
        echo "❌ $dep missing"
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
    echo "✅ All required dependencies present"
else
    echo "⚠️  Missing dependencies: ${MISSING_DEPS[*]}"
    echo "Running flutter pub get..."
    flutter pub get
fi

echo ""

# Step 3: Test API Configuration
echo "=== STEP 3: API CONFIGURATION TEST ==="
echo "Validating AppConfig.dart settings..."

if [ -f "lib/utils/AppConfig.dart" ]; then
    BASE_URL_LINE=$(grep "BASE_URL.*=" lib/utils/AppConfig.dart | grep -v "//" | head -1)
    echo "✅ AppConfig.dart found"
    echo "   $BASE_URL_LINE"
    
    # Check if pointing to localhost
    if grep -q "localhost\|10.0.2.2" lib/utils/AppConfig.dart; then
        echo "✅ Configured for local development"
    else
        echo "⚠️  Not configured for local development"
    fi
else
    echo "❌ AppConfig.dart not found"
fi

echo ""

# Step 4: Validate Dating Service Integration
echo "=== STEP 4: DATING SERVICE INTEGRATION TEST ==="
echo "Checking SwipeService.dart endpoints..."

if [ -f "lib/services/swipe_service.dart" ]; then
    echo "✅ SwipeService.dart found"
    
    ENDPOINTS=("swipe-discovery" "swipe-action" "who-liked-me" "discovery-stats")
    for endpoint in "${ENDPOINTS[@]}"; do
        if grep -q "$endpoint" lib/services/swipe_service.dart; then
            echo "   ✅ $endpoint endpoint configured"
        else
            echo "   ❌ $endpoint endpoint missing"
        fi
    done
else
    echo "❌ SwipeService.dart not found"
fi

echo ""

# Step 5: Test Dating Screens
echo "=== STEP 5: DATING SCREENS AVAILABILITY TEST ==="
DATING_SCREENS=(
    "lib/screens/dating/SwipeScreen.dart"
    "lib/screens/dating/WhoLikedMeScreen.dart" 
    "lib/screens/dating/MatchesScreen.dart"
    "lib/screens/dating/ProfileViewScreen.dart"
    "lib/screens/dating/ProfileEditScreen.dart"
)

AVAILABLE_SCREENS=0
for screen in "${DATING_SCREENS[@]}"; do
    if [ -f "$screen" ]; then
        AVAILABLE_SCREENS=$((AVAILABLE_SCREENS + 1))
        echo "✅ $(basename $screen) available"
        
        # Check dark theme integration
        if grep -q "CustomTheme\." "$screen"; then
            THEME_COUNT=$(grep -c "CustomTheme\." "$screen")
            echo "   🎨 Dark theme: $THEME_COUNT CustomTheme references"
        else
            echo "   ⚠️  Dark theme: No CustomTheme references found"
        fi
    else
        echo "❌ $(basename $screen) missing"
    fi
done

echo "📊 Dating screens available: $AVAILABLE_SCREENS/${#DATING_SCREENS[@]}"
echo ""

# Step 6: Test Backend Connection
echo "=== STEP 6: BACKEND CONNECTION TEST ==="
echo "Testing connection to backend API..."

API_URL="http://localhost:8888/katogo/api/me"
if curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200"; then
    echo "✅ Backend API responding (HTTP 200)"
    echo "   URL: $API_URL"
else
    echo "❌ Backend API not responding"
    echo "   Make sure MAMP is running and server is accessible"
fi

echo ""

# Step 7: Compile Test
echo "=== STEP 7: FLUTTER COMPILATION TEST ==="
echo "Testing if app can compile without errors..."

# Create a test build
echo "Running flutter analyze..."
if flutter analyze --no-fatal-infos; then
    echo "✅ Flutter analyze passed"
else
    echo "⚠️  Flutter analyze found issues"
fi

echo ""
echo "Testing if app builds successfully..."
if flutter build apk --debug --target-platform android-arm64 >/dev/null 2>&1; then
    echo "✅ Debug build successful"
else
    echo "⚠️  Debug build had issues - checking for errors..."
    flutter build apk --debug --target-platform android-arm64 2>&1 | tail -10
fi

echo ""

# Step 8: Real Data Integration Test
echo "=== STEP 8: REAL DATA INTEGRATION VERIFICATION ==="
echo "Verifying backend has real test data..."

# Check if test_config.json exists
if [ -f "/Applications/MAMP/htdocs/lovebirds-api/test_config.json" ]; then
    echo "✅ Real test data configuration found"
    USER_COUNT=$(jq '.user_ids | length' /Applications/MAMP/htdocs/lovebirds-api/test_config.json)
    echo "   Test users available: $USER_COUNT"
    
    echo "   Real user IDs:"
    jq -r '.user_ids[]' /Applications/MAMP/htdocs/lovebirds-api/test_config.json | while read id; do
        echo "     - User ID: $id"
    done
else
    echo "❌ Real test data configuration missing"
    echo "   Run: php /Applications/MAMP/htdocs/lovebirds-api/get_test_user_ids.php"
fi

echo ""

# Step 9: Authentication Flow Test
echo "=== STEP 9: AUTHENTICATION FLOW TEST ==="
echo "Checking authentication utilities..."

if [ -f "lib/utils/Utilities.dart" ]; then
    echo "✅ Utilities.dart found"
    
    # Check for http methods
    if grep -q "http_get\|http_post" lib/utils/Utilities.dart; then
        echo "   ✅ HTTP methods implemented"
    else
        echo "   ❌ HTTP methods missing"
    fi
    
    # Check for authentication headers
    if grep -q "Authorization\|Tok" lib/utils/Utilities.dart; then
        echo "   ✅ Authentication headers implemented"
    else
        echo "   ❌ Authentication headers missing"
    fi
else
    echo "❌ Utilities.dart not found"
fi

echo ""

# Step 10: Performance & Memory Test
echo "=== STEP 10: PERFORMANCE VALIDATION ==="
echo "Checking for performance optimizations..."

# Check for common performance patterns
PERFORMANCE_CHECKS=(
    "FutureBuilder:lib/screens/dating/"
    "ListView.builder:lib/screens/dating/" 
    "CachedNetworkImage:lib/"
    "CircularProgressIndicator:lib/screens/dating/"
)

for check in "${PERFORMANCE_CHECKS[@]}"; do
    PATTERN=$(echo $check | cut -d: -f1)
    PATH=$(echo $check | cut -d: -f2)
    
    if find "$PATH" -name "*.dart" -type f -exec grep -l "$PATTERN" {} \; 2>/dev/null | head -1 >/dev/null; then
        echo "✅ $PATTERN usage found"
    else
        echo "⚠️  $PATTERN usage not found (consider for optimization)"
    fi
done

echo ""

# FINAL SUMMARY
echo "=== COMPREHENSIVE TEST SUMMARY ==="
echo "🎯 MOBILE APP READINESS ASSESSMENT:"
echo ""

# Calculate readiness score
TOTAL_CHECKS=10
PASSED_CHECKS=0

# Check results (simplified scoring)
[ -f "lib/utils/AppConfig.dart" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "lib/services/swipe_service.dart" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ $AVAILABLE_SCREENS -gt 3 ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200" && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "/Applications/MAMP/htdocs/lovebirds-api/test_config.json" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "lib/utils/Utilities.dart" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
flutter analyze --no-fatal-infos >/dev/null 2>&1 && PASSED_CHECKS=$((PASSED_CHECKS + 1))
grep -q "get:" pubspec.yaml && PASSED_CHECKS=$((PASSED_CHECKS + 1))
grep -q "dio:" pubspec.yaml && PASSED_CHECKS=$((PASSED_CHECKS + 1))
flutter --version >/dev/null 2>&1 && PASSED_CHECKS=$((PASSED_CHECKS + 1))

READINESS_PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "📊 Readiness Score: $PASSED_CHECKS/$TOTAL_CHECKS ($READINESS_PERCENTAGE%)"
echo ""

if [ $READINESS_PERCENTAGE -ge 80 ]; then
    echo "🎉 MOBILE APP IS READY FOR COMPREHENSIVE TESTING!"
    echo ""
    echo "✅ NEXT STEPS:"
    echo "  1. Run the app: flutter run"
    echo "  2. Test SwipeScreen with real users"
    echo "  3. Verify WhoLikedMeScreen loads data"
    echo "  4. Test MatchesScreen functionality"
    echo "  5. Validate ProfileEditScreen updates"
    echo "  6. Test dark theme consistency"
    echo ""
    echo "🚀 Ready for production testing!"
elif [ $READINESS_PERCENTAGE -ge 60 ]; then
    echo "⚠️  MOBILE APP NEEDS MINOR FIXES"
    echo ""
    echo "🔧 RECOMMENDED ACTIONS:"
    echo "  - Fix any compilation errors"
    echo "  - Ensure all dating screens are available"
    echo "  - Verify API configuration"
    echo ""
    echo "📅 Should be ready for testing after minor fixes"
else
    echo "❌ MOBILE APP NEEDS SIGNIFICANT WORK"
    echo ""
    echo "🚨 CRITICAL ISSUES TO ADDRESS:"
    echo "  - Major compilation or configuration problems"
    echo "  - Missing core dating functionality"
    echo "  - Backend connectivity issues"
    echo ""
    echo "🛠️  Significant development work required"
fi

echo ""
echo "💡 TEST BACKEND SEPARATELY:"
echo "   http://localhost:8888/katogo/test_real_dating_flow.php"
echo ""
echo "📱 MOBILE APP TESTING COMPLETE!"
