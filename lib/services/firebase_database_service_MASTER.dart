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

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _martyrsCollection => _firestore.collection('martyrs');
  CollectionReference get _injuredCollection => _firestore.collection('injured');
  CollectionReference get _prisonersCollection => _firestore.collection('prisoners');
  CollectionReference get _pendingDataCollection => _firestore.collection('pending_data');

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
      return docRef.id;
    } catch (e) {
      print('خطأ في رفع البيانات: $e');
      rethrow;
    }
  }

  Future<List<PendingData>> getPendingData() async {
    try {
      final querySnapshot = await _pendingDataCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PendingData.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      print('خطأ في جلب البيانات المعلقة: $e');
      return [];
    }
  }

  Future<void> approvePendingData(String pendingId) async {
    try {
      final pendingDoc = await _pendingDataCollection.doc(pendingId).get();
      if (!pendingDoc.exists) {
        throw Exception('البيانات غير موجودة');
      }

      final pendingData = PendingData.fromFirestore(
        pendingDoc.data() as Map<String, dynamic>
      ).copyWith(id: pendingId);

      // Move to appropriate collection
      switch (pendingData.type) {
        case 'martyr':
          await _martyrsCollection.add(pendingData.data);
          break;
        case 'injured':
          await _injuredCollection.add(pendingData.data);
          break;
        case 'prisoner':
          await _prisonersCollection.add(pendingData.data);
          break;
      }

      // Mark as approved
      await _pendingDataCollection.doc(pendingId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في الموافقة: $e');
      rethrow;
    }
  }

  Future<void> rejectPendingData(String pendingId, String reason) async {
    try {
      await _pendingDataCollection.doc(pendingId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في الرفض: $e');
      rethrow;
    }
  }

  Future<List<Martyr>> getMartyrs() async {
    try {
      final querySnapshot = await _martyrsCollection
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Martyr.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('خطأ في جلب بيانات الشهداء: $e');
      return [];
    }
  }

  Future<List<Injured>> getInjured() async {
    try {
      final querySnapshot = await _injuredCollection
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Injured.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('خطأ في جلب بيانات الجرحى: $e');
      return [];
    }
  }

  Future<List<Prisoner>> getPrisoners() async {
    try {
      final querySnapshot = await _prisonersCollection
          .orderBy('dateAdded', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Prisoner.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('خطأ في جلب بيانات المعتقلين: $e');
      return [];
    }
  }

  Future<void> createUser(app_user.User user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());
    } catch (e) {
      print('خطأ في إنشاء المستخدم: $e');
      rethrow;
    }
  }

  Future<app_user.User?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  Future<bool> updateUser(app_user.User user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toFirestore());
      return true;
    } catch (e) {
      print('خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }
}