import 'package:flutter/material.dart';
import 'payment_providers_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-adaptive colors
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF8F9FA);
    final cardBg = isDark 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    final innerCardBg = isDark 
        ? const Color(0xFF262626) 
        : const Color(0xFFF1F3F5);
    final accentColor = const Color.fromARGB(255, 55, 194, 21); // K-Pesa Green accent

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
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),
                  
                  // ── User Information ────────────────────────
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.account_circle, size: 100, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Eddy Kimani',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Summary Section (Screenshot Remodel) ─────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: isDark ? null : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildSummaryCard(
                          label: 'Deposits',
                          amount: 'Ksh. 0',
                          cardBg: innerCardBg,
                          accentColor: accentColor,
                          textColor: textColor,
                          subtleColor: subtleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          label: 'Withdrawals',
                          amount: 'Ksh. 0',
                          cardBg: innerCardBg,
                          accentColor: accentColor,
                          textColor: textColor,
                          subtleColor: subtleColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Settings Menu ──────────────────────────
                  _buildMenuItem(
                    icon: Icons.phone_android_rounded,
                    title: 'Payment Providers',
                    subtitle: 'Add, modify, remove',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentProvidersPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'MT5 Account',
                    subtitle: 'MTR*****',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Default Accounts',
                    subtitle: 'MT5, Deposits, Withdrawals',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Change Password',
                    subtitle: '*******',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_rounded,
                    title: 'Help & feedback',
                    subtitle: 'Help center, contact us',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Other Settings',
                    subtitle: 'Theme, notifications',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
                  ),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    cardBg: cardBg,
                    accentColor: accentColor,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    isDark: isDark,
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

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required Color cardBg,
    required Color accentColor,
    required Color textColor,
    required Color subtleColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                'KES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: subtleColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
    required Color cardBg,
    required Color accentColor,
    required Color textColor,
    required Color subtleColor,
    required bool isDark,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: subtleColor,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: showArrow
            ? Icon(Icons.chevron_right, color: accentColor, size: 20)
            : null,
      ),
    );
  }
}
