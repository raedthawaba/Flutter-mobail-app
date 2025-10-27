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

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Widget _buildDataTile(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          item.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.dataType == 'martyrs'
              ? 'تاريخ الاستشهاد: ${_formatDate(item.deathDate)}'
              : widget.dataType == 'injured'
                  ? 'تاريخ الإصابة: ${_formatDate(item.injuryDate)}'
                  : 'تاريخ الأسر: ${_formatDate(item.captureDate)}',
        ),
        onTap: () {
          // TODO: إضافة شاشة تفاصيل البيانات
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تصفح ${_getTitle()}'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
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
                    ? const Center(
                        child: Text(
                          'لا توجد بيانات معتمدة',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          return _buildDataTile(_dataList[index]);
                        },
                      ),
      ),
    );
  }
}