// lib/pages/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:offerion/pages/profile/profile.dart';
import 'package:offerion/pages/homePage/home_page.dart';
import '../favourites_page/favourites_page.dart';
import '../offers_page/offers_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Widget> _pages = [
    const HomePage(),
    const OfferPage(),
    const FavouritesPage(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicator: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color.fromRGBO(220, 53, 69, 1),
                width: 3,
              ),
            ),
          ),
          labelColor: const Color.fromRGBO(220, 53, 69, 1),
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(icon: Icon(Icons.home_filled), text: "Home"),
            Tab(icon: Icon(Icons.star), text: "Offers"),
            Tab(icon: Icon(Icons.favorite_outlined), text: "Favourites"),
            Tab(icon: Icon(Icons.person), text: "Profile"),
          ],
        ),
      ),
    );
  }
}