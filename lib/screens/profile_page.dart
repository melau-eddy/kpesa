import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color.fromARGB(255, 240, 240, 240);
    final accentColor = const Color.fromARGB(255, 115, 60, 255); // Purple accent from screenshots

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
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
                  const Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),
                  // ── User Info ──────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Eddy Kimani',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'eddymutugik@gmail.com',
                          style: TextStyle(
                            color: subtleColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CR10125517',
                          style: TextStyle(
                            color: subtleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Summary Tiles ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryCard(
                          'Deposits',
                          'Ksh. 0',
                          accentColor,
                          textColor,
                          subtleColor,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          'Withdrawals',
                          'Ksh. 0',
                          accentColor,
                          textColor,
                          subtleColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Menu List ──────────────────────────────
                  _buildMenuItem(
                    icon: Icons.phone_outlined,
                    title: 'Payment Providers',
                    subtitle: 'Add, modify, remove',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'MT5 Account',
                    subtitle: 'MTR*****',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.group_outlined,
                    title: 'Default Accounts',
                    subtitle: 'MT5, Deposits, Withdrawals',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Change Password',
                    subtitle: '*******',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & feedback',
                    subtitle: 'Help center, contact us',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Other Settings',
                    subtitle: 'Theme, biometrics',
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                  ),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: null,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    cardBg: cardBg,
                    showArrow: false,
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

  Widget _buildSummaryCard(
    String label,
    String amount,
    Color accentColor,
    Color textColor,
    Color subtleColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color.fromARGB(255, 38, 38, 38)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), 
            width: 1,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: const Text(
                'KES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: subtleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color accentColor,
    required Color textColor,
    required Color subtleColor,
    required Color cardBg,
    bool showArrow = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: accentColor.withValues(alpha: 0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
