class UserModel {
  final String uid;
  final String email;
  final String shopId;
  final String role; // 'owner', 'manager', 'cashier'

  UserModel({
    required this.uid,
    required this.email,
    required this.shopId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'shop_id': shopId,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      shopId: map['shop_id'] ?? '',
      role: map['role'] ?? 'cashier',
    );
  }
}
