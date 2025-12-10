// lib/pages/otp_verification_page/otp_verification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offerion/services/api_service.dart';
import 'package:offerion/services/auth_manager.dart';
import 'package:offerion/pages/bottom_nav/bottom_nav.dart';

class OtpVerificationPage extends StatefulWidget {
  final int userId;
  final String phoneNumber;
  final bool isSignUp;

  const OtpVerificationPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
    this.isSignUp = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final ApiService _apiService = ApiService();
  final AuthManager _authManager = AuthManager();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    print('OTP Verification initialized for User ID: ${widget.userId}, Phone: ${widget.phoneNumber}');
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _verifyOtp() async {
    final otpString = _otpControllers.map((controller) => controller.text).join();

    if (otpString.length != 6) {
      _showSnackBar('Please enter complete OTP');
      return;
    }

    final otp = int.tryParse(otpString);
    if (otp == null) {
      _showSnackBar('Please enter valid OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Verifying OTP: $otp for User ID: ${widget.userId}');

      // Verify OTP with the API
      final response = await _apiService.verifyOtp(widget.userId, otp);

      // Extract token from response
      String? token = response['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Verification successful but no token received. Please try logging in again.');
      }

      // Update AuthManager with login credentials
      await _authManager.login(token, userId: widget.userId);

      _showSnackBar('OTP verified successfully!', isError: false);

      // Navigate to main app
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
              (route) => false,
        );
      }
    } catch (e) {
      print('OTP Verification Error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific error cases
      if (errorMessage.contains('invalid') || errorMessage.contains('expired') || errorMessage.contains('wrong')) {
        errorMessage = 'Invalid or expired OTP. Please try again or request a new one.';
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
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

  void _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Send OTP using phone number as string
      await _apiService.sendOtp(widget.phoneNumber);

      _showSnackBar('OTP sent successfully!', isError: false);
      _startResendTimer();

      // Clear existing OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      print('Resend OTP Error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      }

      _showSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    if (index == 5 && value.isNotEmpty) {
      final isComplete = _otpControllers.every((controller) => controller.text.isNotEmpty);
      if (isComplete) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _verifyOtp();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(220, 53, 69, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Verification illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(220, 53, 69, 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.message,
                size: 60,
                color: Color.fromRGBO(220, 53, 69, 1),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Verification Code',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We have sent the verification code to\n+91 ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            if (widget.isSignUp) ...[
              const SizedBox(height: 8),
              Text(
                'User ID: ${widget.userId}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 40),
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color.fromRGBO(220, 53, 69, 1), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) => _onOtpDigitChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(220, 53, 69, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Resend OTP Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                GestureDetector(
                  onTap: _canResend && !_isResending ? _resendOtp : null,
                  child: Text(
                    _canResend
                        ? (_isResending ? 'Sending...' : 'Resend')
                        : 'Resend in ${_resendTimer}s',
                    style: TextStyle(
                      color: _canResend && !_isResending
                          ? const Color.fromRGBO(220, 53, 69, 1)
                          : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
