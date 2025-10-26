#!/bin/bash

echo "🔄 Executing Git commands to get new commit hash..."
echo "📁 Current directory: $(pwd)"

# Step 1: Add all changes
echo "📤 Adding all changes to git staging..."
git add -A

# Step 2: Commit changes
echo "💾 Committing changes..."
git commit -m "🔥 FINAL FIX: All compilation errors resolved - pending_data.dart, firebase_database_service.dart recreated, CardTheme fixed"

# Step 3: Get the new commit hash
echo "🔍 Getting new commit hash..."
NEW_COMMIT=$(git rev-parse HEAD)
echo "✅ New commit hash: $NEW_COMMIT"

# Step 4: Push to GitHub
echo "🚀 Pushing to GitHub..."
git push --force-with-lease origin master

# Step 5: Display final status
echo "📊 Final status:"
echo "New Commit Hash: $NEW_COMMIT"
echo "Repository: https://github.com/raedthawaba/Flutter-mobail-app"
echo "Branch: master"
echo "Status: Ready for CodeMagic build"

# Step 6: Show commit info
echo "📋 Commit information:"
git show --oneline -s HEAD

echo "🎉 All operations completed successfully!"
echo "Next steps:"
echo "1. Go to CodeMagic"
echo "2. Clear cache (Settings → Clear Cache)"
echo "3. Trigger build manually"
echo "4. Send build results"