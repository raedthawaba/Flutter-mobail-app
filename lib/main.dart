import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';
import 'services/firebase_database_service.dart';
import 'utils/sample_data_generator.dart';

// دالة اختبار Firebase سريعة
Future<void> _runQuickFirebaseTest() async {
  try {
    print('🚀 بدء اختبار Firebase السريع...');
    final FirebaseDatabaseService firebaseService = FirebaseDatabaseService();

    // اختبار الشهداء المعتمدين
    print('\n1️⃣ اختبار الشهداء المعتمدين...');
    final martyrs = await firebaseService.getAllApprovedMartyrs();
    print('   عدد الشهداء المعتمدين: ${martyrs.length}');
    for (var martyr in martyrs.take(2)) {
      print('   - ${martyr.fullName} (${martyr.status})');
    }

    // اختبار الجرحى المعتمدين  
    print('\n2️⃣ اختبار الجرحى المعتمدين...');
    final injured = await firebaseService.getAllApprovedInjured();
    print('   عدد الجرحى المعتمدين: ${injured.length}');
    for (var injuredPerson in injured.take(2)) {
      print('   - ${injuredPerson.fullName} (${injuredPerson.status})');
    }

    // اختبار|日本ين المعتمدين
    print('\n3️⃣ اختبار|日本ين المعتمدين...');
    final prisoners = await firebaseService.getAllApprovedPrisoners();
    print('   عدد|日本ين المعتمدين: ${prisoners.length}');
    for (var prisoner in prisoners.take(2)) {
      print('   - ${prisoner.fullName} (${prisoner.status})');
    }

    // اختبار البيانات المعلقة
    print('\n4️⃣ اختبار البيانات المعلقة...');
    try {
      final pendingData = await firebaseService.getPendingData();
      print('   البيانات المعلقة: ${pendingData.length}');
      for (var item in pendingData.take(2)) {
        print('   - ${item.data['fullName']} (${item.type})');
      }
    } catch (e) {
      print('   ❌ خطأ في البيانات المعلقة: $e');
    }

    // اختبار المستخدم الحالي
    print('\n5️⃣ اختبار المستخدم الحالي...');
    final currentUser = firebaseService.getCurrentUser();
    if (currentUser != null) {
      print('   المستخدم: ${currentUser.email}');
      // احتاج للحصول على userType من database
      print('   UserType: يمكن الحصول عليه من database');
    } else {
      print('   لم يتم تسجيل دخول');
    }

    print('\n✅ انتهى الاختبار بنجاح!');
    print('📊 ملخص: شهداء(${martyrs.length}) - جرحى(${injured.length}) -|日本ين(${prisoners.length})');

  } catch (e) {
    print('❌ خطأ في الاختبار: $e');
  }
}

void main() async {
  bool firebaseInitialized = false;
  String? initError;
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('=== PALESTINE MARTYR APP STARTING ===');
    print('Flutter initialized successfully');
    
    // معالج الأخطاء العالمي لـ Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      print('=== FLUTTER ERROR CAUGHT ===');
      print('Error: ${details.exception}');
      print('StackTrace: ${details.stack}');
      FlutterError.presentError(details);
    };
    
    // تهيئة Firebase أولاً - هذا مهم!
    try {
      print('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      print('✅ Firebase initialized successfully!');
    } catch (e, stackTrace) {
      print('⚠️ Firebase initialization failed:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      initError = e.toString();
      // لا نتوقف هنا، نستمر بدون Firebase
    }
    
    // تهيئة Firebase Firestore بعد تهيئة Firebase الأساسية
    if (firebaseInitialized) {
      print('Initializing Firebase Firestore...');
      final FirebaseDatabaseService firebaseDbService = FirebaseDatabaseService();
      await firebaseDbService.initializeFirebase();
      print('✅ Firebase Firestore initialized successfully!');
    }
    
    // تهيئة ThemeService
    print('Initializing ThemeService...');
    await ThemeService().initialize();
    print('✅ ThemeService initialized successfully!');
    
    // تشغيل اختبار Firebase سريع
    print('\n🔥 === STARTING QUICK FIREBASE TEST ===\n');
    await _runQuickFirebaseTest();
    print('\n🔥 === FIREBASE TEST COMPLETED ===\n');

    // تشغيل التطبيق
    runApp(PalestineMartyrApp(
      firebaseInitialized: firebaseInitialized,
      initError: initError,
    ));
  } catch (e, stackTrace) {
    print('=== CRITICAL ERROR IN MAIN ===');
    print('Error: $e');
    print('StackTrace: $stackTrace');
    
    // محاولة تشغيل التطبيق بشاشة خطأ بسيطة
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'خطأ حرج في التطبيق',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: 'Error: $e\n\nStackTrace: $stackTrace'));
                  },
                  child: const Text('نسخ معلومات الخطأ'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class PalestineMartyrApp extends StatefulWidget {
  final bool firebaseInitialized;
  final String? initError;
  
  const PalestineMartyrApp({
    Key? key, 
    required this.firebaseInitialized,
    this.initError,
  }) : super(key: key);

  @override
  State<PalestineMartyrApp> createState() => _PalestineMartyrAppState();
}

class _PalestineMartyrAppState extends State<PalestineMartyrApp> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    // عرض شاشة خطأ إذا فشل Firebase
    if (!widget.firebaseInitialized && widget.initError != null) {
      return MaterialApp(
        title: 'Firebase Error',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.error,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'خطأ في تهيئة Firebase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.initError!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.initError!));
                      },
                      child: const Text('نسخ رسالة الخطأ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // التطبيق العادي مع دعم التحديث الديناميكي
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: _themeService.localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              
              // دعم المظهر الديناميكي
              themeMode: themeMode,
              theme: ThemeData(
                primaryColor: AppColors.primaryGreen,
                scaffoldBackgroundColor: AppColors.backgroundLight,
                fontFamily: 'Tajawal',
                brightness: Brightness.light,
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              darkTheme: ThemeData(
                primaryColor: AppColors.primaryGreen,
                scaffoldBackgroundColor: const Color(0xFF121212),
                fontFamily: 'Tajawal',
                brightness: Brightness.dark,
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                cardTheme: CardThemeData(
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              
              // دعم اللغة الديناميكي
              locale: locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}