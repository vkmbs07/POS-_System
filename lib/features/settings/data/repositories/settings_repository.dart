import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../models/shop_settings.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;
  final String? _userId; // In future, this will be shopId

  SettingsRepository(this._firestore, this._userId);

  DocumentReference<Map<String, dynamic>>? get _settingsDoc {
    if (_userId == null) return null;
    return _firestore
        .collection('shops')
        .doc(_userId)
        .collection('settings')
        .doc('general');
  }

  Stream<ShopSettings> getSettingsStream() {
    final doc = _settingsDoc;
    if (doc == null) return Stream.value(ShopSettings.empty());

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return ShopSettings.empty();
      }
      return ShopSettings.fromMap(snapshot.data()!);
    });
  }

  Future<ShopSettings> getSettings() async {
    final doc = _settingsDoc;
    if (doc == null) return ShopSettings.empty();

    final snapshot = await doc.get();
    if (!snapshot.exists || snapshot.data() == null) {
      return ShopSettings.empty();
    }
    return ShopSettings.fromMap(snapshot.data()!);
  }

  Future<void> saveSettings(ShopSettings settings) async {
    final doc = _settingsDoc;
    if (doc == null) throw Exception('User not logged in');

    await doc.set(settings.toMap());
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final userProfile = ref.watch(userProfileProvider).value;
  return SettingsRepository(FirebaseFirestore.instance, userProfile?.shopId);
});

final shopSettingsStreamProvider = StreamProvider<ShopSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).getSettingsStream();
});
