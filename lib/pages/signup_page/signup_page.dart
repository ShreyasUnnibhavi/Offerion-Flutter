// lib/pages/signup_page/signup_page.dart

import 'package:flutter/material.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/pages/otp_verification_page/otp_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  String? _selectedAgeGroup;
  String? _selectedLocation;

  bool _termsAccepted = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Convert phone to integer for registration
      final int? phoneNumber = int.tryParse(_phoneController.text.trim());
      if (phoneNumber == null) {
        _showSnackBar('Please enter valid 10-digit phone number');
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: Prepare user data exactly as API expects
      final userData = {
        'name': _nameController.text.trim(),
        'phone': phoneNumber, // INTEGER for registration
        'email': _emailController.text.trim(),
        'gender': _selectedGender!,
        'age': _selectedAgeGroup!,
        'place': _selectedLocation!,
        'account_type': 'user',
        'profile_image': 'https://example.com/default.jpg',
      };

      print('Step 1: Attempting registration with data: $userData');

      // Step 3: Register user - Handle both new registration and existing inactive user
      final response = await _apiService.registerUser(userData);

      if (response['userId'] == null) {
        throw Exception('Registration failed: No user ID returned');
      }

      final int userId = response['userId'];

      // Check if this is an existing inactive user (this is normal and expected)
      if (response['message'] != null &&
          response['message'].toString().toLowerCase().contains('inactive')) {
        _showSnackBar('Account found! Sending OTP for verification...', isError: false);
      } else {
        _showSnackBar('Registration successful!', isError: false);
      }

      print('Step 2: Registration/Account found successful, User ID: $userId');

      // Step 4: Send OTP (phone as string for OTP API)
      print('Step 3: Sending OTP to: ${_phoneController.text.trim()}');
      await _apiService.sendOtp(_phoneController.text.trim());
      _showSnackBar('OTP sent successfully!', isError: false);
      print('Step 4: OTP sent successfully');

      // Step 5: Navigate to OTP verification
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              userId: userId,
              phoneNumber: _phoneController.text.trim(),
              isSignUp: true,
            ),
          ),
        );
      }
    } catch (e) {
      print('Registration Error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific error cases - but "inactive" user is NOT an error
      if (errorMessage.contains('duplicate') || errorMessage.contains('already exists') || errorMessage.contains('already registered')) {
        errorMessage = 'This phone number or email is already registered and active. Please use different credentials or sign in instead.';
      } else if (errorMessage.contains('validation') || errorMessage.contains('invalid')) {
        errorMessage = 'Please check your information and try again.';
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      _showSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return false;
    }

    if (_nameController.text.trim().length < 2) {
      _showSnackBar('Name must be at least 2 characters long');
      return false;
    }

    if (_phoneController.text.trim().isEmpty || _phoneController.text.trim().length != 10) {
      _showSnackBar('Please enter valid 10-digit phone number');
      return false;
    }

    // Validate phone contains only numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(_phoneController.text.trim())) {
      _showSnackBar('Phone number should contain only digits');
      return false;
    }

    if (_emailController.text.trim().isEmpty || !_isValidEmail(_emailController.text.trim())) {
      _showSnackBar('Please enter valid email address');
      return false;
    }

    if (_selectedGender == null) {
      _showSnackBar('Please select gender');
      return false;
    }

    if (_selectedAgeGroup == null) {
      _showSnackBar('Please select age group');
      return false;
    }

    if (_selectedLocation == null) {
      _showSnackBar('Please select location');
      return false;
    }

    if (!_termsAccepted) {
      _showSnackBar('Please accept terms and conditions');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("SIGN UP", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Picture Section
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromRGBO(240, 240, 240, 1),
                        child: Icon(Icons.person, size: 60, color: Color.fromRGBO(180, 180, 180, 1)),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement image picker
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      const Text("Name*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Phone Number Field
                      const Text("Phone Number*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("+91", style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      const Text("Email*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Gender and Age Group Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Gender*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  value: _selectedGender,
                                  items: ['male', 'female', 'other']
                                      .map((String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                  hint: const Text("Select", style: TextStyle(color: Colors.black, fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Age Group*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  value: _selectedAgeGroup,
                                  items: ['18-22', '23-30', '31-40', '41-50', '50+']
                                      .map((String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedAgeGroup = newValue;
                                    });
                                  },
                                  hint: const Text("Select", style: TextStyle(color: Colors.black, fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Location Field
                      const Text("Location*", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        value: _selectedLocation,
                        items: ['Hubli', 'Dharwad', 'Bengaluru', 'Mumbai', 'Delhi', 'Chennai']
                            .map((String value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLocation = newValue;
                          });
                        },
                        hint: const Text("Choose your city", style: TextStyle(color: Colors.black, fontSize: 18)),
                      ),
                      const SizedBox(height: 20),
                      // Terms and Conditions Checkbox
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _termsAccepted = newValue ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(color: Colors.grey, width: 2),
                                activeColor: const Color.fromRGBO(220, 53, 69, 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "I have read and understood the "),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: " and "),
                                    TextSpan(
                                      text: "Privacy Policy.",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Register Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: (_termsAccepted && !_isLoading) ? _signUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_termsAccepted && !_isLoading)
                      ? const Color.fromRGBO(220, 53, 69, 1)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text("Register & Send OTP", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
