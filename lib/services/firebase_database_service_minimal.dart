// Minimal Firebase Database Service - Temporary fix
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
  Future<void> submitDataForApproval({
    required String type,
    required Map<String, dynamic> data,
    String? imageUrl,
    String? resumeUrl,
  }) async {
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

    await _pendingDataCollection.add(pendingData.toFirestore());
  }

  Future<List<PendingData>> getPendingData() async {
    try {
      final QuerySnapshot snapshot = await _pendingDataCollection.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PendingData.fromFirestore(data).copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في جلب البيانات: $e');
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
}
