import 'package:http/http.dart' as http;

class SmsService {
  // ── Africa's Talking credentials ─────────────────────────────────────────────
  static const _atUsername = 'cyberpark';
  static const _apiKey =
      'atsk_d15ce90cb6fedbd0f8168634896a78752c60137484636ebf12b535dd19f2dcdc66fbce94';
  // Sender ID is omitted until "K-pesa" is registered with Africa's Talking.
  // Once registered, add  'from': 'K-pesa'  back into the request body below.

  /// Sends a 6-digit [otp] to a Kenyan [phone] number via Africa's Talking SMS.
  /// Returns true if AT accepted the request (HTTP 201).
  static Future<bool> sendOtp(String phone, String otp) async {
    final formatted = _formatKenyanPhone(phone);
    final message =
        'Your K-PESA verification code is: $otp. '
        'Valid for 10 minutes. Do not share this code.';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.africastalking.com/version1/messaging'),
            headers: {'apiKey': _apiKey, 'Accept': 'application/json'},
            body: {
              'username': _atUsername,
              'to': formatted,
              'message': message,
              // 'from': 'K-pesa', // uncomment after registering the sender ID
            },
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Converts a Kenyan phone number to E.164 format (+254XXXXXXXXX).
  static String _formatKenyanPhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('07') || phone.startsWith('01')) {
      return '+254${phone.substring(1)}';
    }
    if (phone.startsWith('7') || phone.startsWith('1')) {
      return '+254$phone';
    }
    if (phone.startsWith('+254')) return phone;
    return '+254$phone';
  }
}

