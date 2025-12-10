// lib/pages/vendor_info/vendor_info.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offerion/utils/app_constants.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';

class VendorInfo extends StatefulWidget {
  final int shopId;
  const VendorInfo({super.key, required this.shopId});

  @override
  State<VendorInfo> createState() => _VendorInfoState();
}

class _VendorInfoState extends State<VendorInfo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _offersScrollController = ScrollController();
  final ScrollController _promoScrollController = ScrollController();
  final ScrollController _newScrollController = ScrollController();
  final ScrollController _saleScrollController = ScrollController();
  late Future<ShopItem> _vendorInfoFuture;
  late Future<List<ProductItem>> _productsFuture;
  late Future<List<PromotionItem>> _promotionsFuture;
  late Future<List<ProductItem>> _salesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _vendorInfoFuture = _apiService.getShopDetails(widget.shopId);
    _productsFuture = _apiService.getProductsByShop(widget.shopId);
    _promotionsFuture = _apiService.getOffersByShop(widget.shopId);
    _salesFuture = _apiService.getProductsByShop(widget.shopId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _offersScrollController.dispose();
    _promoScrollController.dispose();
    _newScrollController.dispose();
    _saleScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(210.0),
        child: FutureBuilder<ShopItem>(
          future: _vendorInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Failed to load vendor info.');
            } else if (snapshot.hasData) {
              final vendor = snapshot.data!;
              return VendorAppBar(
                vendorName: vendor.shopName,
                vendorLocation: vendor.area,
                offerDescription: vendor.description,
              );
            } else {
              return const Text('No vendor info available.');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOffersTab(),
          _buildPromotionsTab(),
          _buildNewItemsTab(),
          _buildSalesTab(),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    return FutureBuilder<List<ProductItem>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final offers = snapshot.data!;
          return OffersTabPage(
              offers: offers.map((e) => DynamicOfferData(
                  offerImage: e.images['0'] ?? '',
                  offerTitle: e.title
              )).toList(),
              scrollController: _offersScrollController
          );
        } else {
          return const Center(child: Text('No offers available.'));
        }
      },
    );
  }

  Widget _buildPromotionsTab() {
    return FutureBuilder<List<PromotionItem>>(
      future: _promotionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final promotions = snapshot.data!;
          return PromotionsPage(
              promotions: promotions,
              scrollController: _promoScrollController
          );
        } else {
          return const Center(child: Text('No promotions available.'));
        }
      },
    );
  }

  Widget _buildNewItemsTab() {
    return FutureBuilder<List<ProductItem>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final newItems = snapshot.data!;
          return NewItemsPage(
              newItems: newItems,
              scrollController: _newScrollController
          );
        } else {
          return const Center(child: Text('No new items available.'));
        }
      },
    );
  }

  Widget _buildSalesTab() {
    return FutureBuilder<List<ProductItem>>(
      future: _salesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final sales = snapshot.data!;
          return SalesPage(
              sales: sales,
              scrollController: _saleScrollController
          );
        } else {
          return const Center(child: Text('No sales available.'));
        }
      },
    );
  }
}

// Add the missing SaleDetailsPage class
class SaleDetailsPage extends StatelessWidget {
  final int productId;

