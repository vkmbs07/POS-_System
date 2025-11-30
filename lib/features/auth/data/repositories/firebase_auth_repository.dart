
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Stream<UserModel?> get userProfileStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return null;
            return UserModel.fromMap(snapshot.data()!);
          });
    });
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password, {String? shopId}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Determine Shop ID and Role
      final String finalShopId = (shopId != null && shopId.isNotEmpty) 
          ? shopId 
          : credential.user!.uid;
      
      final String role = (shopId != null && shopId.isNotEmpty) 
          ? 'cashier' 
          : 'owner';

      // Create User Profile
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        shopId: finalShopId,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());
      
      // Only initialize shop settings if creating a NEW shop (owner)
      if (role == 'owner') {
        await _firestore
            .collection('shops')
            .doc(finalShopId)
            .set({'created_at': FieldValue.serverTimestamp()});
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).userProfileStream;
});
