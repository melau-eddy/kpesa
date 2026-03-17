import 'package:flutter/material.dart';

class PaymentProvidersPage extends StatelessWidget {
  const PaymentProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = const Color(0xFF6200EE); // Deep Purple to match screenshot chevrons

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textColor),
                  ),
                  Expanded(
                    child: Text(
                      'Payment Providers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),

                  // ── Mobile Section ────────────────────────
                  _buildSectionHeader('Mobile', textColor),
                  const SizedBox(height: 16),
                  _buildProviderCard(
                    logoPath: 'assets/mpesa.png',
                    title: 'M-PESA',
                    subtitle: '254793814776',
                    cardBg: cardBg,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 12),
                  _buildProviderCard(
                    logoPath: 'assets/airtel.png',
                    title: 'Airtel Money',
                    subtitle: 'No airtel money account added',
                    cardBg: cardBg,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 16),
                  _buildNote(
                    '* Please note that you can only link one account per payment provider. If you have accounts with both Safaricom and Airtel, you may add only one account for each payment provider.',
                    subtleColor,
                  ),

                  const SizedBox(height: 40),

                  // ── Bank Section ──────────────────────────
                  _buildSectionHeader('Bank', textColor),
                  const SizedBox(height: 16),
                  _buildBankCard(
                    cardBg: cardBg,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 16),
                  _buildNote(
                    '* Please note that bank option is only available for withdrawals, not deposits.',
                    subtleColor,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        // The mockup has a slightly playful/cursive header font. 
        // We'll use a very bold weight and slightly tighter spacing to match the 'vibe'.
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildProviderCard({
    String? logoPath,
    Widget? customLogo,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color textColor,
    required Color subtleColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        leading: SizedBox(
          width: 110, // Increased from 90 for even larger, more prominent logos
          child: Center(
            child: customLogo ?? (logoPath != null ? Image.asset(
              logoPath,
              height: 64, // Increased from 54 to match the larger mockup scale
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => Icon(Icons.account_balance_wallet, color: accentColor, size: 32),
            ) : const SizedBox()),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(
              color: subtleColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: accentColor, size: 22),
      ),
    );
  }

  Widget _buildBankCard({
    required Color cardBg,
    required Color textColor,
    required Color subtleColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        leading: SizedBox(
          width: 60,
          child: Icon(Icons.account_balance_outlined, color: accentColor, size: 36),
        ),
        title: Text(
          'Add New Bank',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Click to add a bank account',
            style: TextStyle(
              color: subtleColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: accentColor, size: 22),
      ),
    );
  }

  Widget _buildNote(String text, Color subtleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: subtleColor.withValues(alpha: 0.6),
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
