// lib/models/models.dart

class BannerItem {
  final String title;
  final String image;

  BannerItem({required this.title, required this.image});

  factory BannerItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BannerItem(title: 'No Title', image: '');
    }

    try {
      return BannerItem(
        title: json['title']?.toString() ?? 'No Title',
        image: json['image']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing BannerItem: $e');
      return BannerItem(title: 'No Title', image: '');
    }
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

  factory CategoryItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CategoryItem(category: 'No Category', image: '');
    }

    try {
      return CategoryItem(
        category: json['category']?.toString() ?? 'No Category',
        image: json['image']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing CategoryItem: $e');
      return CategoryItem(category: 'No Category', image: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'image': image,
    };
  }
}

class PromotionItem {
  final int id;
  final int shopId;
  final String shopName;
  final String shopImage;
  final Map<String, dynamic> location;
  final String promotionTitle;
  final String actualPrice;
  final String sellingPrice;
  final String description;
  final String category;
  final String subCategory;
  final String mediaLink;
  final String contentType;
  final String status;
  final String promotionType;
  final Map<String, dynamic> counter;
  final String? denialReason;
  final String createdAt;
  final String updatedAt;

  PromotionItem({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopImage,
    required this.location,
    required this.promotionTitle,
    required this.actualPrice,
    required this.sellingPrice,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.mediaLink,
    required this.contentType,
    required this.status,
    required this.promotionType,
    required this.counter,
    this.denialReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromotionItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return _getDefaultPromotionItem();
    }

    try {
      // Handle shop information
      Map<String, dynamic> shopData = {};
      String shopName = 'Unknown Shop';
      String shopImage = '';

      if (json['shop'] != null && json['shop'] is Map) {
        shopData = Map<String, dynamic>.from(json['shop']);
        shopName = shopData['shopName']?.toString() ?? 'Unknown Shop';
        shopImage = shopData['storeImages'] != null &&
            shopData['storeImages'] is Map &&
            shopData['storeImages']['0'] != null
            ? shopData['storeImages']['0'].toString()
            : '';
      } else {
        shopName = json['shopName']?.toString() ?? 'Unknown Shop';
        shopImage = json['shopImage']?.toString() ?? '';
      }

      // Handle location
      Map<String, dynamic> locationData = {};
      if (shopData.isNotEmpty) {
        locationData = {
          'area': shopData['area']?.toString() ?? '',
          'address': shopData['address']?.toString() ?? '',
          'city': shopData['city']?.toString() ?? '',
          'state': shopData['state']?.toString() ?? '',
        };
      } else if (json['location'] != null && json['location'] is Map) {
        locationData = Map<String, dynamic>.from(json['location']);
      }

      return PromotionItem(
        id: _parseId(json['id']),
        shopId: _parseId(json['shopId']),
        shopName: shopName,
        shopImage: shopImage,
        location: locationData,
        promotionTitle: json['title']?.toString() ?? 'No Title',
        actualPrice: json['actualPrice']?.toString() ?? '0',
        sellingPrice: json['sellingPrice']?.toString() ?? '0',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        subCategory: json['subCategory']?.toString() ?? '',
        mediaLink: json['mediaLink']?.toString() ?? '',
        contentType: json['contentType']?.toString() ?? 'image',
        status: json['status']?.toString() ?? 'active',
        promotionType: json['promotionType']?.toString() ?? 'Free',
        counter: json['counter'] is Map ? Map<String, dynamic>.from(json['counter'])
            : {'like': 0, 'report': 0, 'favourite': 0},
        denialReason: json['denialReason']?.toString() ?? json['denial_reason']?.toString(),
        createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing PromotionItem: $e');
      return _getDefaultPromotionItem();
    }
  }

  static PromotionItem _getDefaultPromotionItem() {
    return PromotionItem(
      id: 0,
      shopId: 0,
      shopName: 'Unknown Shop',
      shopImage: '',
      location: {},
      promotionTitle: 'No Title',
      actualPrice: '0',
      sellingPrice: '0',
      description: '',
      category: '',
      subCategory: '',
      mediaLink: '',
      contentType: 'image',
      status: 'active',
      promotionType: 'Free',
      counter: {'like': 0, 'report': 0, 'favourite': 0},
      denialReason: null,
      createdAt: '',
      updatedAt: '',
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to get discount percentage
  double get discountPercentage {
    try {
      final actual = double.tryParse(actualPrice) ?? 0.0;
      final selling = double.tryParse(sellingPrice) ?? 0.0;
      if (actual > 0 && selling > 0) {
        return ((actual - selling) / actual) * 100;
      }
    } catch (e) {
      print('Error calculating discount: $e');
    }
    return 0.0;
  }

  // Helper method to get location string
  String get locationString {
    try {
      final address = location['address']?.toString() ?? '';
      final area = location['area']?.toString() ?? '';
      final city = location['city']?.toString() ?? '';
      final state = location['state']?.toString() ?? '';

      List<String> parts = [];
      if (address.isNotEmpty) parts.add(address);
      if (area.isNotEmpty) parts.add(area);
      if (city.isNotEmpty) parts.add(city);
      if (state.isNotEmpty) parts.add(state);

      return parts.join(', ');
    } catch (e) {
      print('Error getting location string: $e');
      return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'shopImage': shopImage,
      'location': location,
      'title': promotionTitle,
      'actualPrice': actualPrice,
      'sellingPrice': sellingPrice,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'mediaLink': mediaLink,
      'contentType': contentType,
      'status': status,
      'promotionType': promotionType,
      'counter': counter,
      'denialReason': denialReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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

  factory ShopItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return _getDefaultShopItem();
    }

    try {
      final shopName = json['shopName']?.toString() ?? '';
      final area = json['area']?.toString() ?? '';

      // Validate essential fields
      if (shopName.isEmpty || shopName.toLowerCase() == 'no shop name' || shopName.trim() == 'No Shop Name') {
        throw Exception('Invalid shop data - missing or placeholder shop name');
      }

      if (area.isEmpty || area.toLowerCase() == 'unknown area' || area.trim() == 'Unknown Area') {
        throw Exception('Invalid shop data - missing or placeholder area');
      }

      return ShopItem(
        shopId: PromotionItem._parseId(json['id']),
        shopName: shopName,
        storeImages: json['storeImages'] is Map ? Map<String, dynamic>.from(json['storeImages']) : {},
        categoryHierarchy: json['category_hierarchy'] is List ? List.from(json['category_hierarchy']) : [],
        area: area,
        address: json['address']?.toString() ?? 'Unknown Address',
        description: json['description']?.toString() ?? 'No description available.',
      );
    } catch (e) {
      print('Error parsing ShopItem: $e');
      return _getDefaultShopItem();
    }
  }

  static ShopItem _getDefaultShopItem() {
    return ShopItem(
      shopId: 0,
      shopName: 'Unknown Shop',
      storeImages: {},
      categoryHierarchy: [],
      area: 'Unknown Area',
      address: 'Unknown Address',
      description: 'No description available.',
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

  factory ProductItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return _getDefaultProductItem();
    }

    try {
      return ProductItem(
        id: PromotionItem._parseId(json['id']),
        shopId: PromotionItem._parseId(json['shop_id']),
        title: json['title']?.toString() ?? 'No Title',
        actualPrice: _parseDouble(json['actual_price']),
        sellingPrice: _parseDouble(json['selling_price']),
        description: json['description']?.toString() ?? '',
        images: json['images'] is Map ? Map<String, dynamic>.from(json['images']) : {},
        validity: json['validity']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        subCategory: json['sub_category']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing ProductItem: $e');
      return _getDefaultProductItem();
    }
  }

  static ProductItem _getDefaultProductItem() {
    return ProductItem(
      id: 0,
      shopId: 0,
      title: 'No Title',
      actualPrice: 0.0,
      sellingPrice: 0.0,
      description: '',
      images: {},
      validity: '',
      category: '',
      subCategory: '',
    );
  }

  static double _parseDouble(dynamic value) {
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    } catch (e) {
      print('Error parsing double: $e');
    }
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

  factory UserActivityItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return _getDefaultUserActivityItem();
    }

    try {
      return UserActivityItem(
        id: PromotionItem._parseId(json['id']),
        activityId: PromotionItem._parseId(json['activityId']),
        action: json['action']?.toString() ?? '',
        userId: PromotionItem._parseId(json['userId']),
        activityType: json['activityType']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing UserActivityItem: $e');
      return _getDefaultUserActivityItem();
    }
  }

  static UserActivityItem _getDefaultUserActivityItem() {
    return UserActivityItem(
      id: 0,
      activityId: 0,
      action: '',
      userId: 0,
      activityType: '',
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

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return _getDefaultUserProfile();
    }

    try {
      return UserProfile(
        name: json['name']?.toString() ?? 'N/A',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? 'N/A',
        gender: json['gender']?.toString() ?? 'N/A',
        age: json['age']?.toString() ?? 'N/A',
        place: json['place']?.toString() ?? 'N/A',
        profileImage: json['profile_image']?.toString() ?? 'assets/images/user.jpeg',
      );
    } catch (e) {
      print('Error parsing UserProfile: $e');
      return _getDefaultUserProfile();
    }
  }

  static UserProfile _getDefaultUserProfile() {
    return UserProfile(
      name: 'N/A',
      phone: '',
      email: 'N/A',
      gender: 'N/A',
      age: 'N/A',
      place: 'N/A',
      profileImage: 'assets/images/user.jpeg',
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
