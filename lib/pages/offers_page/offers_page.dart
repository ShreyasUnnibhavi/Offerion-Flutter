// lib/pages/offers_page/offers_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/pages/vendor_info/vendor_info.dart';
import 'package:offerion/utils/app_constants.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';
import 'package:intl/intl.dart';

class OfferPage extends StatefulWidget {
  final int? initialTabIndex;
  const OfferPage({super.key, this.initialTabIndex});

  @override
  State<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  late Future<List<CategoryItem>> _categoriesFuture;
  late Future<List<PromotionItem>> _promotionsFuture;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _categoriesFuture = _apiService.getCategories();
    _promotionsFuture = _apiService.getPromotions();
  }

  void _filterContent(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _promotionsFuture = _apiService.getPromotions();
      } else {
        _promotionsFuture = _apiService.getPromotions().then((promotions) {
          return promotions.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: FutureBuilder<List<CategoryItem>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final categories = snapshot.data!;
              final displayCategoryImages = [
                "assets/images/all.webp",
                ...categories.map((e) => e.image)
              ];
              final displayCategoryNames = [
                "All",
                ...categories.map((e) => e.category)
              ];
              return CategoryFilterBar(
                categoryImages: displayCategoryImages,
                categoryNames: displayCategoryNames,
                selectedCategory: _selectedCategory,
                onCategorySelected: _filterContent,
              );
            } else {
              return const Center(child: Text('No categories found.'));
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(child: Text('Promotions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Tab(child: Text('Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<PromotionItem>>(
            future: _promotionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return PromotionsPage(
                  promotions: snapshot.data!,
                  scrollController: _scrollController,
                );
              } else {
                return const Center(child: Text('No promotions available.'));
              }
            },
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No offers available at the moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFilterBar extends StatelessWidget {
  final List<String> categoryImages;
  final List<String> categoryNames;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categoryImages,
    required this.categoryNames,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
        gradient: LinearGradient(
          begin: Alignment(0.0, -3.0),
          end: Alignment(0.0, 0.70),
          colors: [Color.fromRGBO(220, 53, 69, 0.02), Colors.white],
        ),
      ),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final label = categoryNames[index];
          final image = categoryImages[index];
          final isSelected = selectedCategory == label;
          return OfferCategoryItem(
            image: image,
            label: label,
            isSelected: isSelected,
            onTap: () => onCategorySelected(label),
          );
        },
      ),
    );
  }
}

class OfferCategoryItem extends StatelessWidget {
  final String image;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const OfferCategoryItem({
    super.key,
    required this.image,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.transparent,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: image.startsWith('assets')
                  ? Image.asset(image, width: 50, height: 50)
                  : Image.network(
                image,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.red : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionsPage extends StatelessWidget {
  final List<PromotionItem> promotions;
  final ScrollController scrollController;

  const PromotionsPage({
    super.key,
    required this.promotions,
    required this.scrollController,
  });

  Widget _buildBackToTopButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Back to top", style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_upward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/nothingToShow.png",
                width: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nothing here yet - check back soon or explore other sections !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: promotions.length + 1,
      itemBuilder: (context, index) {
        if (index < promotions.length) {
          return PromotionCard(promotion: promotions[index]);
        } else {
          return _buildBackToTopButton();
        }
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

class PromotionCard extends StatefulWidget {
  final PromotionItem promotion;
  const PromotionCard({super.key, required this.promotion});

  @override
  State<PromotionCard> createState() => _PromotionCardState();
}

class _PromotionCardState extends State<PromotionCard> {
  bool _isLiked = false;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 0, 8.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorInfo(shopId: widget.promotion.shopId),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: widget.promotion.shopImage.isNotEmpty
                            ? NetworkImage(widget.promotion.shopImage)
                            : const AssetImage("assets/images/offer.webp") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.promotion.shopName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.promotion.locationString.isNotEmpty
                            ? widget.promotion.locationString
                            : 'Location not available',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            widget.promotion.status.toUpperCase(),
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              widget.promotion.description.isNotEmpty
                  ? widget.promotion.description
                  : widget.promotion.promotionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: Colors.black26)),
              image: widget.promotion.mediaLink.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(widget.promotion.mediaLink),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.promotion.mediaLink.isEmpty
                ? Image.asset(defaultImage, fit: BoxFit.cover)
                : null,
          ),
          Container(
            height: 40,
            decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.07)),
            padding: const EdgeInsets.only(left: 12.0, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 20, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${widget.promotion.counter['like'] ?? 0} Likes',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 20, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${widget.promotion.counter['favourite'] ?? 0} Favorites',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 20, color: Colors.yellow),
                        const SizedBox(width: 2),
                        Text('${widget.promotion.counter['report'] ?? 0} Reports',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                icon: Icon(
                  _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 20,
                  color: _isLiked ? Colors.blue : Colors.black54,
                ),
                label: Text(
                  'Like',
                  style: TextStyle(
                    fontSize: 20,
                    color: _isLiked ? Colors.blue : Colors.black54,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
              ),
              TextButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _isFavorited ? Colors.red : Colors.black54,
                ),
                label: Text(
                  'Favorite',
                  style: TextStyle(
                    fontSize: 20,
                    color: _isFavorited ? Colors.red : Colors.black54,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.flag_outlined, size: 20),
                label: const Text('Report', style: TextStyle(fontSize: 20)),
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OffersTabPage extends StatelessWidget {
  final List<DynamicOfferData> offers;
  final ScrollController? scrollController;

  const OffersTabPage({super.key, required this.offers, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/nothingToShow.png",
                  width: 300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nothing here yet - check back soon or explore other sections !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return DynamicOfferCard(offer: offers[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
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
}

class DynamicOfferCard extends StatefulWidget {
  final DynamicOfferData offer;
  const DynamicOfferCard({super.key, required this.offer});

  @override
  State<DynamicOfferCard> createState() => _DynamicOfferCardState();
}

class _DynamicOfferCardState extends State<DynamicOfferCard> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorInfo(shopId: widget.offer.shopId),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: Colors.grey.shade400,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Featured Offer",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.offer.location,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorited = !_isFavorited;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: widget.offer.offerImage.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(widget.offer.offerImage),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: widget.offer.offerImage.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_size_select_actual_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No Image Found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.offer.offerTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Discounts on ${widget.offer.offerTitle}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('Validity:', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 4),
                              Text(
                                'Coming Soon',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 150,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VendorInfo(shopId: widget.offer.shopId),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'VIEW OFFER',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
