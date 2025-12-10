// lib/pages/favourites_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/pages/offers_page/offers_page.dart';
import 'package:offerion/pages/sale_details_page/sale_details_page.dart';

// You will need to create a `FavoriteManager` utility class
// For demonstration, here's a basic implementation
class FavoriteManager {
  static final Map<String, List<dynamic>> _favorites = {};

  static void toggleFavorite(String type, dynamic item, int userId) {
    if (!_favorites.containsKey(type)) {
      _favorites[type] = [];
    }
    final isFavorited = _favorites[type]!.any((element) => element.id == item.id);

    if (isFavorited) {
      _favorites[type]!.removeWhere((element) => element.id == item.id);
      // TODO: Call API to remove from favorites
    } else {
      _favorites[type]!.add(item);
      // TODO: Call API to add to favorites
    }
  }

  static bool isItemFavorited(dynamic item) {
    final type = item.runtimeType.toString();
    if (_favorites.containsKey(type)) {
      return _favorites[type]!.any((element) => element.id == item.id);
    }
    return false;
  }

  static List<dynamic> getFavorites(String type) {
    return _favorites[type] ?? [];
  }
}


class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final int _userId = 1; // Placeholder user ID

  late Future<List<UserActivityItem>> _favouriteProductsFuture;
  late Future<List<UserActivityItem>> _favouriteOffersFuture;
  late Future<List<UserActivityItem>> _favouritePromotionsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _favouriteProductsFuture = _apiService.getUserActivities(_userId, 'products');
    _favouriteOffersFuture = _apiService.getUserActivities(_userId, 'offers');
    _favouritePromotionsFuture = _apiService.getUserActivities(_userId, 'promotions');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Offerion",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Offers'),
                Tab(text: 'Promotions'),
                Tab(text: 'Products'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesList(_favouriteOffersFuture, 'offer'),
          _buildFavoritesList(_favouritePromotionsFuture, 'promotions'),
          _buildFavoritesList(_favouriteProductsFuture, 'products'),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(Future<List<UserActivityItem>> future, String type) {
    return FutureBuilder<List<UserActivityItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final favorites = snapshot.data!;
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet.\nStart adding some!', textAlign: TextAlign.center));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              // You'll need to fetch the full details of the item based on its ID
              return ListTile(
                title: Text('Favorite ID: ${item.activityId}'),
                subtitle: Text('Type: ${item.activityType}'),
              );
            },
          );
        } else {
          return const Center(child: Text('No data available.'));
        }
      },
    );
  }
}