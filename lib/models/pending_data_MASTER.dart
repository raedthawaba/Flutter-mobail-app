import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingData {
  final String? id;
  final String type; // 'martyr', 'injured', 'prisoner'
  final String status; // 'pending', 'approved', 'rejected'
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? resumeUrl;
  final String submittedBy;
  final DateTime submittedAt;

  PendingData({
    this.id,
    required this.type,
    required this.status,
    required this.data,
    this.imageUrl,
    this.resumeUrl,
    required this.submittedBy,
    required this.submittedAt,
  });

  factory PendingData.fromFirestore(Map<String, dynamic> data) {
    return PendingData(
      id: data['id'] as String?,
      type: data['type'] as String? ?? '',
      status: data['status'] as String? ?? '',
      data: data['data'] as Map<String, dynamic>? ?? {},
      imageUrl: data['imageUrl'] as String?,
      resumeUrl: data['resumeUrl'] as String?,
      submittedBy: data['submittedBy'] as String? ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'data': data,
      'imageUrl': imageUrl,
      'resumeUrl': resumeUrl,
      'submittedBy': submittedBy,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  PendingData copyWith({
    String? id,
    String? type,
    String? status,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? resumeUrl,
    String? submittedBy,
    DateTime? submittedAt,
  }) {
    return PendingData(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}