  const SaleDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: Color.fromRGBO(220, 53, 69, 1),
            ),
            const SizedBox(height: 16),
            Text(
              'Product Details',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Product ID: $productId',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detailed product information will be displayed here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String vendorName;
  final String vendorLocation;
  final String offerDescription;

  const VendorAppBar({
    super.key,
    required this.vendorName,
    required this.vendorLocation,
    required this.offerDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: const Color.fromRGBO(220, 53, 69, 1),
                            iconSize: 25,
                          ),
                          Text(
                            vendorName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                          padding: EdgeInsets.only(right: 16.0, bottom: 16),
                          child: Icon(
                            Icons.share_outlined,
                            color: Colors.black,
                            size: 20,
                          )
                      )
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vendorName,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(7),
                                          topRight: Radius.circular(7)
                                      )
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "--",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Text(
                              offerDescription,
                              style: const TextStyle(
                                  color: Colors.black38,
                                  fontSize: 20
                              ),
                            ),
                            const Divider(
                              height: 2,
                              color: Colors.black26,
                              endIndent: 80,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Color.fromRGBO(220, 53, 69, 1),
                                ),
                                Text(
                                  vendorLocation,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Color.fromRGBO(220, 53, 69, 0.2),
                          radius: 23,
                          child: Icon(
                              Icons.call,
                              color: Color.fromRGBO(220, 53, 69, 1),
                              size: 25
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Color.fromRGBO(220, 53, 69, 0.2),
                          radius: 23,
                          child: Icon(
                              Icons.share_sharp,
                              color: Color.fromRGBO(220, 53, 69, 1),
                              size: 25
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]
        )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(210.0);
}

class BackToTopButton extends StatelessWidget {
  final ScrollController scrollController;
  const BackToTopButton({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
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
}

class OffersTabPage extends StatelessWidget {
  final List<DynamicOfferData> offers;
  final ScrollController scrollController;

  const OffersTabPage({
    super.key,
    required this.offers,
    required this.scrollController
  });

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
      controller: scrollController,
      itemCount: offers.length + 1,
      itemBuilder: (context, index) {
        if (index < offers.length) {
          return DynamicOfferCard(offer: offers[index]);
        }
        return BackToTopButton(scrollController: scrollController);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

class DynamicOfferData {
  final String offerImage;
  final String offerTitle;
  final String location;
  final String category;

  const DynamicOfferData({
    required this.offerImage,
    required this.offerTitle,
    this.location = 'Unknown Location',
    this.category = 'Unknown Category'
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
  // Removed unused _apiService field

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                    Icons.storefront,
                    color: Colors.grey.shade400,
                    size: 30
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "Featured Offer",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    const SizedBox(height: 2),
                    Text(
                        widget.offer.location,
                        style: const TextStyle(color: Colors.black54, fontSize: 13)
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                            Icons.access_time_filled,
                            size: 14,
                            color: Colors.black54
                        ),
                        const SizedBox(width: 4),
                        Text(
                            DateFormat('d MMMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13
                            )
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
                    // TODO: Call API to toggle favorite
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
                        size: 40
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "No Image Found",
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12
                        )
                    )
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
                                  fontSize: 18
                              )
                          ),
                          const SizedBox(height: 4),
                          Text(
                              "Discounts on ${widget.offer.offerTitle}",
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14
                              )
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
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 150,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                              child: const Text(
                                  'VIEW OFFER',
                                  style: TextStyle(fontWeight: FontWeight.bold)
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

class PromotionsPage extends StatelessWidget {
  final List<PromotionItem> promotions;
  final ScrollController scrollController;

  const PromotionsPage({
    super.key,
    required this.promotions,
    required this.scrollController,
  });

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
          return BackToTopButton(scrollController: scrollController);
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
      // TODO: Call the API to add/remove the favorite
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
                          onTap: () {},
                          child: Container(
                              width: 60,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                      image: AssetImage("assets/images/offer.webp"),
                                      fit: BoxFit.cover
                                  )
                              )
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  "Featured Promoter",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                  'API does not have location',
                                  style: TextStyle(color: Colors.black54, fontSize: 13)
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                  children: [
                                    Icon(
                                        Icons.access_time_filled,
                                        size: 14,
                                        color: Colors.black54
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                        "Coming Soon",
                                        style: TextStyle(color: Colors.black54, fontSize: 13)
                                    )
                                  ]
                              )
                            ]
                        )
                      ]
                  )
              ),
              const SizedBox(height: 12),
              Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                      widget.promotion.promotionTitle,
                      style: const TextStyle(fontSize: 20)
                  )
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
                      fit: BoxFit.cover
                  )
                      : null,
                ),
                child: widget.promotion.mediaLink.isEmpty
                    ? Image.asset(defaultImage, fit: BoxFit.cover)
                    : null,
              ),
              Container(
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.07)
                  ),
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.thumb_up, size: 20, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('0 Likes', style: TextStyle(fontSize: 18))
                            ]
                        ),
                        Row(
                            children: [
                              Row(
                                  children: [
                                    Icon(Icons.favorite, size: 20, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text('0 Favorites', style: TextStyle(fontSize: 18))
                                  ]
                              ),
                              SizedBox(width: 10),
                              Row(
                                  children: [
                                    Icon(Icons.flag, size: 20, color: Colors.yellow),
                                    SizedBox(width: 2),
                                    Text('0 Reports', style: TextStyle(fontSize: 18))
                                  ]
                              )
                            ]
                        )
                      ]
                  )
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
                            color: _isLiked ? Colors.blue : Colors.black54
                        ),
                        label: Text(
                            'Like',
                            style: TextStyle(
                                fontSize: 20,
                                color: _isLiked ? Colors.blue : Colors.black54
                            )
                        ),
                        style: TextButton.styleFrom(foregroundColor: Colors.black54)
                    ),
                    TextButton.icon(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                            _isFavorited ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: _isFavorited ? Colors.red : Colors.black54
                        ),
                        label: Text(
                            'Favorite',
                            style: TextStyle(
                                fontSize: 20,
                                color: _isFavorited ? Colors.red : Colors.black54
                            )
                        ),
                        style: TextButton.styleFrom(foregroundColor: Colors.black54)
                    ),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.flag_outlined, size: 20),
                        label: const Text('Report', style: TextStyle(fontSize: 20)),
                        style: TextButton.styleFrom(foregroundColor: Colors.black54)
                    )
                  ]
              )
            ]
        )
    );
  }
}

