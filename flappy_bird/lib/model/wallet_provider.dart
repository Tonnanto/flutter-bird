
class WalletProvider {
  final String id;
  final String name;
  final String? imageUrl;
  final String? iosLink;
  final String? androidLink;
  final String? native;
  final String? universal;

  WalletProvider({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.iosLink,
    required this.androidLink,
    required this.native,
    required this.universal,
  });

  static WalletProvider fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> appMap = json['app'] as Map<String, dynamic>;
    Map<String, dynamic> imageMap = json['image_url'] as Map<String, dynamic>;
    Map<String, dynamic> mobileMap = json['mobile'] as Map<String, dynamic>;
    return WalletProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: imageMap['md'] as String?,
      iosLink: appMap['ios'] as String?,
      androidLink: appMap['android'] as String?,
      native: mobileMap['native'] as String?,
      universal: mobileMap['universal'] as String?,
    );
  }
}