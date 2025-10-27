import 'package:equatable/equatable.dart';
import '../constants/app_constants.dart';

class Injured extends Equatable {
  final String? id;
  final String fullName;
  final String tribe;
  final DateTime injuryDate;
  final String injuryPlace;
  final String injuryType;
  final String injuryDescription;
  final String injuryDegree;
  final String currentStatus;
  final String? hospitalName;
  final String contactFamily;
  final String addedByUserId; // User ID from Firebase Auth (String UID)
  final String? photoPath;
  final String? cvFilePath;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Injured({
    this.id,
    required this.fullName,
    required this.tribe,
    required this.injuryDate,
    required this.injuryPlace,
    required this.injuryType,
    required this.injuryDescription,
    required this.injuryDegree,
    required this.currentStatus,
    this.hospitalName,
    required this.contactFamily,
    required this.addedByUserId,
    this.photoPath,
    this.cvFilePath,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters for compatibility with admin screens
  bool get isApproved => status == AppConstants.statusApproved;
  String get idNumber => id?.toString() ?? 'غير محدد';
  String get area => tribe;
  DateTime get dateOfInjury => injuryDate;
  String get placeOfInjury => injuryPlace;
  String get typeOfInjury => injuryType;
  String get injurySeverity => injuryDegree;
  String? get notes => adminNotes;
  int get age => 0; // Age calculation would need birth date

  factory Injured.fromMap(Map<String, dynamic> map) {
    return Injured(
      id: map['id'],
      fullName: map['full_name'],
      tribe: map['tribe'],
      injuryDate: DateTime.parse(map['injury_date']),
      injuryPlace: map['injury_place'],
      injuryType: map['injury_type'],
      injuryDescription: map['injury_description'],
      injuryDegree: map['injury_degree'],
      currentStatus: map['current_status'],
      hospitalName: map['hospital_name'],
      contactFamily: map['contact_family'],
      addedByUserId: map['added_by_user_id'],
      photoPath: map['photo_path'],
      cvFilePath: map['cv_file_path'],
      status: map['status'],
      adminNotes: map['admin_notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'tribe': tribe,
      'injury_date': injuryDate.toIso8601String(),
      'injury_place': injuryPlace,
      'injury_type': injuryType,
      'injury_description': injuryDescription,
      'injury_degree': injuryDegree,
      'current_status': currentStatus,
      'hospital_name': hospitalName,
      'contact_family': contactFamily,
      'added_by_user_id': addedByUserId,
      'photo_path': photoPath,
      'cv_file_path': cvFilePath,
      'status': status,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Injured copyWith({
    String? id,
    String? fullName,
    String? tribe,
    DateTime? injuryDate,
    String? injuryPlace,
    String? injuryType,
    String? injuryDescription,
    String? injuryDegree,
    String? currentStatus,
    String? hospitalName,
    String? contactFamily,
    String? addedByUserId, // User ID from Firebase Auth (String UID)
    String? photoPath,
    String? cvFilePath,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Injured(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      tribe: tribe ?? this.tribe,
      injuryDate: injuryDate ?? this.injuryDate,
      injuryPlace: injuryPlace ?? this.injuryPlace,
      injuryType: injuryType ?? this.injuryType,
      injuryDescription: injuryDescription ?? this.injuryDescription,
      injuryDegree: injuryDegree ?? this.injuryDegree,
      currentStatus: currentStatus ?? this.currentStatus,
      hospitalName: hospitalName ?? this.hospitalName,
      contactFamily: contactFamily ?? this.contactFamily,
      addedByUserId: addedByUserId ?? this.addedByUserId,
      photoPath: photoPath ?? this.photoPath,
      cvFilePath: cvFilePath ?? this.cvFilePath,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        tribe,
        injuryDate,
        injuryPlace,
        injuryType,
        injuryDescription,
        injuryDegree,
        currentStatus,
        hospitalName,
        contactFamily,
        addedByUserId,
        photoPath,
        cvFilePath,
        status,
        adminNotes,
        createdAt,
        updatedAt,
      ];

  // Factory method to create Injured from Firestore data
  factory Injured.fromFirestore(Map<String, dynamic> data) {
    return Injured(
      id: data['id'],
      fullName: data['full_name'] ?? data['fullName'] ?? '',
      tribe: data['tribe'] ?? '',
      injuryDate: data['injury_date'] != null || data['injuryDate'] != null
          ? (data['injury_date'] != null ? 
              (data['injury_date'] is String 
                  ? DateTime.parse(data['injury_date']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['injury_date'])) :
              (data['injuryDate'] is String 
                  ? DateTime.parse(data['injuryDate']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['injuryDate'])))
          : DateTime.now(),
      injuryPlace: data['injury_place'] ?? data['injuryPlace'] ?? '',
      injuryType: data['injury_type'] ?? data['injuryType'] ?? '',
      injuryDescription: data['injury_description'] ?? data['injuryDescription'] ?? '',
      injuryDegree: data['injury_degree'] ?? data['injuryDegree'] ?? '',
      currentStatus: data['current_status'] ?? data['currentStatus'] ?? '',
      hospitalName: data['hospital_name'] ?? data['hospitalName'],
      contactFamily: data['contact_family'] ?? data['contactFamily'] ?? '',
      addedByUserId: data['added_by_user_id'] ?? data['addedByUserId'] ?? '',
      photoPath: data['photo_path'] ?? data['photoPath'],
      cvFilePath: data['cv_file_path'] ?? data['cvFilePath'],
      status: data['status'] ?? AppConstants.statusPending,
      adminNotes: data['admin_notes'] ?? data['adminNotes'],
      createdAt: data['created_at'] != null || data['createdAt'] != null
          ? (data['created_at'] != null ? 
              (data['created_at'] is String 
                  ? DateTime.parse(data['created_at']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['created_at'])) :
              (data['createdAt'] is String 
                  ? DateTime.parse(data['createdAt']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['createdAt'])))
          : DateTime.now(),
      updatedAt: data['updated_at'] != null || data['updatedAt'] != null
          ? (data['updated_at'] != null ? 
              (data['updated_at'] is String 
                  ? DateTime.parse(data['updated_at']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['updated_at'])) :
              (data['updatedAt'] is String 
                  ? DateTime.parse(data['updatedAt']) 
                  : DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])))
          : null,
    );
  }

  // Method to convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'full_name': fullName,
      'tribe': tribe,
      'injury_date': injuryDate.millisecondsSinceEpoch,
      'injury_place': injuryPlace,
      'injury_type': injuryType,
      'injury_description': injuryDescription,
      'injury_degree': injuryDegree,
      'current_status': currentStatus,
      'contact_family': contactFamily,
      'added_by_user_id': addedByUserId,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    
    if (hospitalName != null) data['hospital_name'] = hospitalName;
    if (photoPath != null) data['photo_path'] = photoPath;
    if (cvFilePath != null) data['cv_file_path'] = cvFilePath;
    if (adminNotes != null) data['admin_notes'] = adminNotes;
    if (updatedAt != null) data['updated_at'] = updatedAt!.millisecondsSinceEpoch;
    
    return data;
  }
}