// lib/pages/profile/profile.dart

import 'package:flutter/material.dart';
import 'package:offerion/pages/signin_page/signin_page.dart';
import 'package:offerion/pages/signup_page/signup_page.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/models/models.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ApiService _apiService = ApiService();
  final int _userId = 1; // Placeholder for authenticated user ID
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Assuming the user is authenticated, fetch their profile
    _profileFuture = _apiService.getUserDetails(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Offerion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.9),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildUnauthenticatedProfile();
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return _buildAuthenticatedProfile(user);
          } else {
            return _buildUnauthenticatedProfile();
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(UserProfile user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.profileImage),
                    onBackgroundImageError: (exception, stackTrace) => const AssetImage("assets/images/user.jpeg"),
                  ),
                  const SizedBox(height: 10),
                  Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement logout functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildImportantLinks(),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, top: 15, right: 8, left: 8),
                child: Text("Login or SignUp to view your complete profile", style: TextStyle(fontSize: 19)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromRGBO(220, 53, 69, 1),
                        minimumSize: const Size(180, 55),
                        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        side: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
                      },
                      child: const Text("Sign In", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 55),
                        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                      },
                      child: const Text("Sign Up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildImportantLinks(),
      ],
    );
  }

  Widget _buildImportantLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15, bottom: 5, left: 5),
          child: Text("IMPORTANT LINKS", style: TextStyle(fontSize: 21, color: Color.fromRGBO(0, 0, 0, 0.7))),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.favorite_outlined),
                    Text(" Terms and Conditions", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.shopping_bag),
                    Text(" Privacy Policy", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.contact_page),
                    Text(" Disclaimer", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12, top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.info),
                    Text(" About", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.call),
                    Text(" Contact us", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }
}