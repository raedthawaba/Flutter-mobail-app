// Minimal Admin Approval Screen - Temporary fix
import 'package:flutter/material.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة البيانات'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: const Center(
        child: Text('شاشة مراجعة البيانات قيد التطوير'),
      ),
    );
  }
}
