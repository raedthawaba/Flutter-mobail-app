import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';
import '../services/firebase_database_service.dart';
// removed: import '../utils/sample_data_generator.dart';
import 'login_screen.dart';
import 'admin_martyrs_management_screen.dart';
import 'admin_injured_management_screen.dart';
import 'admin_prisoners_management_screen.dart';
import 'admin_users_management_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_approval_screen.dart';
import 'add_martyr_screen.dart';
import 'add_injured_screen.dart';
import 'add_prisoner_screen.dart';
import 'advanced_search_screen.dart';
import 'favorites_screen.dart';
import 'statistics_screen.dart';
import 'backup_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  // removed: final SampleDataGenerator _sampleDataGenerator = SampleDataGenerator();
  
  String? _adminName;
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  // removed: bool _isGeneratingData = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final adminName = await _authService.getCurrentUserName();
      
      // جلب البيانات من قاعدة بيانات Firebase
      final FirebaseDatabaseService dbService = FirebaseDatabaseService();
      final firebaseStats = await dbService.getStatistics();
      
      print('📊 إحصائيات Firebase: $firebaseStats');
      
      if (mounted) {
        setState(() {
          _adminName = adminName;
          _statistics = firebaseStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(AppConstants.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.primaryWhite,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // removed: _generateSampleData() function

  void _navigateToManagement(String section) {
    Widget? targetScreen;
    
    switch (section) {
      case 'الشهداء':
        targetScreen = const AdminMartyrsManagementScreen();
        break;
      case 'الجرحى':
        targetScreen = const AdminInjuredManagementScreen();
        break;
      case 'الأسرى':
        targetScreen = const AdminPrisonersManagementScreen();
        break;
      case 'المستخدمين':
        targetScreen = const AdminUsersManagementScreen();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('سيتم إضافة شاشة إدارة $section قريباً'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
    }
    
    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد اتجاه النص حسب اللغة الحالية
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم الإدارية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryWhite,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        elevation: 4,
        leading: !isRtl ? Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
              color: AppColors.primaryWhite,
            ),
            tooltip: 'القائمة الجانبية',
          ),
        ) : Builder(
          builder: (context) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: AppColors.primaryWhite,
                ),
                tooltip: 'الإعدادات',
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.primaryWhite,
                ),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
        ),
        actions: [
          if (isRtl) Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(
                Icons.menu,
                color: AppColors.primaryWhite,
              ),
              tooltip: 'القائمة الجانبية',
            ),
          ),
          if (!isRtl) ...[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.settings,
                color: AppColors.primaryWhite,
              ),
              tooltip: 'الإعدادات',
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout,
                color: AppColors.primaryWhite,
              ),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ],
      ),
      drawer: !isRtl ? _buildDrawer() : null,
      endDrawer: isRtl ? _buildDrawer() : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.primaryWhite,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // ترحيب بالمسؤول
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                              size: 48,
                              color: AppColors.primaryWhite,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'مرحباً ${_adminName ?? "المسؤول"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'لوحة التحكم الإدارية - إدارة ومراجعة البيانات',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // بطاقات الإحصائيات الأساسية
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'الشهداء',
                              count: _statistics['martyrs'] ?? 0,
                              icon: Icons.person_off_outlined,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'الجرحى',
                              count: _statistics['injured'] ?? 0,
                              icon: Icons.healing_outlined,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'الأسرى',
                              count: _statistics['prisoners'] ?? 0,
                              icon: Icons.lock_person_outlined,
                              color: AppColors.earthBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'قيد المراجعة',
                              count: _statistics['pending'] ?? 0,
                              icon: Icons.pending_outlined,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // بطاقات الميزات المميزة
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              title: 'المفضلة',
                              subtitle: 'عناصر مختارة',
                              icon: Icons.favorite,
                              color: const Color(0xFFE91E63),
                              count: 0, // سيتم جلب العدد الحقيقي لاحقاً
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FavoritesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              title: 'البحث',
                              subtitle: 'بحث متقدم',
                              icon: Icons.search,
                              color: const Color(0xFF2196F3),
                              count: 0,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdvancedSearchScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              title: 'الإحصائيات',
                              subtitle: 'تحليلات ذكية',
                              icon: Icons.analytics,
                              color: const Color(0xFF9C27B0),
                              count: 0,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatisticsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              title: 'النسخ الاحتياطي',
                              subtitle: 'حماية البيانات',
                              icon: Icons.backup,
                              color: const Color(0xFF607D8B),
                              count: 0,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BackupScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // زر فتح القائمة الجانبية
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.menu,
                              size: 48,
                              color: AppColors.primaryWhite,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'اضغط على القائمة الجانبية لإدارة البيانات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'إدارة الشهداء والجرحى والأسرى والمستخدمين والإعدادات',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (isRtl) {
                                  Scaffold.of(context).openEndDrawer();
                                } else {
                                  Scaffold.of(context).openDrawer();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryWhite,
                                foregroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'فتح القائمة الجانبية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // removed: test data generation card

                      const SizedBox(height: 32),

                      // ملاحظة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'أنت مسجل دخول كمسؤول. يمكنك مراجعة وإدارة جميع البيانات المرسلة.',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
    );
  }

  Widget _buildDrawer() {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Drawer(
        width: 300,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : AppColors.primaryWhite,
          ),
          child: Column(
            children: [
              // رأس القائمة - تصميم مطابق للصورة تماماً
              _buildDrawerHeader(isDark),
              
              // العناصر الرئيسية للقائمة
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // قسم عنوان الإضافة السريعة
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة جديدة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // إضافة شهيد
                    _buildMenuItem(
                      title: 'إضافة شهيد',
                      subtitle: 'إضافة وتوثيق بيانات شهيد',
                      icon: Icons.person_off_outlined,
                      color: const Color(0xFF8B0000),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToAddForm(AppConstants.sectionMartyrs);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // إضافة جريح
                    _buildMenuItem(
                      title: 'إضافة جريح',
                      subtitle: 'إضافة وتوثيق بيانات جريح',
                      icon: Icons.medical_services_outlined,
                      color: const Color(0xFFD2691E),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToAddForm(AppConstants.sectionInjured);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // إضافة أسير
                    _buildMenuItem(
                      title: 'إضافة أسير',
                      subtitle: 'إضافة وتوثيق بيانات أسير',
                      icon: Icons.lock_person_outlined,
                      color: const Color(0xFF708090),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToAddForm(AppConstants.sectionPrisoners);
                      },
                    ),
                    
                    // فاصل
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF4CAF50),
                          ],
                        ),
                      ),
                    ),
                    
                    // قسم الميزات المميزة
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars_outlined,
                            color: Color(0xFFFF6F00),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الميزات المميزة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6F00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // البحث المتقدم
                    _buildMenuItem(
                      title: 'البحث المتقدم',
                      subtitle: 'بحث ذكي مع فلاتر متقدمة',
                      icon: Icons.search,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdvancedSearchScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // المفضلة السريع
                    _buildMenuItem(
                      title: 'المفضلة السريع',
                      subtitle: 'وصول سريع للعناصر المهمة',
                      icon: Icons.favorite,
                      color: const Color(0xFFE91E63),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // الإحصائيات والتحليلات
                    _buildMenuItem(
                      title: 'الإحصائيات والتحليلات',
                      subtitle: 'تقارير مرئية ورؤى ذكية',
                      icon: Icons.analytics,
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // النسخ الاحتياطي الذكي
                    _buildMenuItem(
                      title: 'النسخ الاحتياطي',
                      subtitle: 'حماية ذكية ونسخ احتياطية تلقائية',
                      icon: Icons.backup,
                      color: const Color(0xFF607D8B),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupScreen(),
                          ),
                        );
                      },
                    ),
                    
                    // فاصل
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF2E7D32),
                          ],
                        ),
                      ),
                    ),
                    
                    // قسم عنوان الإدارة
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إدارة البيانات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // إدارة الشهداء
                    _buildMenuItem(
                      title: 'إدارة الشهداء',
                      subtitle: 'مراجعة وتوثيق بيانات الشهداء',
                      icon: Icons.person_off_outlined,
                      color: const Color(0xFF8B0000), // Dark red like screenshot
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToManagement('الشهداء');
                      },
                    ),
                    const SizedBox(height: 12),

                    // إدارة الجرحى
                    _buildMenuItem(
                      title: 'إدارة الجرحى',
                      subtitle: 'مراجعة وتوثيق بيانات الجرحى',
                      icon: Icons.medical_services_outlined,
                      color: const Color(0xFFD2691E), // Brown-orange like screenshot
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToManagement('الجرحى');
                      },
                    ),
                    const SizedBox(height: 12),

                    // إدارة الأسرى
                    _buildMenuItem(
                      title: 'إدارة الأسرى',
                      subtitle: 'مراجعة وتوثيق بيانات الأسرى',
                      icon: Icons.lock_person_outlined,
                      color: const Color(0xFF708090), // Slate gray like screenshot
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToManagement('الأسرى');
                      },
                    ),
                    const SizedBox(height: 12),

                    // إدارة المستخدمين
                    _buildMenuItem(
                      title: 'إدارة المستخدمين',
                      subtitle: 'إدارة حسابات المستخدمين',
                      icon: Icons.group_outlined,
                      color: const Color(0xFF2E7D32), // Dark green like screenshot
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToManagement('المستخدمين');
                      },
                    ),
                    const SizedBox(height: 12),

                    // إدارة البيانات المرسلة
                    _buildMenuItem(
                      title: 'إدارة البيانات المرسلة',
                      subtitle: 'مراجعة وإدارة البيانات المرسلة من المستخدمين',
                      icon: Icons.inbox_outlined,
                      color: const Color(0xFFFF6F00), // Orange color
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminApprovalScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // الإعدادات
                    _buildMenuItem(
                      title: 'الإعدادات',
                      subtitle: 'إعدادات التطبيق والحساب',
                      icon: Icons.settings,
                      color: const Color(0xFF4682B4), // Steel blue like screenshot
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // زر تسجيل الخروج
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildLogoutButton(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // رأس القائمة مع الترس وزر الخروج
  Widget _buildDrawerHeader(bool isDark) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20, 
        40 + MediaQuery.of(context).padding.top, 
        20, 
        30
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32), // Dark green exactly like screenshot
      ),
      child: Column(
        children: [
          // الصف الأول: سهم العودة + ترس الإعدادات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // سهم العودة
              IconButton(
                icon: Icon(
                  isRtl ? Icons.arrow_forward : Icons.arrow_back,
                  color: AppColors.primaryWhite,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              
              // ترس الإعدادات
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: AppColors.primaryWhite,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // أيقونة المدير
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.security,
                    size: 40,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // اسم المدير
          const Text(
            'Administrator',
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          const Text(
            'Administrator',
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // بناء عنصر القائمة
  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // النص الرئيسي
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AppColors.primaryWhite : color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? AppColors.primaryWhite.withOpacity(0.8) : color.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // الأيقونة
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryWhite : color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? color : AppColors.primaryWhite,
                size: 20,
              ),
            ),
            
            // سهم التنقل
            Icon(
              isRtl ? Icons.chevron_left : Icons.chevron_right,
              color: isDark ? AppColors.primaryWhite : color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // زر تسجيل الخروج
  Widget _buildLogoutButton(bool isDark) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _logout();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(
              'تسجيل الخروج',
              style: const TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.logout,
              color: AppColors.primaryWhite,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة ميزة مميزة
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// دالة التنقل لشاشات الإضافة (مثل صفحة المستخدم العادي)
  void _navigateToAddForm(String section) {
    Widget destinationScreen;
    
    switch (section) {
      case AppConstants.sectionMartyrs:
        destinationScreen = const AddMartyrScreen();
        break;
      case AppConstants.sectionInjured:
        destinationScreen = const AddInjuredScreen();
        break;
      case AppConstants.sectionPrisoners:
        destinationScreen = const AddPrisonerScreen();
        break;
      default:
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }
}

