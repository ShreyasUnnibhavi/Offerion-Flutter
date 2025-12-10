// lib/pages/categories/categories.dart

import 'package:flutter/material.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/pages/brand_list_page/brand_list_page.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late Future<List<CategoryItem>> _categoriesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories();
  }

  void _navigateToBrandPage(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandListPage(title: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(220, 53, 69, 1)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "All Categories",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, -8.0),
                end: Alignment(0.0, 0.75),
                colors: [Color.fromRGBO(220, 53, 69, 0.02), Colors.white],
              ),
            ),
          ),
          FutureBuilder<List<CategoryItem>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categories = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Text(
                        "Category",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      child: Text(
                        "Trending categories filled with offers",
                        style: TextStyle(fontSize: 16, color: Colors.black38),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 55,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _navigateToBrandPage(context, category.category);
                                  },
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(category.image),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(category.category),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return const Center(child: Text('No categories found.'));
              }
            },
          ),
        ],
      ),
    );
  }
}