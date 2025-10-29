import 'package:flutter/material.dart';
import 'dart:io';
import '../services/firebase_database_service.dart';
import '../services/auth_service.dart';
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
  // ًں”§ ط§ظ„ط¥طµظ„ط§ط­ ط§ظ„ط£ط³ط§ط³ظٹ: ط¥ط¶ط§ظپط© AuthService instance
  final AuthService _authService = AuthService();
  
  List<dynamic> _dataList = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // ط¥ط¹ط¯ط§ط¯ listener ظ„ظ„طھط­ط¯ظٹط« ط§ظ„ط¢ظ„ظٹ
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // ط§ط³طھظ…ط¹ ظ„ظ„طھط­ط¯ظٹط«ط§طھ ط§ظ„ط¢ظ„ظٹط©
    _dbService.listenToApprovedData(widget.dataType).listen(
      (data) {
        // طھط­ط¯ظٹط« ط§ظ„ط¨ظٹط§ظ†ط§طھ ظˆط¥ط¬ط±ط§ط، ط§ظ„ط¨ط­ط« ط¥ط°ط§ ظƒط§ظ† ظ‡ظ†ط§ظƒ ظ†طµ
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
          _error = 'ط®ط·ط£ ظپظٹ ط§ظ„طھط­ط¯ظٹط« ط§ظ„ط¢ظ„ظٹ: $error';
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

      // ط¬ظ„ط¨ ط§ظ„ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ…ط¹طھظ…ط¯ط© ظپظ‚ط·
      final data = await _dbService.getAllApprovedData(widget.dataType);
      
      setState(() {
        _dataList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'ط®ط·ط£ ظپظٹ طھط­ظ…ظٹظ„ ط§ظ„ط¨ظٹط§ظ†ط§طھ: $e';
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
        _error = 'ط®ط·ط£ ظپظٹ ط§ظ„ط¨ط­ط«: $e';
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
        return 'ط´ظ‡ط¯ط§ط،';
      case 'injured':
        return 'ط¬ط±ط­ظ‰';
      case 'prisoners':
        return 'ط£ط³ط±ظ‰';
      default:
        return 'ط§ظ„ط¨ظٹط§ظ†ط§طھ';
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ط§ط¨ط­ط« ط¹ظ† ${_getTitle()}...',
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
          // ط§ظ„ط¨ط­ط« ط§ظ„طھظ„ظ‚ط§ط¦ظٹ ط£ط«ظ†ط§ط، ط§ظ„ظƒطھط§ط¨ط© (ظ…ط¹ طھط£ط®ظٹط±)
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
              Text('ط§ظ„ط¹ظ…ط±: ${item.age} ط³ظ†ط©'),
            if (widget.dataType == 'martyrs' && item.deathDate != null)
              Text('طھط§ط±ظٹط® ط§ظ„ط§ط³طھط´ظ‡ط§ط¯: ${_formatDate(item.deathDate)}'),
            if (widget.dataType == 'injured' && item.injuryDate != null)
              Text('طھط§ط±ظٹط® ط§ظ„ط¥طµط§ط¨ط©: ${_formatDate(item.injuryDate)}'),
            if (widget.dataType == 'prisoners' && item.captureDate != null)
              Text('طھط§ط±ظٹط® ط§ظ„ط£ط³ط±: ${_formatDate(item.captureDate)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: ط¥ط¶ط§ظپط© ط´ط§ط´ط© طھظپط§طµظٹظ„ ط§ظ„ط¨ظٹط§ظ†ط§طھ
          _showDetailsDialog(item);
        },
      ),
    );
  }

  // ط¯ظˆط§ظ„ ط¹ط±ط¶ ط§ظ„طµظˆط± ظˆط§ظ„ظ…ظ„ظپط§طھ
  void _viewImage(String imagePath) {
    Navigator.of(context).pop(); // ط¥ط؛ظ„ط§ظ‚ ط§ظ„ظ€ dialog ط§ظ„ط­ط§ظ„ظٹ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('طµظˆط±ط© ط´ط®طµظٹط©'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('طھط¹ط°ط± طھط­ظ…ظٹظ„ ط§ظ„طµظˆط±ط©'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewFile(String filePath) {
    Navigator.of(context).pop(); // ط¥ط؛ظ„ط§ظ‚ ط§ظ„ظ€ dialog ط§ظ„ط­ط§ظ„ظٹ
    // ظٹظ…ظƒظ† طھط·ظˆظٹط± ظ‡ط°ظ‡ ط§ظ„ط¯ط§ظ„ط© ظ„ظپطھط­ PDF ط£ظˆ ط¹ط±ط¶ ط§ظ„ظ…ظ„ظپ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ط³ظٹطھظ… طھط·ظˆظٹط± ط¹ط±ط¶ ظ…ظ„ظپ ط§ظ„ط³ظٹط±ط© ط§ظ„ط°ط§طھظٹط© ظ‚ط±ظٹط¨ط§ظ‹'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ًں”§ ط§ظ„ط¥طµظ„ط§ط­ ط§ظ„ط£ط³ط§ط³ظٹ: ط¯ط§ظ„ط© ط§ظ„طھط­ظ‚ظ‚ ظ…ظ† طµظ„ط§ط­ظٹط§طھ ط§ظ„ظ…ط³ط¤ظˆظ„
  Future<bool> _isUserAdmin() async {
    try {
      // ًں”§ ظ‡ط°ط§ ظ‡ظˆ ط§ظ„ط³ط·ط± ط§ظ„ظ…ظڈطµظ„ط­: ط§ط³طھط®ط¯ط§ظ… instance method ط¨ط¯ظ„ط§ظ‹ ظ…ظ† static method
      final user = await _authService.getCurrentUser();
      return user?.userType == 'admin';
    } catch (e) {
      print('Error checking if user is admin: $e');
      return false;
    }
  }

  void _showDetailsDialog(dynamic item) async {
    final bool isAdmin = await _isUserAdmin();
    
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
                // ط§ظ„طµظˆط± ظˆظ…ظ„ظپط§طھ ط§ظ„ط³ظٹط±ط© ط§ظ„ط°ط§طھظٹط© (ظ„ظ„ظ…ط³ط¤ظˆظ„ظٹظ† ظپظ‚ط·)
                if (isAdmin && (item.photoPath != null || item.cvFilePath != null))
                  ...[
                    // ط¹ط±ط¶ ط§ظ„طµظˆط±ط© ط§ظ„ط´ط®طµظٹط©
                    if (item.photoPath != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(item.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    // ط£ط²ط±ط§ط± ط¹ط±ط¶ ط§ظ„طµظˆط± ظˆظ…ظ„ظپط§طھ ط§ظ„ط³ظٹط±ط©
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (item.photoPath != null)
                          ElevatedButton.icon(
                            onPressed: () => _viewImage(item.photoPath!),
                            icon: const Icon(Icons.image),
                            label: const Text('ط¹ط±ط¶ ط§ظ„طµظˆط±ط©'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        if (item.cvFilePath != null)
                          ElevatedButton.icon(
                            onPressed: () => _viewFile(item.cvFilePath!),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('ط¹ط±ط¶ ط§ظ„ط³ظٹط±ط©'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                
                // ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط£ط³ط§ط³ظٹط© (ظ…ط±ط¦ظٹط© ظ„ظ„ط¬ظ…ظٹط¹)
                if (isAdmin && item.age != null && item.age > 0)
                  Text('ط§ظ„ط¹ظ…ط±: ${item.age} ط³ظ†ط©', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (!isAdmin && item.age != null && item.age > 0)
                  Text('ط§ظ„ط¹ظ…ط±: ${item.age} ط³ظ†ط©'),
                
                if (widget.dataType == 'martyrs' && item.nickname != null)
                  Text('ط§ظ„ظƒظ†ظٹط©: ${item.nickname}'),
                
                // ظ…ط¹ظ„ظˆظ…ط§طھ ط¹ط§ظ…ط©
                if (item.area != null) Text('ط§ظ„ظ‚ط¨ظٹظ„ط©: ${item.area}'),
                
                // ظ…ط¹ظ„ظˆظ…ط§طھ ط·ط¨ظٹط© ط­ط³ط§ط³ط© (ظ„ظ„ظ…ط³ط¤ظˆظ„ظٹظ† ظپظ‚ط·)
                if (isAdmin) ...[
                  if (widget.dataType == 'martyrs' && item.deathDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط§ط³طھط´ظ‡ط§ط¯: ${_formatDate(item.deathDate)}'),
                  if (widget.dataType == 'martyrs' && item.placeOfMartyrdom != null)
                    Text('ظ…ظƒط§ظ† ط§ظ„ط§ط³طھط´ظ‡ط§ط¯: ${item.placeOfMartyrdom}'),
                  if (widget.dataType == 'martyrs' && item.causeOfMartyrdom != null)
                    Text('ط³ط¨ط¨ ط§ظ„ط§ط³طھط´ظ‡ط§ط¯: ${item.causeOfMartyrdom}'),
                  
                  if (widget.dataType == 'injured' && item.injuryDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط¥طµط§ط¨ط©: ${_formatDate(item.injuryDate)}'),
                  if (widget.dataType == 'injured' && item.injuryType != null)
                    Text('ظ†ظˆط¹ ط§ظ„ط¥طµط§ط¨ط©: ${item.injuryType}'),
                  if (widget.dataType == 'injured' && item.injuryDegree != null)
                    Text('ط¯ط±ط¬ط© ط§ظ„ط¥طµط§ط¨ط©: ${item.injuryDegree}'),
                  if (widget.dataType == 'injured' && item.placeOfInjury != null)
                    Text('ظ…ظƒط§ظ† ط§ظ„ط¥طµط§ط¨ط©: ${item.placeOfInjury}'),
                  if (widget.dataType == 'injured' && item.hospitalName != null && item.hospitalName!.isNotEmpty)
                    Text('ط§ظ„ظ…ط³طھط´ظپظ‰: ${item.hospitalName}'),
                  if (widget.dataType == 'injured' && item.currentStatus != null)
                    Text('ط§ظ„ط­ط§ظ„ط© ط§ظ„ط­ط§ظ„ظٹط©: ${item.currentStatus}'),
                  
                  if (widget.dataType == 'prisoners' && item.captureDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط£ط³ط±: ${_formatDate(item.captureDate)}'),
                  if (widget.dataType == 'prisoners' && item.capturedBy != null)
                    Text('ط£ظڈط³ط± ط¹ظ„ظ‰ ظٹط¯: ${item.capturedBy}'),
                  if (widget.dataType == 'prisoners' && item.placeOfArrest != null)
                    Text('ظ…ظƒط§ظ† ط§ظ„ط£ط³ط±: ${item.placeOfArrest}'),
                  if (widget.dataType == 'prisoners' && item.currentStatus != null)
                    Text('ط§ظ„ط­ط§ظ„ط© ط§ظ„ط­ط§ظ„ظٹط©: ${item.currentStatus}'),
                  if (widget.dataType == 'prisoners' && item.currentPrison != null)
                    Text('ظ…ظƒط§ظ† ط§ظ„ط§ط¹طھظ‚ط§ظ„: ${item.currentPrison}'),
                  if (widget.dataType == 'prisoners' && item.familyContact != null)
                    Text('ط¬ظ‡ط© ط§طھطµط§ظ„ ط§ظ„ط¹ط§ط¦ظ„ط©: ${item.familyContact}'),
                  
                  if (widget.dataType == 'injured' && item.injuryDescription != null && item.injuryDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('ظˆطµظپ ط§ظ„ط¥طµط§ط¨ط©: ${item.injuryDescription}'),
                    ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('ظ…ظ„ط§ط­ط¸ط§طھ ط¥ط¶ط§ظپظٹط©: ${item.notes}'),
                    ),
                  if (item.adminNotes != null && item.adminNotes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('ظ…ظ„ط§ط­ط¸ط§طھ ط¥ط¯ط§ط±ظٹط©: ${item.adminNotes}'),
                    ),
                ] else if (!isAdmin) ...[
                  // ط±ط³ط§ط¦ظ„ ظ„ظ„ظ…ط³طھط®ط¯ظ…ظٹظ† ط§ظ„ط¹ط§ط¯ظٹظٹظ†
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„طھظپطµظٹظ„ظٹط© ظ…طھط§ط­ط© ظ„ظ„ظ…ط³ط¤ظˆظ„ظٹظ† ظپظ‚ط·',
                            style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // ظ…ط¹ظ„ظˆظ…ط§طھ ط£ط³ط§ط³ظٹط© ظ…ط­ط¯ظˆط¯ط© ظ„ظ„ظ…ط³طھط®ط¯ظ…ظٹظ† ط§ظ„ط¹ط§ط¯ظٹظٹظ†
                  if (widget.dataType == 'martyrs' && item.deathDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط§ط³طھط´ظ‡ط§ط¯: ${_formatDate(item.deathDate)}'),
                  if (widget.dataType == 'injured' && item.injuryDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط¥طµط§ط¨ط©: ${_formatDate(item.injuryDate)}'),
                  if (widget.dataType == 'prisoners' && item.captureDate != null)
                    Text('طھط§ط±ظٹط® ط§ظ„ط£ط³ط±: ${_formatDate(item.captureDate)}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ط¥ط؛ظ„ط§ظ‚'),
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
        title: Text('طھطµظپط­ ${_getTitle()}'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'طھط­ط¯ظٹط« ط§ظ„ط¨ظٹط§ظ†ط§طھ',
          ),
        ],
      ),
      body: Column(
        children: [
          // ط´ط±ظٹط· ط§ظ„ط¨ط­ط«
          _buildSearchBar(),
          
          // ظ…ط¹ظ„ظˆظ…ط§طھ ط§ظ„ط¨ط­ط«
          if (_searchQuery.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ط§ظ„ظ†طھط§ط¦ط¬ ط¹ظ†: "$_searchQuery" - ${_dataList.length} ط¹ظ†طµط±',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          
          // ظ…ط­طھظˆظ‰ ط§ظ„ط¨ظٹط§ظ†ط§طھ
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
                                child: const Text('ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©'),
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
                                        ? 'ظ„ط§ طھظˆط¬ط¯ ظ†طھط§ط¦ط¬ ظ„ظ„ط¨ط­ط« "$_searchQuery"'
                                        : 'ظ„ط§ طھظˆط¬ط¯ ط¨ظٹط§ظ†ط§طھ ظ…ط¹طھظ…ط¯ط©',
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
