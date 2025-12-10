// lib/pages/common/helper_widgets.dart

import 'package:flutter/material.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/pages/vendor_info/vendor_info.dart';
import 'package:offerion/utils/app_constants.dart';

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
          try {
            final label = categoryNames.length > index ? categoryNames[index] : '';
            final image = categoryImages.length > index ? categoryImages[index] : '';
            final isSelected = selectedCategory == label;

            return CategoryItem(
              image: image,
              label: label,
              isSelected: isSelected,
              onTap: () => onCategorySelected(label),
            );
          } catch (e) {
            print('Error building category item at index $index: $e');
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String image;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
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
              child: _buildImageWidget(),
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

  Widget _buildImageWidget() {
    try {
      if (image.startsWith('assets')) {
        return Image.asset(
          image,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $image, error: $error');
            return const Icon(Icons.error, color: Colors.red, size: 50);
          },
        );
      } else if (image.isNotEmpty) {
        return Image.network(
          image,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $image, error: $error');
            return const Icon(Icons.error, color: Colors.red, size: 50);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 50,
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );
      }
    } catch (e) {
      print('Error building image widget: $e');
    }

    return const Icon(Icons.error, color: Colors.red, size: 50);
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
            try {
              scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              print('Error scrolling to top: $e');
            }
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
    try {
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
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.inbox, size: 200, color: Colors.grey);
                  },
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
          try {
            if (index < promotions.length) {
              return PromotionCard(promotion: promotions[index]);
            } else {
              return _buildBackToTopButton();
            }
          } catch (e) {
            print('Error building promotion item at index $index: $e');
            return const SizedBox.shrink();
          }
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      );
    } catch (e) {
      print('Error building promotions page: $e');
      return const Center(
        child: Text('Error loading promotions'),
      );
    }
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
    try {
      setState(() {
        _isFavorited = !_isFavorited;
        // TODO: Call the API to add/remove the favorite
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
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
                      try {
                        if (widget.promotion.shopId > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorInfo(shopId: widget.promotion.shopId),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error navigating to vendor info: $e');
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: _buildShopImageDecoration(),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.promotion.locationString.isNotEmpty
                              ? widget.promotion.locationString
                              : 'Location not available',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.promotion.promotionTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (widget.promotion.description.isNotEmpty)
                    Text(
                      widget.promotion.description,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPromotionImage(),
            _buildCounterSection(),
            _buildActionButtons(),
          ],
        ),
      );
    } catch (e) {
      print('Error building promotion card: $e');
      return const SizedBox.shrink();
    }
  }

  DecorationImage? _buildShopImageDecoration() {
    try {
      if (widget.promotion.shopImage.isNotEmpty) {
        return DecorationImage(
          image: NetworkImage(widget.promotion.shopImage),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {
            print('Error loading shop image: ${widget.promotion.shopImage}, error: $error');
          },
        );
      }
    } catch (e) {
      print('Error building shop image decoration: $e');
    }
    return const DecorationImage(
      image: AssetImage("assets/images/offer.webp"),
      fit: BoxFit.cover,
    );
  }

  Widget _buildPromotionImage() {
    try {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: Colors.black26)),
          image: widget.promotion.mediaLink.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(widget.promotion.mediaLink),
            fit: BoxFit.cover,
            onError: (error, stackTrace) {
              print('Error loading promotion image: ${widget.promotion.mediaLink}, error: $error');
            },
          )
              : null,
        ),
        child: widget.promotion.mediaLink.isEmpty
            ? Image.asset(
          defaultImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey));
          },
        )
            : null,
      );
    } catch (e) {
      print('Error building promotion image: $e');
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey)),
      );
    }
  }

  Widget _buildCounterSection() {
    try {
      final counter = widget.promotion.counter;
      return Container(
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
                Text('${counter['like'] ?? 0} Likes', style: const TextStyle(fontSize: 18)),
              ],
            ),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 20, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${counter['favourite'] ?? 0} Favorites', style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 20, color: Colors.yellow),
                    const SizedBox(width: 2),
                    Text('${counter['report'] ?? 0} Reports', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building counter section: $e');
      return Container(
        height: 40,
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.07)),
        child: const Center(child: Text('0 Likes • 0 Favorites • 0 Reports')),
      );
    }
  }

  Widget _buildActionButtons() {
    try {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: () {
              try {
                setState(() {
                  _isLiked = !_isLiked;
                });
              } catch (e) {
                print('Error toggling like: $e');
              }
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
            onPressed: () {
              // TODO: Implement report functionality
            },
            icon: const Icon(Icons.flag_outlined, size: 20),
            label: const Text('Report', style: TextStyle(fontSize: 20)),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          ),
        ],
      );
    } catch (e) {
      print('Error building action buttons: $e');
      return const SizedBox.shrink();
    }
  }
}
