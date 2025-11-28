import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence settings if needed, 
    // though default is usually enabled for mobile/web.
    _firestore.settings = const Settings(
      persistenceEnabled: true, 
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
    );
  }

  // Generic Get Collection
  CollectionReference getCollection(String path) {
    return _firestore.collection(path);
  }

  // Add Document
  Future<void> addDocument(String path, Map<String, dynamic> data) async {
    await _firestore.collection(path).add(data);
  }

  // Set Document (with ID)
  Future<void> setDocument(String path, String id, Map<String, dynamic> data) async {
    await _firestore.collection(path).doc(id).set(data);
  }

  // Stream Collection
  Stream<QuerySnapshot> streamCollection(String path) {
    return _firestore.collection(path).snapshots();
  }
}
