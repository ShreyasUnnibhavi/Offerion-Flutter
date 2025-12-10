// lib/pages/banners/banners.dart

import 'package:flutter/material.dart';
import 'package:offerion/models/models.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/utils/app_constants.dart';

class Banners extends StatefulWidget {
  const Banners({super.key});

  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {
  late Future<List<BannerItem>> _bannersFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _bannersFuture = _apiService.getBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color.fromRGBO(220, 53, 69, 1),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "All Banners",
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
          FutureBuilder<List<BannerItem>>(
            future: _bannersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final banners = snapshot.data!;
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Text(
                          "Banners",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: Text(
                          "Trending banners filled with offers",
                          style: TextStyle(fontSize: 16, color: Colors.black38),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: banners.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              banners[index].image,
                              width: 350,
                              height: 210,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  defaultImage,
                                  width: 350,
                                  height: 210,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('No banners found.'));
              }
            },
          ),
        ],
      ),
    );
  }
}