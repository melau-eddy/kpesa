import 'package:http/http.dart' as http;

class SmsService {
  // ── Africa's Talking credentials ─────────────────────────────────────────────
  static const _atUsername = 'cyberpark';
  static const _apiKey =
      'atsk_007a9d3d48eea35e78a31efc293f66bde0ef581298478b6493f1f7eca1d044be0f4eb07b';
  // Sender ID is omitted until "K-pesa" is registered with Africa's Talking.
  // Once registered, add  'from': 'K-pesa'  back into the request body below.

  /// Sends a 6-digit [otp] to a Kenyan [phone] number via Africa's Talking
  /// Bulk SMS (Legacy) API. Returns true if AT accepted the request (HTTP 201).
  static Future<bool> sendOtp(String phone, String otp) async {
    final formatted = _formatKenyanPhone(phone);
    final message =
        'Your K-PESA verification code is: $otp. '
        'Valid for 10 minutes. Do not share this code.';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.africastalking.com/version1/messaging'),
            headers: {
              'apiKey': _apiKey,
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'username': _atUsername,
              'to': formatted,
              'message': message,
              'bulkSMSMode': '1',
              //'from': 'K-pesa', // uncomment after registering the sender ID
            },
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Converts a Kenyan phone number to E.164 format (+254XXXXXXXXX).
  /// Input examples: 0712345678 → +254712345678
  ///                 712345678  → +254712345678
  ///                +254712345678 → +254712345678 (unchanged)
  static String _formatKenyanPhone(String phone) {
    phone = phone.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (phone.startsWith('+254')) return phone; // already E.164
    if (phone.startsWith('0'))
      return '+254${phone.substring(1)}'; // 07... → +2547...
    return '+254$phone'; // 7... → +2547...
  }
}
