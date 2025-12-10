// lib/pages/sale_details_page/sale_details_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/utils/app_constants.dart';

class SaleDetailsPage extends StatefulWidget {
  final int productId;
  const SaleDetailsPage({super.key, required this.productId});

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  late Future<ProductItem> _productFuture; // Fixed: Added proper type annotation
  final ApiService _apiService = ApiService();
  bool _isFavorited = false;
  final Color _favoriteButtonColor = Colors.yellow.shade700;

  @override
  void initState() {
    super.initState();
    _productFuture = _apiService.getProductDetails(widget.productId);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      // TODO: Call API to toggle favorite
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? _favoriteButtonColor : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<ProductItem>( // Fixed: Added proper type annotation
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!;

            // Fixed: Handle null safety for image URL
            final imageUrl = product.images.isNotEmpty ? product.images['0'] ?? '' : '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed: Check if imageUrl is not empty before using Image.network
                  imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl, // Now guaranteed to be non-null
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(defaultImage, fit: BoxFit.cover, height: 400),
                  )
                      : Image.asset(defaultImage, fit: BoxFit.cover, height: 400),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '₹${product.sellingPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '₹${product.actualPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${((1 - (product.sellingPrice / product.actualPrice)) * 100).toStringAsFixed(0)}% Off',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.share, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text(
                                      'Share',
                                      style: TextStyle(color: Colors.black, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _toggleFavorite,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _favoriteButtonColor,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  _isFavorited ? 'Remove Favorite' : 'Add to Favorite',
                                  style: const TextStyle(color: Colors.black, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Product Details",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Category: ${product.category}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sub Category: ${product.subCategory}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        // Fixed: Added null check for validity date
                        if (product.validity.isNotEmpty)
                          Text(
                            'Valid Until: ${DateFormat('d MMMM yyyy').format(DateTime.parse(product.validity))}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No product data available.'));
          }
        },
      ),
    );
  }
}
