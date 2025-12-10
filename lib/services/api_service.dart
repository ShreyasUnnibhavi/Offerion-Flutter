// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  final String _baseUrl = 'https://api-offerion.lattech.in/api';
  String? _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  dynamic _validateAndDecodeResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'HTTP Error ${response.statusCode}';
        throw Exception(errorMessage);
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) {
          rethrow;
        }
        throw Exception('HTTP Error ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}');
      }
    }

    if (response.body.trim().isEmpty) {
      throw Exception('Empty response body');
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Invalid JSON response: ${response.body}');
    }
  }

  // FIXED REGISTER USER - Phone as Integer
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      // Ensure phone is sent as integer
      final data = {
        "name": userData['name'],
        "phone": userData['phone'], // Must be int!
        "email": userData['email'],
        "gender": userData['gender'],
        "age": userData['age'],
        "place": userData['place'],
        "account_type": userData['account_type'] ?? 'user',
        "profile_image": userData['profile_image'] ?? "https://example.com/default.jpg",
        if (userData['shop_id'] != null) "shop_id": userData['shop_id'],
      };

      print('Registering user with data: $data');

      final response = await http.post(
        Uri.parse('$_baseUrl/user'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      final decoded = _validateAndDecodeResponse(response);

      // Extract userId from various possible response formats
      int? userId;
      if (decoded['userId'] != null) {
        userId = decoded['userId'] is int ? decoded['userId'] : int.tryParse(decoded['userId'].toString());
      } else if (decoded['user_id'] != null) {
        userId = decoded['user_id'] is int ? decoded['user_id'] : int.tryParse(decoded['user_id'].toString());
      } else if (decoded['data'] != null && decoded['data']['id'] != null) {
        userId = decoded['data']['id'] is int ? decoded['data']['id'] : int.tryParse(decoded['data']['id'].toString());
      } else if (decoded['id'] != null) {
        userId = decoded['id'] is int ? decoded['id'] : int.tryParse(decoded['id'].toString());
      }

      // Store token if provided
      if (decoded['token'] != null) {
        setToken(decoded['token']);
      }

      // Return userId in standard format
      final result = Map<String, dynamic>.from(decoded);
      if (userId != null) {
        result['userId'] = userId;
      }

      print('Registration successful. User ID: $userId');
      return result;
    } catch (e) {
      print('Register User Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      // Handle specific API errors
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('duplicate') || errorMessage.contains('already exists')) {
        errorMessage = 'This phone number or email is already registered. Please use different credentials or sign in instead.';
      }

      throw Exception(errorMessage);
    }
  }

  // FIXED SEND OTP - Phone as String
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      if (phone.trim().isEmpty) {
        throw Exception('Phone number cannot be empty');
      }

      // Clean phone number (remove any non-digits)
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length != 10) {
        throw Exception('Please enter a valid 10-digit phone number');
      }

      print('Sending OTP to: $cleanPhone');
      final response = await http.post(
        Uri.parse('$_baseUrl/user/send-otp'),
        headers: _headers,
        body: jsonEncode({
          'userId': 0, // Will be ignored by server for registration
          'phone': cleanPhone, // Send as string
        }),
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      print('Send OTP Response: $data');
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Send OTP Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('not found') || errorMessage.contains('does not exist')) {
        errorMessage = 'Phone number not registered. Please sign up first.';
      }

      throw Exception(errorMessage);
    }
  }

  // FIXED VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp(int userId, int otp) async {
    try {
      print('Verifying OTP for user: $userId, OTP: $otp');
      final response = await http.post(
        Uri.parse('$_baseUrl/user/verify-otp'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);

      // Store token if provided
      if (data['token'] != null) {
        setToken(data['token']);
        print('Token received and stored: ${data['token']}');
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Verify OTP Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('invalid') || errorMessage.contains('expired') || errorMessage.contains('wrong')) {
        errorMessage = 'Invalid or expired OTP. Please try again.';
      }

      throw Exception(errorMessage);
    }
  }

  Future<UserProfile> getUserDetails(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception('Invalid user ID');
      }

      print('Getting user details for: $userId');
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      final userData = data['data'] ?? data;
      return UserProfile.fromJson(userData);
    } catch (e) {
      print('Get User Details Error: $e');
      if (e.toString().contains('401')) {
        throw Exception('Session expired. Please login again.');
      }
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<UserActivityItem>> getUserActivities(int userId, String activityType) async {
    try {
      print('Getting user activities for: $userId, type: $activityType');
      final response = await http.get(
        Uri.parse('$_baseUrl/useractivity?userId=$userId&activityType=$activityType'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> activitiesData = [];

      if (data is List) {
        activitiesData = data;
      } else if (data is Map) {
        if (data['data'] != null && data['data'] is List) {
          activitiesData = data['data'];
        } else if (data['activities'] != null && data['activities'] is List) {
          activitiesData = data['activities'];
        }
      }

      return activitiesData.map((json) => UserActivityItem.fromJson(json)).toList();
    } catch (e) {
      print('Get User Activities Error: $e');
      if (e.toString().contains('401')) {
        throw Exception('Session expired. Please login again.');
      }
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }

      return []; // Return empty list on error
    }
  }

  Future<List<CategoryItem>> getCategories() async {
    try {
      print('Getting categories');
      final response = await http.get(
        Uri.parse('$_baseUrl/category/all'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> categoriesData = [];

      if (data is List) {
        categoriesData = data;
      } else if (data is Map) {
        if (data['data'] != null && data['data'] is List) {
          categoriesData = data['data'];
        } else if (data['categories'] != null && data['categories'] is List) {
          categoriesData = data['categories'];
        } else if (data['result'] != null && data['result'] is List) {
          categoriesData = data['result'];
        }
      }

      return categoriesData.map((json) => CategoryItem.fromJson(json)).toList();
    } catch (e) {
      print('Get Categories Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load categories: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<BannerItem>> getBanners() async {
    try {
      print('Getting banners');
      final response = await http.get(
        Uri.parse('$_baseUrl/banner/list'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> bannersData = [];

      if (data is List) {
        bannersData = data;
      } else if (data is Map) {
        if (data['data'] != null && data['data'] is Map && data['data']['banners'] is List) {
          bannersData = data['data']['banners'];
        } else if (data['data'] != null && data['data'] is List) {
          bannersData = data['data'];
        } else if (data['banners'] != null && data['banners'] is List) {
          bannersData = data['banners'];
        } else if (data['result'] != null && data['result'] is List) {
          bannersData = data['result'];
        }
      }

      return bannersData.map((json) => BannerItem.fromJson(json)).toList();
    } catch (e) {
      print('Get Banners Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load banners: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<PromotionItem>> getPromotions({int page = 1, int limit = 10}) async {
    try {
      print('Getting promotions from API - Page: $page, Limit: $limit');
      final response = await http.get(
        Uri.parse('$_baseUrl/promotions?page=$page&limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> promotionsData = [];

      if (data is Map) {
        if (data['data'] != null && data['data']['promotions'] is List) {
          promotionsData = data['data']['promotions'];
        } else if (data['data'] != null && data['data'] is List) {
          promotionsData = data['data'];
        } else if (data['promotions'] != null && data['promotions'] is List) {
          promotionsData = data['promotions'];
        }
      } else if (data is List) {
        promotionsData = data;
      }

      print('Total promotions loaded: ${promotionsData.length}');
      return promotionsData.map((json) => PromotionItem.fromJson(json)).toList();
    } catch (e) {
      print('Get Promotions Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load promotions: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<PromotionItem>> getOffersByShop(int shopId) async {
    try {
      if (shopId <= 0) {
        throw Exception('Invalid shop ID');
      }

      print('Getting offers for shop: $shopId');
      final response = await http.get(
        Uri.parse('$_baseUrl/promotions?shop_id=$shopId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> offersData = [];

      if (data is List) {
        offersData = data;
      } else if (data is Map) {
        if (data['data'] != null && data['data']['promotions'] is List) {
          offersData = data['data']['promotions'];
        } else if (data['data'] != null && data['data'] is List) {
          offersData = data['data'];
        } else if (data['offers'] != null && data['offers'] is List) {
          offersData = data['offers'];
        } else if (data['promotions'] != null && data['promotions'] is List) {
          offersData = data['promotions'];
        }
      }

      return offersData.map((json) => PromotionItem.fromJson(json)).toList();
    } catch (e) {
      print('Get Offers by Shop Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load shop offers: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<ProductItem> getProductDetails(int productId) async {
    try {
      if (productId <= 0) {
        throw Exception('Invalid product ID');
      }

      print('Getting product details for: $productId');
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$productId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      final productData = data['data'] ?? data;
      return ProductItem.fromJson(productData);
    } catch (e) {
      print('Get Product Details Error: $e');
      if (e.toString().contains('404')) {
        throw Exception('Product not found.');
      }
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load product details: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<ProductItem>> getProductsByShop(int shopId) async {
    try {
      if (shopId <= 0) {
        throw Exception('Invalid shop ID');
      }

      print('Getting products for shop: $shopId');
      final response = await http.get(
        Uri.parse('$_baseUrl/product?shop_id=$shopId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> productsData = [];

      if (data is List) {
        productsData = data;
      } else if (data is Map) {
        if (data['data'] != null && data['data'] is List) {
          productsData = data['data'];
        } else if (data['products'] != null && data['products'] is List) {
          productsData = data['products'];
        } else if (data['result'] != null && data['result'] is List) {
          productsData = data['result'];
        }
      }

      return productsData.map((json) => ProductItem.fromJson(json)).toList();
    } catch (e) {
      print('Get Products by Shop Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load shop products: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<ShopItem>> getShopsByCategory(String categoryName) async {
    try {
      print('Getting shops for category: $categoryName');
      final response = await http.get(
        Uri.parse('$_baseUrl/shop'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      List<dynamic> shopsData = [];

      if (data is Map && data['data'] != null && data['data']['shops'] is List) {
        shopsData = data['data']['shops'];
      } else if (data is Map && data['data'] is List) {
        shopsData = data['data'];
      } else if (data is List) {
        shopsData = data;
      }

      List<ShopItem> validShops = [];
      for (var shopJson in shopsData) {
        try {
          final shop = ShopItem.fromJson(shopJson);
          if (shop.shopName != 'Unknown Shop') {
            validShops.add(shop);
          }
        } catch (e) {
          print('Skipping invalid shop: $e');
        }
      }

      print('Total valid shops loaded: ${validShops.length}');

      if (categoryName.toLowerCase() != 'any' && categoryName.toLowerCase() != 'all') {
        final filtered = validShops.where((shop) {
          try {
            final matches = shop.categoryHierarchy.any((cat) {
              if (cat is Map && cat['category'] != null) {
                print('Checking category: ${cat['category']} against $categoryName');
                return cat['category'].toString().toLowerCase() == categoryName.toLowerCase();
              }
              return false;
            });
            return matches;
          } catch (e) {
            print('Error filtering shop category: $e');
            return false;
          }
        }).toList();

        print('Filtered shops for $categoryName: ${filtered.length}');
        return filtered;
      }

      return validShops;
    } catch (e) {
      print('Get Shops by Category Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load shops: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<ShopItem> getShopDetails(int shopId) async {
    try {
      if (shopId <= 0) {
        throw Exception('Invalid shop ID');
      }

      print('Getting shop details for: $shopId');
      final response = await http.get(
        Uri.parse('$_baseUrl/shop/$shopId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      final shopData = data['data'] ?? data;
      return ShopItem.fromJson(shopData);
    } catch (e) {
      print('Get Shop Details Error: $e');
      if (e.toString().contains('404')) {
        throw Exception('Shop not found.');
      }
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Unable to load shop details: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      if (filePath.trim().isEmpty) {
        throw Exception('File path cannot be empty');
      }

      print('Uploading image: $filePath');
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/general/uploadimage'));

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      final data = _validateAndDecodeResponse(response);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Upload Image Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Upload timed out. Please try again.');
      }

      throw Exception('Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<String>> getLocations() async {
    try {
      print('Getting locations');
      final shops = await getShopsByCategory('Any');
      final locations = shops.map((shop) => shop.area).where((area) => area.isNotEmpty).toSet().toList();
      return locations;
    } catch (e) {
      print('Get Locations Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addActivity({
    required int shopId,
    required int userId,
    required String activityType,
    required String action,
    required int activityId,
  }) async {
    try {
      if (shopId <= 0 || userId <= 0 || activityId <= 0) {
        throw Exception('Invalid IDs provided');
      }

      print('Adding activity: $action for $activityType with ID: $activityId');
      final response = await http.post(
        Uri.parse('$_baseUrl/activity'),
        headers: _headers,
        body: jsonEncode({
          'shopId': shopId,
          'userId': userId,
          'activityType': activityType,
          'action': action,
          'activityId': activityId,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = _validateAndDecodeResponse(response);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Add Activity Error: $e');
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }

      throw Exception('Failed to update activity: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