class NewItemsPage extends StatelessWidget {
  final List<ProductItem> newItems;
  final ScrollController scrollController;

  const NewItemsPage({
    super.key,
    required this.newItems,
    required this.scrollController
  });

  @override
  Widget build(BuildContext context) {
    if (newItems.isEmpty) {
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
                'No new items to show right now. Check back later!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      controller: scrollController,
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: newItems.length,
      itemBuilder: (context, index) {
        final item = newItems[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SaleDetailsPage(productId: item.id),
              ),
            );
          },
          child: NewCard(item: item),
        );
      },
    );
  }
}

class NewCard extends StatefulWidget {
  final ProductItem item;
  const NewCard({super.key, required this.item});

  @override
  State<NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  bool favorited = false;
  final String defaultImage = "assets/images/noImage.jpeg";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    double newPrice = item.sellingPrice;
    double oldPrice = item.actualPrice;
    final discount = ((oldPrice - newPrice) / oldPrice * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 12,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Image.network(
                      item.images['0'] ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 10,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC3545),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$discount% Off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹ $oldPrice',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹ ${newPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$discount% off',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            favorited = !favorited;
                            // TODO: Call API to toggle favorite
                          });
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: favorited
                                ? const Color(0xFFDC3545).withAlpha(26)
                                : const Color(0xFFDC3545),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Icon(
                            favorited ? Icons.favorite : Icons.favorite_border,
                            color: favorited
                                ? const Color(0xFFDC3545)
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Implement share functionality here if needed
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDC3545)),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Color(0xFFDC3545),
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
    );
  }
}

class SalesPage extends StatefulWidget {
  final List<ProductItem> sales;
  final ScrollController scrollController;

  const SalesPage({
    super.key,
    required this.sales,
    required this.scrollController
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = ['All', 'Electronics', 'Mobiles'];
  String selectedCategory = 'All';
  String searchTerm = '';

  List<ProductItem> get filteredItems {
    List<ProductItem> items = widget.sales;
    if (selectedCategory != 'All') {
      items = items.where((e) => e.category == selectedCategory).toList();
    }
    if (searchTerm.isNotEmpty) {
      items = items
          .where((e) => e.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }
    return items;
  }

  void _onCategorySelect(String cat) {
    setState(() {
      selectedCategory = cat;
    });
  }

  void _onSearch(String val) {
    setState(() {
      searchTerm = val;
    });
  }

  void _clearSearch() {
    setState(() {
      searchTerm = '';
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = filteredItems;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                          Icons.search,
                          color: Color.fromRGBO(220, 53, 69, 1),
                          size: 30
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for products...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 20
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _clearSearch();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color.fromRGBO(220, 53, 69, 1),
                              size: 30,
                            ),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: _onSearch,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, idx) {
                      final isSelected = selectedCategory == categories[idx];
                      return GestureDetector(
                        onTap: () => _onCategorySelect(categories[idx]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFDC3545)
                                  : const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            categories[idx],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFDC3545)
                                  : const Color(0xFF757575),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
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
                  style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final item = filteredProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaleDetailsPage(productId: item.id),
                    ),
                  );
                },
                child: SaleCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SaleCard extends StatefulWidget {
  final ProductItem item;
  const SaleCard({super.key, required this.item});

  @override
  State<SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<SaleCard> {
  bool favorited = false;
  final String defaultImage = "assets/images/noImage.jpeg";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    double newPrice = item.sellingPrice;
    double oldPrice = item.actualPrice;
    final discount = ((1 - (newPrice / oldPrice)) * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 12,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Image.network(
                      item.images['0'] ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 10,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC3545),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$discount% Off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 12,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹ ${oldPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹ ${newPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$discount% off',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            favorited = !favorited;
                            // TODO: Call API to toggle favorite
                          });
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: favorited
                                ? const Color(0xFFDC3545).withAlpha(26)
                                : const Color(0xFFDC3545),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Icon(
                            favorited ? Icons.favorite : Icons.favorite_border,
                            color: favorited
                                ? const Color(0xFFDC3545)
                                : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Implement share functionality here if needed
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDC3545)),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Color(0xFFDC3545),
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
    );
  }
}
