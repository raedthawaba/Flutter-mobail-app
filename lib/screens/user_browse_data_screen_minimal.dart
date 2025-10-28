// Minimal User Browse Data Screen - Temporary fix
import 'package:flutter/material.dart';

class UserBrowseDataScreen extends StatefulWidget {
  final String dataType;
  
  const UserBrowseDataScreen({
    super.key,
    required this.dataType,
  });

  @override
  State<UserBrowseDataScreen> createState() => _UserBrowseDataScreenState();
}

class _UserBrowseDataScreenState extends State<UserBrowseDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض ${widget.dataType}'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Text('عرض بيانات ${widget.dataType} قيد التطوير'),
      ),
    );
  }
}
