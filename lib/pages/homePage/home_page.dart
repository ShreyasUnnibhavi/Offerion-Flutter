// lib/pages/homePage/home_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/pages/banners/banners.dart';
import 'package:offerion/pages/brand_list_page/brand_list_page.dart';
import 'package:offerion/pages/categories/categories.dart';
import 'package:offerion/pages/offers_page/offers_page.dart';
import 'package:offerion/pages/profile/profile.dart';
import 'package:offerion/utils/app_constants.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  late Future<List<BannerItem>> _bannersFuture;
  late Future<List<CategoryItem>> _categoriesFuture;
  late Future<List<PromotionItem>> _promotionsFuture;
  late Future<List<ShopItem>> _featuredClothShopsFuture;
  late Future<List<ShopItem>> _featuredElectronicShopsFuture;
  late Future<List<ShopItem>> _featuredRestaurantShopsFuture;
  late Future<List<ShopItem>> _featuredFootwearShopsFuture;
  late Future<List<ShopItem>> _featuredMobileShopsFuture;

  String? selectedCardImage;
  String? selectedCardTitle;
  bool _showLocationCard = false;
  String _selectedLocation = "Set Location";

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  void _initializeFutures() {
    _bannersFuture = _apiService.getBanners();
    _categoriesFuture = _apiService.getCategories();
    _promotionsFuture = _apiService.getPromotions();
    _featuredClothShopsFuture = _apiService.getShopsByCategory("Cloth");
    _featuredElectronicShopsFuture = _apiService.getShopsByCategory("Electronics");
    _featuredRestaurantShopsFuture = _apiService.getShopsByCategory("Restaurant");
    _featuredFootwearShopsFuture = _apiService.getShopsByCategory("Footwear");
    _featuredMobileShopsFuture = _apiService.getShopsByCategory("Mobile");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void showCard(String imagePath, String title) {
    setState(() {
      selectedCardImage = imagePath;
      selectedCardTitle = title;
    });
  }

  void hideCard() {
    setState(() {
      selectedCardImage = null;
      selectedCardTitle = null;
    });
  }

  void _showLocationCardDialog() {
    setState(() {
      _showLocationCard = true;
    });
  }

  void _hideLocationCardDialog() {
    setState(() {
      _showLocationCard = false;
    });
  }

  void _updateLocation(String newLocation) {
    setState(() {
      _selectedLocation = newLocation;
    });
    _hideLocationCardDialog();
  }

  void _navigateToBrandPage(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandListPage(
          title: categoryName,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage, VoidCallback onRetry) {
    String cleanError = errorMessage.replaceAll('Exception: ', '');
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                cleanError,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offerion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.9),
        centerTitle: true,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.white
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    color: Color.fromRGBO(220, 53, 69, 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: TextButton(
                              onPressed: _showLocationCardDialog,
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white, size: 24),
                                  Text(_selectedLocation, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 21,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage("assets/images/user.jpeg"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                        child: SizedBox(
                          height: 45,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.transparent)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.transparent)
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Shop name or Products...",
                              hintStyle: const TextStyle(fontSize: 18),
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search, color: Color.fromRGBO(220, 53, 69, 1), size: 30),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("#SpecialForYou", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                      InkWell(
                        child: const Text("See all", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Banners()));
                        },
                      ),
                    ],
                  ),
                ),
                // Banners Section with Error Handling
                SizedBox(
                  height: 220,
                  child: FutureBuilder<List<BannerItem>>(
                    future: _bannersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return _buildErrorWidget(
                            snapshot.error.toString(),
                                () => setState(() => _bannersFuture = _apiService.getBanners())
                        );
                      } else if (snapshot.hasData) {
                        final banners = snapshot.data!;
                        if (banners.isEmpty) {
                          return const Center(child: Text('No banners available at the moment.'));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: banners.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  banners[index].image,
                                  width: 418,
                                  height: 220,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      defaultImage,
                                      width: 418,
                                      height: 220,
                                      fit: BoxFit.fill,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No banners found.'));
                      }
                    },
                  ),
                ),
                // Categories Section
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment(0.0, -8.0),
                        end: Alignment(0.0, 0.75),
                        colors: [Color.fromRGBO(220, 53, 69, 0.02), Colors.white]
                    ),
                    border: Border(
                      top: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                      bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                  child: Text("Trending categories filled with offers", style: TextStyle(fontSize: 16, color: Color.fromRGBO(0, 0, 0, 0.5))),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Categories()));
                                },
                                child: const Text("See all", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Categories Grid with Error Handling
                        FutureBuilder<List<CategoryItem>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                  height: 100,
                                  child: Center(child: CircularProgressIndicator())
                              );
                            } else if (snapshot.hasError) {
                              return SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline, size: 32, color: Colors.red),
                                        const SizedBox(height: 4),
                                        Text(
                                          snapshot.error.toString().replaceAll('Exception: ', ''),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        ElevatedButton(
                                          onPressed: () => setState(() => _categoriesFuture = _apiService.getCategories()),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          ),
                                          child: const Text('Retry', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  )
                              );
                            } else if (snapshot.hasData) {
                              final categories = snapshot.data!;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categories.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                ),
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(category.image),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Image.network(
                                              category.image,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Image.asset(defaultImage, fit: BoxFit.fill)
                                          ),
                                        ),
                                        onTap: () {
                                          _navigateToBrandPage(context, category.category);
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        category.category,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              return const Center(child: Text('No categories found.'));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(33, 37, 41, 0.03),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/images/offer.webp"),
                        ),
                        title: const Text("Newly Featured Offers!", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text("Trending Offers just for you"),
                        trailing: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferPage(initialTabIndex: 1)));
                            },
                            child: const Text("See all", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold))
                        ),
                      ),
                      // Fixed overflow in "Newly Featured Offers"
                      SizedBox(
                        height: 250,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/nothingToShow.png",
                                  width: 150,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No offers available at the moment.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Latest Launches Section with fixed location width
                ListTile(
                  tileColor: Colors.white,
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/offer.webp"),
                  ),
                  title: const Text("Latest Launches", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Trending Offers just for you"),
                  trailing: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferPage(initialTabIndex: 0)));
                      },
                      child: const Text("See all", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold))
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: 300,
                  child: FutureBuilder<List<PromotionItem>>(
                    future: _promotionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return _buildErrorWidget(
                            snapshot.error.toString(),
                                () => setState(() => _promotionsFuture = _apiService.getPromotions())
                        );
                      } else if (snapshot.hasData) {
                        final promotions = snapshot.data!;
                        if (promotions.isEmpty) {
                          return const Center(child: Text('No latest launches available.'));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: promotions.length,
                          itemBuilder: (context, index) {
                            final item = promotions[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 5.0, bottom: 8, left: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showCard(item.mediaLink, item.promotionTitle);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item.mediaLink,
                                        height: 240,
                                        width: 175,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            defaultImage,
                                            height: 240,
                                            width: 175,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 159, // Fixed width to match image width (175 - 16 padding)
                                          child: Text(
                                            item.promotionTitle,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 159, // Fixed width to match image width
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.red, size: 16),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item.locationString.isNotEmpty ? item.locationString : "Location not available",
                                                  style: const TextStyle(fontSize: 16),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No latest launches found.'));
                      }
                    },
                  ),
                ),
                // Featured Sections
                _buildFeaturedSection("Featured cloth brands", "Cloth", _featuredClothShopsFuture),
                _buildFeaturedSection("Featured electronic brands", "Electronics", _featuredElectronicShopsFuture),
                _buildFeaturedSection("Featured Restaurant brands", "Restaurant", _featuredRestaurantShopsFuture),
                _buildFeaturedSection("Featured Footwear brands", "Footwear", _featuredFootwearShopsFuture),
                _buildFeaturedSection("Featured Mobile brands", "Mobile", _featuredMobileShopsFuture),
                Container(
                  height: 8,
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Prime Offers", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.decelerate,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Back to top", style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_upward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Location Card Overlay
          if (_showLocationCard)
            GestureDetector(
              onTap: _hideLocationCardDialog,
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      const begin = Offset(0.0, -1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;
                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                    child: LocationCard(
                      key: ValueKey(_showLocationCard),
                      onClose: _hideLocationCardDialog,
                      onLocationSelected: _updateLocation,
                    ),
                  ),
                ),
              ),
            ),
          // Image Card Overlay
          if (selectedCardImage != null)
            GestureDetector(
              onTap: hideCard,
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 15,
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 500,
                            width: 400,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(selectedCardImage!),
                                  fit: BoxFit.fill
                              ),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: hideCard,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(selectedCardTitle ?? "Offer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
                            child: Text("Upto 50% off", style: TextStyle(fontWeight: FontWeight.w100, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(String title, String category, Future<List<ShopItem>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          color: const Color.fromRGBO(0, 0, 0, 0.15),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  child: const Text("See all", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: () => _navigateToBrandPage(context, category),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 336,
          child: FutureBuilder<List<ShopItem>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 336,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              switch (category) {
                                case "Cloth":
                                  _featuredClothShopsFuture = _apiService.getShopsByCategory("Cloth");
                                  break;
                                case "Electronics":
                                  _featuredElectronicShopsFuture = _apiService.getShopsByCategory("Electronics");
                                  break;
                                case "Restaurant":
                                  _featuredRestaurantShopsFuture = _apiService.getShopsByCategory("Restaurant");
                                  break;
                                case "Footwear":
                                  _featuredFootwearShopsFuture = _apiService.getShopsByCategory("Footwear");
                                  break;
                                case "Mobile":
                                  _featuredMobileShopsFuture = _apiService.getShopsByCategory("Mobile");
                                  break;
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final shops = snapshot.data!;
                if (shops.isEmpty) {
                  return const Center(child: Text('No shops available at the moment.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    final imageUrl = shop.storeImages.isNotEmpty ? shop.storeImages['0'] : null;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFF1F1F1))
                        ),
                        shadowColor: Colors.black,
                        color: Colors.white,
                        elevation: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                              ),
                              child: Image.network(
                                imageUrl ?? '',
                                height: 200,
                                width: 350,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(defaultImage, height: 200, width: 350, fit: BoxFit.fill);
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                              child: Text(shop.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                                  Text(shop.area, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            Container(
                              width: 350,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(33, 37, 41, 0.03),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage("assets/images/offer.webp"),
                                  ),
                                  SizedBox(width: 5),
                                  Text("Coming Soon", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No shops found.'));
              }
            },
          ),
        ),
      ],
    );
  }
}

class LocationCard extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onLocationSelected;

  const LocationCard({
    super.key,
    required this.onClose,
    required this.onLocationSelected,
  });

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  final TextEditingController _locationSearchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _locationSearchController.addListener(_filterLocations);
  }

  Future<void> _fetchLocations() async {
    try {
      final shops = await _apiService.getShopsByCategory("Any");
      final uniqueLocations = shops.map((shop) => shop.area).toSet().toList();
      if (mounted) {
        setState(() {
          _filteredLocations = uniqueLocations;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch locations: $e');
    }
  }

  void _filterLocations() {
    final query = _locationSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _fetchLocations();
      } else {
        _filteredLocations = _filteredLocations
            .where((location) => location.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationSearchController,
              decoration: const InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = _filteredLocations[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(location),
                    onTap: () {
                      widget.onLocationSelected(location);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }
}
