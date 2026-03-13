/// Carries all collected user data through the sign-up flow.
class SignupData {
  // ── Source account ──────────────────────────────────────────────────────────
  final String? binanceId;
  final String? derivEmail;
  final String? derivName;
  final String? derivAccount;

  // ── Payment methods ─────────────────────────────────────────────────────────
  final String? mpesaPhone;
  final String? airtelPhone;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;

  const SignupData({
    this.binanceId,
    this.derivEmail,
    this.derivName,
    this.derivAccount,
    this.mpesaPhone,
    this.airtelPhone,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
  });

  /// True when we already know their email (from Deriv OAuth).
  bool get hasKnownEmail => derivEmail != null && derivEmail!.trim().isNotEmpty;

  /// First available phone number (M-Pesa takes priority over Airtel).
  String? get primaryPhone => mpesaPhone ?? airtelPhone;

  SignupData copyWith({
    String? binanceId,
    String? derivEmail,
    String? derivName,
    String? derivAccount,
    String? mpesaPhone,
    String? airtelPhone,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
  }) {
    return SignupData(
      binanceId: binanceId ?? this.binanceId,
      derivEmail: derivEmail ?? this.derivEmail,
      derivName: derivName ?? this.derivName,
      derivAccount: derivAccount ?? this.derivAccount,
      mpesaPhone: mpesaPhone ?? this.mpesaPhone,
      airtelPhone: airtelPhone ?? this.airtelPhone,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
    );
  }
}
