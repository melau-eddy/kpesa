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
    final accentColor = const Color.fromARGB(255, 55, 194, 21); // K-Pesa Green

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
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS', // Matching the playful font in screenshot if available, else standard
      ),
    );
  }

  Widget _buildProviderCard({
    required String logoPath,
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Image.asset(
          logoPath,
          height: 40,
          width: 80,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => Icon(Icons.account_balance_wallet, color: accentColor, size: 32),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: subtleColor,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: accentColor.withValues(alpha: 0.6)),
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_balance_outlined, color: accentColor, size: 28),
        ),
        title: Text(
          'Add New Bank',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Click to add a bank account',
          style: TextStyle(
            color: subtleColor,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: accentColor.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _buildNote(String text, Color subtleColor) {
    return Text(
      text,
      style: TextStyle(
        color: subtleColor.withValues(alpha: 0.8),
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}
