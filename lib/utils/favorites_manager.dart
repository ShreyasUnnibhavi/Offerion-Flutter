// lib/models/models.dart

class BannerItem {
  final String title;
  final String image;

  BannerItem({required this.title, required this.image});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      title: json['title']?.toString() ?? 'No Title',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
    };
  }
}

class CategoryItem {
  final String category;
  final String image;

  CategoryItem({required this.category, required this.image});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      category: json['category']?.toString() ?? 'No Category',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'image': image,
    };
  }
}

class PromotionItem {
  final String promotionTitle;
  final String mediaLink;
  final int id;
  final String shopId;

  PromotionItem({
    required this.promotionTitle,
    required this.mediaLink,
    required this.id,
    required this.shopId,
  });

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    return PromotionItem(
      promotionTitle: json['title']?.toString() ?? 'No Title',
      mediaLink: json['mediaLink']?.toString() ?? '',
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      shopId: json['shopId']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': promotionTitle,
      'mediaLink': mediaLink,
      'id': id,
      'shopId': shopId,
    };
  }
}

class ShopItem {
  final int shopId;
  final String shopName;
  final Map<String, dynamic> storeImages;
  final List<dynamic> categoryHierarchy;
  final String area;
  final String address;
  final String description;

  ShopItem({
    required this.shopId,
    required this.shopName,
    required this.storeImages,
    required this.categoryHierarchy,
    required this.area,
    required this.address,
    required this.description,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      shopId: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      shopName: json['shopName']?.toString() ?? 'No Shop Name',
      storeImages: Map<String, dynamic>.from(json['storeImages'] ?? {}),
      categoryHierarchy: List<dynamic>.from(json['category_hierarchy'] ?? []),
      area: json['area']?.toString() ?? 'Unknown Area',
      address: json['address']?.toString() ?? 'Unknown Address',
      description: json['description']?.toString() ?? 'No description available.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': shopId,
      'shopName': shopName,
      'storeImages': storeImages,
      'category_hierarchy': categoryHierarchy,
      'area': area,
      'address': address,
      'description': description,
    };
  }
}

class ProductItem {
  final int id;
  final int shopId;
  final String title;
  final double actualPrice;
  final double sellingPrice;
  final String description;
  final Map<String, dynamic> images;
  final String validity;
  final String category;
  final String subCategory;

  ProductItem({
    required this.id,
    required this.shopId,
    required this.title,
    required this.actualPrice,
    required this.sellingPrice,
    required this.description,
    required this.images,
    required this.validity,
    required this.category,
    required this.subCategory,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      shopId: json['shop_id'] is int ? json['shop_id'] : int.tryParse(json['shop_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'No Title',
      actualPrice: _parseDouble(json['actual_price']),
      sellingPrice: _parseDouble(json['selling_price']),
      description: json['description']?.toString() ?? '',
      images: Map<String, dynamic>.from(json['images'] ?? {}),
      validity: json['validity']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'title': title,
      'actual_price': actualPrice,
      'selling_price': sellingPrice,
      'description': description,
      'images': images,
      'validity': validity,
      'category': category,
      'sub_category': subCategory,
    };
  }
}

class UserActivityItem {
  final int id;
  final int activityId;
  final String action;
  final int userId;
  final String activityType;

  UserActivityItem({
    required this.id,
    required this.activityId,
    required this.action,
    required this.userId,
    required this.activityType,
  });

  factory UserActivityItem.fromJson(Map<String, dynamic> json) {
    return UserActivityItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      activityId: json['activityId'] is int ? json['activityId'] : int.tryParse(json['activityId']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? '',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      activityType: json['activityType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'action': action,
      'userId': userId,
      'activityType': activityType,
    };
  }
}

class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String gender;
  final String age;
  final String place;
  final String profileImage;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.age,
    required this.place,
    required this.profileImage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? 'N/A',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? 'N/A',
      gender: json['gender']?.toString() ?? 'N/A',
      age: json['age']?.toString() ?? 'N/A',
      place: json['place']?.toString() ?? 'N/A',
      profileImage: json['profile_image']?.toString() ?? 'assets/images/user.jpeg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'age': age,
      'place': place,
      'profile_image': profileImage,
    };
  }
}

// Additional required classes for favorites_manager.dart

class SaleItem {
  final String saleTitle;
  final String location;
  final String image;
  final double price;
  final double originalPrice;

  SaleItem({
    required this.saleTitle,
    this.location = '',
    this.image = '',
    this.price = 0.0,
    this.originalPrice = 0.0,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      saleTitle: json['saleTitle']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: ProductItem._parseDouble(json['price']),
      originalPrice: ProductItem._parseDouble(json['originalPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleTitle': saleTitle,
      'location': location,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
    };
  }
}

class DynamicOfferData {
  final String offerImage;
  final String offerTitle;
  final int shopId;
  final String location;
  final String category;

  const DynamicOfferData({
    required this.offerImage,
    required this.offerTitle,
    required this.shopId,
    this.location = 'Unknown Location',
    this.category = 'Unknown Category',
  });

  factory DynamicOfferData.fromJson(Map<String, dynamic> json) {
    return DynamicOfferData(
      offerImage: json['offerImage']?.toString() ?? '',
      offerTitle: json['offerTitle']?.toString() ?? '',
      shopId: json['shopId'] is int ? json['shopId'] : int.tryParse(json['shopId']?.toString() ?? '0') ?? 0,
      location: json['location']?.toString() ?? 'Unknown Location',
      category: json['category']?.toString() ?? 'Unknown Category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerImage': offerImage,
      'offerTitle': offerTitle,
      'shopId': shopId,
      'location': location,
      'category': category,
    };
  }
}

class NewItem {
  final String newTitle;
  final String mediaLink;
  final String description;
  final double price;

  NewItem({
    required this.newTitle,
    required this.mediaLink,
    this.description = '',
    this.price = 0.0,
  });

  factory NewItem.fromJson(Map<String, dynamic> json) {
    return NewItem(
      newTitle: json['newTitle']?.toString() ?? '',
      mediaLink: json['mediaLink']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: ProductItem._parseDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newTitle': newTitle,
      'mediaLink': mediaLink,
      'description': description,
      'price': price,
    };
  }
}
