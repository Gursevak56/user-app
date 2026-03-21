import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/notification_service.dart';

/// A modern bottom-sheet login flow: Phone → OTP → JWT token.
/// Returns `true` if the user successfully authenticated.
class AuthBottomSheet {
  /// Show the auth bottom sheet and return whether login succeeded.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AuthSheetContent(),
    );
    return result == true;
  }
}

class _AuthSheetContent extends StatefulWidget {
  const _AuthSheetContent();

  @override
  State<_AuthSheetContent> createState() => _AuthSheetContentState();
}

enum _AuthStep { phone, otp }

class _AuthSheetContentState extends State<_AuthSheetContent> {
  _AuthStep _step = _AuthStep.phone;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String _phone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final raw = _phoneController.text.trim();
    if (raw.length < 10) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }

    // Prepend 91 if user enters 10 digits without country code
    _phone = raw.length == 10 ? '91$raw' : raw;

    setState(() { _isLoading = true; _error = null; });

    await ServiceCall.postToUrl(
      {'phone': _phone},
      '${SVKey.mainUrl}/auth/send-otp',
      isToken: false,
      withSuccess: (res) async {
        if (mounted) {
          setState(() { _isLoading = false; _step = _AuthStep.otp; });
        }
      },
      failure: (err) async {
        if (mounted) {
          final msg = err is Map
              ? (err['message']?.toString() ?? 'Failed to send OTP')
              : err.toString();
          setState(() { _isLoading = false; _error = msg; });
        }
      },
    );
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _error = 'Please enter the OTP');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    await ServiceCall.postToUrl(
      {'phone': _phone, 'otp': otp, 'userType': 'customer'},
      '${SVKey.mainUrl}/auth/verify-otp',
      isToken: false,
      withSuccess: (res) async {
        final data = res['data'] as Map<String, dynamic>? ?? {};
        final token = data['authToken'] as String? ?? '';
        if (token.isNotEmpty) {
          // Save token and mark as logged in
          Globs.udStringSet(token, Globs.userPayload);
          Globs.udBoolSet(true, Globs.userLogin);
          ServiceCall.userPayload = Globs.udValue(Globs.userPayload);

          // Register FCM token now that user is logged in
          NotificationService.setupFCM();

          if (mounted) Navigator.pop(context, true);
        } else {
          if (mounted) {
            setState(() { _isLoading = false; _error = 'No token received'; });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          final msg = err is Map
              ? (err['message']?.toString() ?? 'Invalid OTP')
              : err.toString();
          setState(() { _isLoading = false; _error = msg; });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _step == _AuthStep.phone ? 'Login to Continue' : 'Verify OTP',
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _step == _AuthStep.phone
                  ? 'Enter your phone number to receive an OTP'
                  : 'We sent an OTP to +$_phone',
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Input field
            if (_step == _AuthStep.phone) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 16, letterSpacing: 1.5),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '98765 43210',
                  hintStyle: TextStyle(color: TColor.placeholder),
                  filled: true,
                  fillColor: TColor.textfield,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(color: TColor.placeholder, letterSpacing: 8),
                  filled: true,
                  fillColor: TColor.textfield,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_step == _AuthStep.phone ? _sendOtp : _verifyOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _step == _AuthStep.phone ? 'Send OTP' : 'Verify & Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),

            // Back to phone step
            if (_step == _AuthStep.otp) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _step = _AuthStep.phone;
                          _otpController.clear();
                          _error = null;
                        });
                      },
                child: Text(
                  'Change Phone Number',
                  style: TextStyle(color: TColor.primary, fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
