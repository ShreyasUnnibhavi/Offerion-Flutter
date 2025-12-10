// lib/pages/brand_list_page/brand_list_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/utils/app_constants.dart';

class BrandListPage extends StatefulWidget {
  final String title;
  const BrandListPage({super.key, required this.title});

  @override
  State<BrandListPage> createState() => _BrandListPageState();
}

class _BrandListPageState extends State<BrandListPage> {
  late Future<List<ShopItem>> _shopsFuture;
  final ApiService _apiService = ApiService();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _shopsFuture = _apiService.getShopsByCategory(widget.title);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(220, 53, 69, 1),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8, right: 8, left: 8),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 45,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Shop name or Products...",
                          hintStyle: const TextStyle(fontSize: 18),
                          prefixIcon: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color.fromRGBO(220, 53, 69, 1),
                              size: 30,
                            ),
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
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<ShopItem>>(
        future: _shopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final shops = snapshot.data!;
            if (shops.isEmpty) {
              return const Center(child: Text('No brands found for this category.'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16, right: 8),
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  ListView.builder(
                    itemCount: shops.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      final imageUrl = shop.storeImages['0'] ?? ''; // Fixed: Handle null case

                      return Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black,
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fixed: Check if imageUrl is not empty before using Image.network
                            imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  defaultImage,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                );
                              },
                            )
                                : Image.asset(
                              defaultImage,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 4),
                              child: Text(
                                shop.shopName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Text(shop.area, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(33, 37, 41, 0.03),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage("assets/images/offer.webp"),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Coming Soon",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
