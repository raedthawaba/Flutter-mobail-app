import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/martyr.dart';
import '../models/injured.dart';
import '../models/prisoner.dart';
import '../services/firebase_database_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();
  
  List<dynamic> _allData = []; // Combined list of all data types
  bool _isLoading = true;
  String _selectedStatus = 'all'; // all, pending, approved, rejected
  String _selectedType = 'all'; // all, martyr, injured, prisoner
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() => _isLoading = true);
      
      List<dynamic> combinedData = [];
      
      // جلب البيانات من جميع Collections
      if (_selectedType == 'all' || _selectedType == 'martyr') {
        final martyrs = await _dbService.getAllMartyrs();
        combinedData.addAll(martyrs.map((m) => {'type': 'martyr', 'data': m}));
      }
      
      if (_selectedType == 'all' || _selectedType == 'injured') {
        final injured = await _dbService.getAllInjured();
        combinedData.addAll(injured.map((i) => {'type': 'injured', 'data': i}));
      }
      
      if (_selectedType == 'all' || _selectedType == 'prisoner') {
        final prisoners = await _dbService.getAllPrisoners();
        combinedData.addAll(prisoners.map((p) => {'type': 'prisoner', 'data': p}));
      }
      
      setState(() {
        _allData = combinedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
      );
    }
  }

  List<dynamic> get _filteredData {
    List<dynamic> filtered = _allData;
    
    // فلتر الحالة
    if (_selectedStatus != 'all') {
      filtered = filtered.where((item) {
        final status = item['data'].status ?? '';
        return status == _selectedStatus;
      }).toList();
    }
    
    // البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final data = item['data'];
        final type = item['type'];
        
        String searchText = '';
        
        if (type == 'martyr') {
          searchText = '${data.fullName ?? ''} ${data.tribe ?? ''} ${data.deathPlace ?? ''}';
        } else if (type == 'injured') {
          searchText = '${data.fullName ?? ''} ${data.tribe ?? ''} ${data.injuryPlace ?? ''}';
        } else if (type == 'prisoner') {
          searchText = '${data.fullName ?? ''} ${data.tribe ?? ''} ${data.capturePlace ?? ''}';
        }
        
        return searchText.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البيانات'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDataList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط البحث
          TextField(
            decoration: const InputDecoration(
              hintText: 'البحث بالاسم أو المكان...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          // فلاتر الحالة والنوع
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                    DropdownMenuItem(value: 'pending', child: Text('في الانتظار')),
                    DropdownMenuItem(value: 'approved', child: Text('معتمد')),
                    DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _loadAllData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('جميع الأنواع')),
                    DropdownMenuItem(value: 'martyr', child: Text('شهداء')),
                    DropdownMenuItem(value: 'injured', child: Text('جرحى')),
                    DropdownMenuItem(value: 'prisoner', child: Text('أسرى')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _loadAllData();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    if (_filteredData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        final item = _filteredData[index];
        return _buildDataCard(item);
      },
    );
  }

  Widget _buildDataCard(Map<String, dynamic> item) {
    final data = item['data'];
    final type = item['type'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          _getItemTitle(data, type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_getTypeText(type)} - ${_getStatusText(data.status ?? 'pending')} - ${_formatDate(data.createdAt)}',
        ),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(data.status ?? 'pending'),
          child: Text(
            _getTypeIcon(type),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصور والملفات
                if (data.photoPath != null || data.cvFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الملفات المرفقة:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (data.photoPath != null)
                              ElevatedButton.icon(
                                onPressed: () => _viewImage(data.photoPath!),
                                icon: const Icon(Icons.image),
                                label: const Text('عرض الصورة'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            if (data.cvFilePath != null)
                              ElevatedButton.icon(
                                onPressed: () => _viewFile(data.cvFilePath!),
                                icon: const Icon(Icons.description),
                                label: const Text('عرض السيرة'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                // البيانات الأساسية
                _buildMartyrDetails(data),
                
                const SizedBox(height: 16),
                
                // أزرار التحكم
                _buildActionButtons(data, type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMartyrDetails(dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'البيانات الأساسية:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // الاسم واللقب
        _buildDetailRow('الاسم الكامل', data.fullName),
        if (data.nickname != null && data.nickname.isNotEmpty)
          _buildDetailRow('اللقب أو الاسم الحركي', data.nickname),
        
        // الجغرافيا
        if (data.tribe != null && data.tribe.isNotEmpty)
          _buildDetailRow('القبيلة/المنطقة', data.tribe),
        
        const SizedBox(height: 12),
        const Text(
          'التواريخ المهمة:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // التواريخ
        if (data.birthDate != null)
          _buildDetailRow('تاريخ الميلاد', _formatDate(data.birthDate)),
        if (data.deathDate != null || data.injuryDate != null || data.captureDate != null)
          _buildDetailRow(
            'تاريخ الحدث', 
            _formatDate(data.deathDate ?? data.injuryDate ?? data.captureDate)
          ),
        
        const SizedBox(height: 12),
        const Text(
          'تفاصيل الحدث:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // تفاصيل الحدث
        if (data.deathPlace != null && data.deathPlace.isNotEmpty)
          _buildDetailRow('مكان الاستشهاد', data.deathPlace),
        if (data.causeOfDeath != null && data.causeOfDeath.isNotEmpty)
          _buildDetailRow('سبب الاستشهاد', data.causeOfDeath),
        if (data.injuryPlace != null && data.injuryPlace.isNotEmpty)
          _buildDetailRow('مكان الإصابة', data.injuryPlace),
        if (data.injuryType != null && data.injuryType.isNotEmpty)
          _buildDetailRow('نوع الإصابة', data.injuryType),
        if (data.capturePlace != null && data.capturePlace.isNotEmpty)
          _buildDetailRow('مكان الاعتقال', data.capturePlace),
        if (data.capturedBy != null && data.capturedBy.isNotEmpty)
          _buildDetailRow('الجهات المعتقلة', data.capturedBy),
        
        // الرتبة/المنصب
        if (data.rankOrPosition != null && data.rankOrPosition.isNotEmpty)
          _buildDetailRow('الرتبة أو الموقع', data.rankOrPosition),
        if (data.participationFronts != null && data.participationFronts.isNotEmpty)
          _buildDetailRow('الجبهات/المعارك', data.participationFronts),
        
        const SizedBox(height: 12),
        const Text(
          'المعلومات الشخصية:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // المعلومات الشخصية
        if (data.familyStatus != null && data.familyStatus.isNotEmpty)
          _buildDetailRow('الحالة الاجتماعية', data.familyStatus),
        if (data.numChildren != null)
          _buildDetailRow('عدد الأبناء', data.numChildren.toString()),
        if (data.currentStatus != null && data.currentStatus.isNotEmpty)
          _buildDetailRow('الحالة الحالية', data.currentStatus),
        if (data.contactFamily != null && data.contactFamily.isNotEmpty)
          _buildDetailRow('رقم العائلة', data.contactFamily),
        if (data.hospitalName != null && data.hospitalName.isNotEmpty)
          _buildDetailRow('اسم المستشفى', data.hospitalName),
        if (data.releaseDate != null)
          _buildDetailRow('تاريخ الإفراج', _formatDate(data.releaseDate)),
        if (data.familyContact != null && data.familyContact.isNotEmpty)
          _buildDetailRow('رقم العائلة', data.familyContact),
        if (data.detentionPlace != null && data.detentionPlace.isNotEmpty)
          _buildDetailRow('مكان الاعتقال', data.detentionPlace),
        if (data.notes != null && data.notes.isNotEmpty)
          _buildDetailRow('ملاحظات', data.notes),
        
        // معلومات الإدارة
        const SizedBox(height: 12),
        const Text(
          'معلومات إدارية:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        _buildDetailRow('حالة التوثيق', _getStatusText(data.status ?? 'pending')),
        _buildDetailRow('تاريخ الإضافة', _formatDate(data.createdAt)),
        if (data.addedByUserId != null)
          _buildDetailRow('رقم المستخدم', data.addedByUserId),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic data, String type) {
    if (data.status == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _updateStatus(data, type, 'approved'),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('موافقة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton.icon(
            onPressed: () => _updateStatus(data, type, 'rejected'),
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text('رفض'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _updateStatus(data, type, 'pending'),
            icon: const Icon(Icons.undo, color: Colors.white),
            label: const Text('إرجاع للانتظار'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton.icon(
            onPressed: () => _deleteData(data, type),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    }
  }

  String _getItemTitle(dynamic data, String type) {
    if (data.fullName != null && data.fullName.isNotEmpty) {
      return data.fullName;
    }
    return 'بيانات ${_getTypeText(type)}';
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'martyr':
        return 'شهيد';
      case 'injured':
        return 'جريح';
      case 'prisoner':
        return 'أسير';
      default:
        return type;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'martyr':
        return '✟';
      case 'injured':
        return '🏥';
      case 'prisoner':
        return '🔒';
      default:
        return '📄';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    if (date is DateTime) {
      return DateFormat('yyyy/MM/dd').format(date);
    }
    return date.toString();
  }

  void _viewImage(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('عرض الصورة')),
          body: Center(
            child: Image.file(
              Uri.parse(imagePath).isAbsolute ? 
                Uri.parse(imagePath).toFilePath() as String : 
                imagePath
            ),
          ),
        ),
      ),
    );
  }

  void _viewFile(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح الملف قريباً...')),
    );
  }

  Future<void> _updateStatus(dynamic data, String type, String newStatus) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد تغيير الحالة'),
        content: Text('هل تريد تغيير الحالة إلى "${_getStatusText(newStatus)}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // هنا يمكن إضافة منطق تحديث الحالة
        // مثال: await _dbService.updateItemStatus(data.id, newStatus);
        
        _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الحالة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحديث الحالة: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteData(dynamic data, String type) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذه البيانات نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // هنا يمكن إضافة منطق حذف البيانات
        // مثال: await _dbService.deleteItem(data.id, type);
        
        _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف البيانات')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الحذف: $e')),
          );
        }
      }
    }
  }
}