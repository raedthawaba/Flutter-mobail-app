#!/usr/bin/env python3

# حل مشكلة d05d913 - دفع الكوميت المحدث
import subprocess
import os

print("🔧 حل مشكلة كوميت d05d913")
print("=" * 40)

try:
    os.chdir('/workspace/Flutter-mobail-app')
    
    print("📤 دفع الكوميت c1734eb إلى GitHub...")
    
    # الدفع المباشر
    result = subprocess.run(['git', 'push', 'origin', 'main'], 
                          capture_output=True, text=True, timeout=60)
    
    if result.returncode == 0:
        print("✅ تم الدفع بنجاح!")
        
        # تحقق من الالتزامن
        result = subprocess.run(['git', 'log', '-1', 'origin/main', '--oneline'], 
                              capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print(f"🌐 GitHub الآن: {result.stdout.strip()}")
            
            if 'c1734eb' in result.stdout:
                print("🎉 مشكلة d05d913 محلولة!")
            else:
                print("⚠️  GitHub لم يتحديث بعد")
        
    else:
        print(f"❌ فشل الدفع: {result.stderr}")
        
except Exception as e:
    print(f"❌ خطأ: {str(e)}")
    print("\nنفذ هذا الأمر يدوياً:")
    print("cd /workspace/Flutter-mobail-app")
    print("git push origin main")

print("\n" + "=" * 40)
print("🚀 تنفيذ اختبار الدفع...")
print("=" * 40)