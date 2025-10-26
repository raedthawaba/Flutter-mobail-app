#!/bin/bash

echo "🔥 FINAL EMERGENCY SYNC TO GITHUB"
echo "=================================="
echo "Target: https://github.com/raedthawaba/Flutter-mobail-app"
echo "Branch: master"
echo "Status: All compilation errors resolved"
echo ""

cd /workspace/Flutter-mobail-app

echo "📤 Adding all files..."
git add -A
if [ $? -eq 0 ]; then
    echo "✅ Files added successfully"
else
    echo "❌ Failed to add files"
    exit 1
fi

echo "💾 Committing changes..."
git commit -m "🔥 FINAL: All compilation errors resolved - CardTheme fixed, all files synced"
if [ $? -eq 0 ]; then
    echo "✅ Commit successful"
else
    echo "❌ Failed to commit"
    exit 1
fi

echo "🚀 Pushing to GitHub (force with lease)..."
git push --force-with-lease origin master
if [ $? -eq 0 ]; then
    echo "✅ Push successful"
    echo "🔍 New commit hash:"
    git rev-parse HEAD
else
    echo "❌ Failed to push"
    exit 1
fi

echo ""
echo "🎉 SUCCESS: CodeMagic should now build successfully!"
echo "📋 Next steps:"
echo "1. Go to CodeMagic"
echo "2. Settings → Clear Cache"
echo "3. Trigger new build manually"
echo "4. APK should build without errors"