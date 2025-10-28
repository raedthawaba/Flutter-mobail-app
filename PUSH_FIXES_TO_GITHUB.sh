#!/bin/bash

echo "🔧 دفع إصلاحات البناء إلى GitHub"
echo "=================================="

cd /workspace/Flutter-mobail-app

echo "📋 1. التحقق من git status:"
git status

echo ""
echo "📋 2. عرض آخر كوميت محلياً:"
git log -1 --oneline

echo ""
echo "📋 3. عرض آخر كوميت على البعيد:"
git log -1 origin/main --oneline

echo ""
echo "📤 4. دفع للمستودع البعيد:"
git push origin main

echo ""
echo "🔍 5. التحقق من النتائج:"
echo "محلي:"
git log -1 --oneline
echo "بعيد:"
git log -1 origin/main --oneline

echo ""
echo "✅ انتهى دفع الإصلاحات!"