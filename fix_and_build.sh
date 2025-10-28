#!/bin/bash

# Echo colored text for better visibility
echo "🔧 بدء عملية إصلاح أخطاء البناء..."
echo ""

# Step 1: Pull latest changes
echo "📥 STEP 1: سحب آخر تحديث من GitHub..."
git pull origin main --force
echo ""

# Step 2: Check current commit
echo "📋 STEP 2: التحقق من آخر commit..."
git rev-parse HEAD
echo ""

# Step 3: Clean project
echo "🧹 STEP 3: تنظيف المشروع..."
flutter clean
echo ""

# Step 4: Get dependencies  
echo "📦 STEP 4: جلب الحزم..."
flutter pub get
echo ""

# Step 5: Build APK
echo "🏗️ STEP 5: بناء التطبيق..."
flutter build apk --debug
echo ""

echo "✅ تم الانتهاء من عملية البناء!"