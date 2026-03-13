import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/signup_data.dart';
import '../services/email_service.dart';
import '../services/sms_service.dart';
import 'affiliate_screen.dart';

class OtpScreen extends StatefulWidget {
  final String destination; // phone number or email
  final bool isEmail;
  final String otp; // the generated OTP (matched against user input)
  final SignupData signupData;

  const OtpScreen({
    super.key,
    required this.destination,
    required this.isEmail,
    required this.otp,
    required this.signupData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _accent = Color.fromARGB(255, 55, 194, 21);
  static const _boxCount = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late String _currentOtp;
  late String _currentDest;
  bool _isEditingDest = false;
  late final TextEditingController _destController;
  bool _isVerifying = false;
  bool _isResending = false;
  String _error = '';
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otp;
    _currentDest = widget.destination;
    _destController = TextEditingController(text: widget.destination);
    _controllers = List.generate(_boxCount, (_) => TextEditingController());

    // Wire up backspace-to-previous-box behaviour on each FocusNode
    _focusNodes = List.generate(_boxCount, (i) {
      final node = FocusNode();
      node.onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[i].text.isEmpty &&
            i > 0) {
          _controllers[i - 1].clear();
          _focusNodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
      return node;
    });

    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _destController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── OTP digit entry ───────────────────────────────────────────────────────

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.isEmpty) return;
    setState(() => _error = '');
    if (index < _boxCount - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
    // Auto-verify when all boxes are filled
    if (_enteredOtp.length == _boxCount) {
      _verify();
    }
  }

  // ── Verify ────────────────────────────────────────────────────────────────

  Future<void> _verify() async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
      _error = '';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (_enteredOtp == _currentOtp) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AffiliateScreen(signupData: widget.signupData),
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
        _error = 'Incorrect code. Please try again.';
        for (final c in _controllers) c.clear();
      });
      _focusNodes[0].requestFocus();
    }
  }

  // ── Resend ────────────────────────────────────────────────────────────────

  Future<void> _resend() async {
    if (_resendSeconds > 0 || _isResending) return;
    setState(() => _isResending = true);

    final newOtp = (100000 + Random.secure().nextInt(900000)).toString();

    if (!widget.isEmail) {
      await SmsService.sendOtp(_currentDest, newOtp);
    } else {
      await EmailService.sendOtp(_currentDest, newOtp);
    }

    if (!mounted) return;
    setState(() {
      _currentOtp = newOtp;
      _error = '';
      _isResending = false;
      for (final c in _controllers) c.clear();
    });
    _startResendTimer();
    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New code sent to $_currentDest'),
        backgroundColor: _accent,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),

                // ── Icon ──────────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isEmail ? Icons.email_rounded : Icons.sms_rounded,
                      color: _accent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Verify your identity',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We sent a 6-digit code to',
                  style: TextStyle(color: subtleColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // ── Destination (editable for email flow) ─────────────────────
                if (widget.isEmail && _isEditingDest) ...[
                  TextField(
                    controller: _destController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'new@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() {
                          _destController.text = _currentDest;
                          _isEditingDest = false;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: (_isResending ||
                            _destController.text.trim().isEmpty)
                        ? null
                        : () async {
                            final newEmail = _destController.text.trim();
                            setState(() {
                              _isEditingDest = false;
                              _isResending = true;
                            });
                            final newOtp =
                                (100000 + Random.secure().nextInt(900000))
                                    .toString();
                            await EmailService.sendOtp(newEmail, newOtp);
                            if (!mounted) return;
                            setState(() {
                              _currentDest = newEmail;
                              _currentOtp = newOtp;
                              _isResending = false;
                              for (final c in _controllers) c.clear();
                            });
                            _startResendTimer();
                            _focusNodes[0].requestFocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('New code sent to $newEmail'),
                                backgroundColor: _accent,
                              ),
                            );
                          },
                    icon: _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send OTP to this address'),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: widget.isEmail
                        ? () => setState(() => _isEditingDest = true)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentDest,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.isEmail) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: subtleColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ── OTP boxes ─────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _boxCount,
                    (i) => _otpBox(i, cardColor, textColor),
                  ),
                ),

                // ── Error ─────────────────────────────────────────────────────
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error,
                    style: TextStyle(color: Colors.red[400], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 36),

                // ── Verify button ─────────────────────────────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: (_isVerifying || _enteredOtp.length < _boxCount)
                      ? null
                      : _verify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // ── Resend row ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive a code? ",
                      style: TextStyle(color: subtleColor, fontSize: 14),
                    ),
                    _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          )
                        : GestureDetector(
                            onTap: _resend,
                            child: Text(
                              _resendSeconds > 0
                                  ? 'Resend in ${_resendSeconds}s'
                                  : 'Resend',
                              style: TextStyle(
                                color: _resendSeconds > 0
                                    ? subtleColor
                                    : _accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index, Color cardColor, Color textColor) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) => _onChanged(index, v),
      ),
    );
  }
}
