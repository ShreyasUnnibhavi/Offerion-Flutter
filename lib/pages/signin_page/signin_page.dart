// lib/pages/signin_page/signin_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/pages/signup_page/signup_page.dart';
import 'package:offerion/pages/otp_verification_page/otp_verification_page.dart';
import 'package:offerion/services/api_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _signIn() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showSnackBar('Please enter phone number');
      return;
    }

    if (phone.length != 10) {
      _showSnackBar('Please enter valid 10-digit phone number');
      return;
    }

    // Validate phone contains only numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnackBar('Phone number should contain only digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Step 1: Attempting to send OTP to: $phone');

      // Send OTP - this will also return userId if user exists
      final response = await _apiService.sendOtp(phone);

      if (response['success'] != true) {
        throw Exception('Failed to send OTP');
      }

      _showSnackBar('OTP sent successfully!', isError: false);

      print('Step 2: OTP sent successfully');

      // For login, we might not get userId in the response
      // We'll handle this in OTP verification by passing 0 and letting the backend handle it
      int userId = response['userId'] ?? 0;

      print('Step 3: Navigating to OTP verification with userId: $userId');

      // Navigate to OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            userId: userId, // May be 0 for login flow
            phoneNumber: phone,
            isSignUp: false,
          ),
        ),
      );

    } catch (e) {
      print('Sign In Error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.toLowerCase().contains('user not found') ||
          errorMessage.toLowerCase().contains('not found') ||
          errorMessage.toLowerCase().contains('phone number not registered')) {
        errorMessage = 'Phone number not registered. Please sign up first.';
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      _showSnackBar(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/signin.webp',
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              "Offerion",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              "One stop for all your offers!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, indent: 60)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("LOGIN", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                  Expanded(child: Divider(color: Colors.grey, endIndent: 60)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "+91",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: "Enter Phone Number",
                        hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1), width: 1.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("DON'T HAVE AN ACCOUNT?", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1), width: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(220, 53, 69, 1),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Offerion - Terms & Conditions and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "🇮🇳 Made in India ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Icon(Icons.favorite, color: Colors.red),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
