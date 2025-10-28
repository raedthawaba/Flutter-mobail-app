import 'package:flutter/material.dart';
import '../services/firebase_database_service.dart';
import '../models/martyr.dart';
import '../models/injured.dart';
import '../models/prisoner.dart';
import '../constants/app_colors.dart';

class UserBrowseDataScreen extends StatefulWidget {
  final String dataType; // 'martyrs', 'injured', 'prisoners'
  
  const UserBrowseDataScreen({
    Key? key,
    required this.dataType,
  }) : super(key: key);

  @override
  State<UserBrowseDataScreen> createState() => _UserBrowseDataScreenState();
}

class _UserBrowseDataScreenState extends State<UserBrowseDataScreen> {
  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();
  List<dynamic> _dataList = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // إعداد listener للتحديث الآلي
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // استمع للتحديثات الآلية
    _dbService.listenToApprovedData(widget.dataType).listen(
      (data) {
        // تحديث البيانات وإجراء البحث إذا كان هناك نص
        List<dynamic> updatedData = data;
        if (_searchQuery.trim().isNotEmpty) {
          updatedData = data.where((item) {
            return item.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        setState(() {
          _dataList = updatedData;
          _isLoading = false;
          _error = '';
        });
      },
      onError: (error) {
        setState(() {
          _error = 'خطأ في التحديث الآلي: $error';
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // جلب البيانات المعتمدة فقط
      final data = await _dbService.getAllApprovedData(widget.dataType);
      
      setState(() {
        _dataList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      setState(() {
        _searchQuery = query;
        _isLoading = true;
      });

      List<dynamic> results;
      if (query.trim().isEmpty) {
        results = await _dbService.getAllApprovedData(widget.dataType);
      } else {
        results = await _dbService.searchInApprovedData(widget.dataType, query);
      }
      
      setState(() {
        _dataList = results;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في البحث: $e';
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _performSearch('');
  }

  String _getTitle() {
    switch (widget.dataType) {
      case 'martyrs':
        return 'شهداء';
      case 'injured':
        return 'جرحى';
      case 'prisoners':
        return 'أسرى';
      default:
        return 'البيانات';
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن ${_getTitle()}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: _performSearch,
        onChanged: (value) {
          // البحث التلقائي أثناء الكتابة (مع تأخير)
          if (value.length >= 3) {
            _performSearch(value);
          } else if (value.isEmpty) {
            _clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildDataTile(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.age != null)
              Text('العمر: ${item.age} سنة'),
            if (widget.dataType == 'martyrs' && item.deathDate != null)
              Text('تاريخ الاستشهاد: ${_formatDate(item.deathDate)}'),
            if (widget.dataType == 'injured' && item.injuryDate != null)
              Text('تاريخ الإصابة: ${_formatDate(item.injuryDate)}'),
            if (widget.dataType == 'prisoners' && item.captureDate != null)
              Text('تاريخ الأسر: ${_formatDate(item.captureDate)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: إضافة شاشة تفاصيل البيانات
          _showDetailsDialog(item);
        },
      ),
    );
  }

  void _showDetailsDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.fullName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.age != null) Text('العمر: ${item.age} سنة'),
                if (widget.dataType == 'martyrs' && item.nickname != null) Text('الكنية: ${item.nickname}'),
                if (item.area != null) Text('القبيلة: ${item.area}'),
                if (widget.dataType == 'martyrs' && item.deathDate != null)
                  Text('تاريخ الاستشهاد: ${_formatDate(item.deathDate)}'),
                if (widget.dataType == 'martyrs' && item.placeOfMartyrdom != null)
                  Text('مكان الاستشهاد: ${item.placeOfMartyrdom}'),
                if (widget.dataType == 'martyrs' && item.causeOfMartyrdom != null)
                  Text('سبب الاستشهاد: ${item.causeOfMartyrdom}'),
                if (widget.dataType == 'injured' && item.injuryDate != null)
                  Text('تاريخ الإصابة: ${_formatDate(item.injuryDate)}'),
                if (widget.dataType == 'injured' && item.injuryType != null)
                  Text('نوع الإصابة: ${item.injuryType}'),
                if (widget.dataType == 'injured' && item.injuryDegree != null)
                  Text('درجة الإصابة: ${item.injuryDegree}'),
                if (widget.dataType == 'injured' && item.placeOfInjury != null)
                  Text('مكان الإصابة: ${item.placeOfInjury}'),
                if (widget.dataType == 'injured' && item.hospitalName != null && item.hospitalName!.isNotEmpty)
                  Text('المستشفى: ${item.hospitalName}'),
                if (widget.dataType == 'injured' && item.currentStatus != null)
                  Text('الحالة الحالية: ${item.currentStatus}'),
                if (widget.dataType == 'prisoners' && item.captureDate != null)
                  Text('تاريخ الأسر: ${_formatDate(item.captureDate)}'),
                if (widget.dataType == 'prisoners' && item.capturedBy != null)
                  Text('أُسر على يد: ${item.capturedBy}'),
                if (widget.dataType == 'prisoners' && item.placeOfArrest != null)
                  Text('مكان الأسر: ${item.placeOfArrest}'),
                if (widget.dataType == 'prisoners' && item.currentStatus != null)
                  Text('الحالة الحالية: ${item.currentStatus}'),
                if (widget.dataType == 'prisoners' && item.currentPrison != null)
                  Text('مكان الاعتقال: ${item.currentPrison}'),
                if (widget.dataType == 'prisoners' && item.familyContact != null)
                  Text('جهة اتصال العائلة: ${item.familyContact}'),
                if (widget.dataType == 'injured' && item.injuryDescription != null && item.injuryDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('وصف الإصابة: ${item.injuryDescription}'),
                  ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('ملاحظات إضافية: ${item.notes}'),
                  ),
                if (item.adminNotes != null && item.adminNotes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('ملاحظات: ${item.adminNotes}'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تصفح ${_getTitle()}'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),
          
          // معلومات البحث
          if (_searchQuery.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'النتائج عن: "$_searchQuery" - ${_dataList.length} عنصر',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          
          // محتوى البيانات
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _dataList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.data_usage,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'لا توجد نتائج للبحث "$_searchQuery"'
                                        : 'لا توجد بيانات معتمدة',
                                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _dataList.length,
                              itemBuilder: (context, index) {
                                return _buildDataTile(_dataList[index]);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}