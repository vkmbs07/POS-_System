class ShopSettings {
  final String shopName;
  final String address;
  final String phone;
  final String? email;
  final String? website;

  ShopSettings({
    required this.shopName,
    required this.address,
    required this.phone,
    this.email,
    this.website,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_name': shopName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
    };
  }

  factory ShopSettings.fromMap(Map<String, dynamic> map) {
    return ShopSettings(
      shopName: map['shop_name'] ?? 'Retail Shop',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      website: map['website'],
    );
  }
  
  // Default settings
  factory ShopSettings.empty() {
    return ShopSettings(
      shopName: 'My Retail Shop',
      address: '',
      phone: '',
    );
  }
}
