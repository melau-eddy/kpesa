import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  // ── Gmail credentials ────────────────────────────────────────────────────────
  // Replace with YOUR Gmail address (the one you generated the App Password on).
  static const _gmailAddress = 'georgeswambugu19@gmail.com';

  // App Password generated from: Google Account → Security → App Passwords
  static const _appPassword = 'gyhy mwrc mije igdu';

  // what recipient sees as sender
  static const _senderAddress = 'otp@k-pesa.tech';

  /// Sends a 6-digit [otp] to [email] via Gmail SMTP.
  /// Returns true if the message was accepted by Gmail's servers.
  static Future<bool> sendOtp(String email, String otp) async {
    final smtpServer = gmail(_gmailAddress, _appPassword);

    final message = Message()
      ..from = const Address(_senderAddress, 'K-PESA')
      ..recipients.add(email)
      ..subject = 'Your K-PESA verification code'
      ..text =
          'Your K-PESA verification code is: $otp\n\n'
          'Valid for 10 minutes. Do not share this code with anyone.';

    try {
      await send(message, smtpServer);
      return true;
    } on MailerException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
