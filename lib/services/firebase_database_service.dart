import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart' as app_user;
import '../models/martyr.dart';
import '../models/injured.dart';
import '../models/prisoner.dart';
import '../models/pending_data.dart';
import '../constants/app_constants.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabaseService _instance = FirebaseDatabaseService._internal();
  factory FirebaseDatabaseService() => _instance;
  FirebaseDatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _martyrsCollection => _firestore.collection('martyrs');
  CollectionReference get _injuredCollection => _firestore.collection('injured');
  CollectionReference get _prisonersCollection => _firestore.collection('prisoners');
  CollectionReference get _pendingDataCollection => _firestore.collection('pending_data');

  // Simplified PendingData methods
  Future<String> submitDataForApproval({
    required String type,
    required Map<String, dynamic> data,
    String? imageUrl,
    String? resumeUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final pendingData = PendingData(
        id: null,
        type: type,
        status: 'pending',
        data: data,
        imageUrl: imageUrl,
        resumeUrl: resumeUrl,
        submittedBy: user.uid,
        submittedAt: DateTime.now(),
      );

      final docRef = await _pendingDataCollection.add(pendingData.toFirestore());
      
      print('✅ تم إرسال البيانات للمراجعة - ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      throw Exception('خطأ في إرسال البيانات: $e');
    }
  }

  Future<List<PendingData>> getPendingData({
    String? statusFilter,
    String? typeFilter,
    int limit = 50,
  }) async {
    try {
      Query query = _pendingDataCollection;
      
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }
      
      if (typeFilter != null) {
        query = query.where('type', isEqualTo: typeFilter);
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('submittedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PendingData.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في جلب البيانات المرسلة: $e');
    }
  }

  // Basic user methods
  Future<void> createUser(app_user.User user) async {
    await _usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'userType': user.userType,
      'displayName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Basic CRUD methods for martyrs
  Future<List<Martyr>> getAllApprovedMartyrs() async {
    try {
      final QuerySnapshot snapshot = await _martyrsCollection
          .where('status', isEqualTo: 'approved')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Martyr.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الشهداء: $e');
    }
  }

  // Similar methods for injured and prisoners would be here...
  Future<List<Injured>> getAllApprovedInjured() async {
    try {
      final QuerySnapshot snapshot = await _injuredCollection
          .where('status', isEqualTo: 'approved')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Injured.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الجرحى: $e');
    }
  }

  Future<List<Prisoner>> getAllApprovedPrisoners() async {
    try {
      final QuerySnapshot snapshot = await _prisonersCollection
          .where('status', isEqualTo: 'approved')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Prisoner.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في جلب المعتقلين: $e');
    }
  }

  // Search methods
  Future<List<Martyr>> searchApprovedMartyrs(String query) async {
    try {
      final QuerySnapshot snapshot = await _martyrsCollection
          .where('status', isEqualTo: 'approved')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Martyr.fromFirestore(data).copyWith(id: doc.id);
      }).toList().where((martyr) {
        return martyr.name.toLowerCase().contains(query.toLowerCase()) ||
               martyr.age.toString().contains(query) ||
               martyr.gender.toLowerCase().contains(query.toLowerCase()) ||
               martyr.governorate.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('خطأ في البحث: $e');
    }
  }

  // Approval methods
  Future<void> approveData(String pendingId, {String? adminNotes}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final docRef = _pendingDataCollection.doc(pendingId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('البيانات غير موجودة');
      }
      
      final pendingData = PendingData.fromFirestore(doc.data() as Map<String, dynamic>).copyWith(id: pendingId);
      
      // نقل البيانات إلى المجموعة الرئيسية مع status = 'approved'
      switch (pendingData.type) {
        case 'martyr':
          await _martyrsCollection.doc(pendingId).set({
            ...pendingData.data,
            'status': 'approved',
            'image_url': pendingData.imageUrl,
            'resume_url': pendingData.resumeUrl,
            'approved_by': user.uid,
            'approved_at': FieldValue.serverTimestamp(),
          });
          break;
        case 'injured':
          await _injuredCollection.doc(pendingId).set({
            ...pendingData.data,
            'status': 'approved',
            'image_url': pendingData.imageUrl,
            'resume_url': pendingData.resumeUrl,
            'approved_by': user.uid,
            'approved_at': FieldValue.serverTimestamp(),
          });
          break;
        case 'prisoner':
          await _prisonersCollection.doc(pendingId).set({
            ...pendingData.data,
            'status': 'approved',
            'image_url': pendingData.imageUrl,
            'resume_url': pendingData.resumeUrl,
            'approved_by': user.uid,
            'approved_at': FieldValue.serverTimestamp(),
          });
          break;
        default:
          throw Exception('نوع البيانات غير مدعوم: ${pendingData.type}');
      }

      // تحديث حالة البيانات المرسلة
      await docRef.update({
        'status': 'approved',
        'adminNotes': adminNotes,
        'adminAction': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'adminId': user.uid,
      });
      
      print('✅ تم الموافقة على البيانات بنجاح');
    } catch (e) {
      throw Exception('خطأ في الموافقة على البيانات: $e');
    }
  }

  // Rejection method
  Future<void> rejectData(String pendingId, {required String reason}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final docRef = _pendingDataCollection.doc(pendingId);
      await docRef.update({
        'status': 'rejected',
        'adminNotes': reason,
        'adminAction': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'adminId': user.uid,
      });
      
      print('✅ تم رفض البيانات');
    } catch (e) {
      throw Exception('خطأ في رفض البيانات: $e');
    }
  }

  // إضافة الـ methods المفقودة المطلوبة في باقي الملفات
  
  // User authentication methods
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Data insertion methods
  Future<void> insertMartyr(Martyr martyr) async {
    final docRef = await _martyrsCollection.add(martyr.toFirestore());
    print('✅ تم إدراج الشهيد - ID: ${docRef.id}');
  }

  Future<void> insertInjured(Injured injured) async {
    final docRef = await _injuredCollection.add(injured.toFirestore());
    print('✅ تم إدراج الجريح - ID: ${docRef.id}');
  }

  Future<void> insertPrisoner(Prisoner prisoner) async {
    final docRef = await _prisonersCollection.add(prisoner.toFirestore());
    print('✅ تم إدراج المعتقل - ID: ${docRef.id}');
  }

  // Statistics methods
  Future<Map<String, int>> getStatistics() async {
    try {
      final martyrsSnapshot = await _martyrsCollection.where('status', isEqualTo: 'approved').get();
      final injuredSnapshot = await _injuredCollection.where('status', isEqualTo: 'approved').get();
      final prisonersSnapshot = await _prisonersCollection.where('status', isEqualTo: 'approved').get();

      return {
        'martyrs': martyrsSnapshot.docs.length,
        'injured': injuredSnapshot.docs.length,
        'prisoners': prisonersSnapshot.docs.length,
        'total': martyrsSnapshot.docs.length + injuredSnapshot.docs.length + prisonersSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('خطأ في جلب الإحصائيات: $e');
    }
  }

  // Data retrieval methods
  Future<List<Martyr>> getAllMartyrs() async {
    return await getAllApprovedMartyrs();
  }

  Future<List<Injured>> getAllInjured() async {
    return await getAllApprovedInjured();
  }

  Future<List<Prisoner>> getAllPrisoners() async {
    return await getAllApprovedPrisoners();
  }

  // Submit data for review
  Future<void> submitDataForReview(String type, Map<String, dynamic> data, {String? imageUrl, String? resumeUrl}) async {
    await submitDataForApproval(
      type: type,
      data: data,
      imageUrl: imageUrl,
      resumeUrl: resumeUrl,
    );
  }
}
