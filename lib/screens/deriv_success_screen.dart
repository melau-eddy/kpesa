import 'package:flutter/material.dart';

class DerivSuccessScreen extends StatelessWidget {
  final String name;
  final String email;
  final String account;

  const DerivSuccessScreen({
    super.key,
    required this.name,
    required this.email,
    required this.account,
  });

  static const _accent = Color.fromARGB(255, 55, 194, 21);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ── Checkmark illustration ────────────────────────────────────
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative dots
                        ..._buildDots(),
                        // Green rounded box with checkmark
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),
                Text(
                  'You have successfully signed in to Deriv.\nPlease confirm that these are your details.',
                  style: TextStyle(
                    color: subtleColor,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── User details ──────────────────────────────────────────────
                _DetailTile(
                  label: 'Name',
                  value: name,
                  textColor: textColor,
                  subtleColor: subtleColor,
                ),
                const SizedBox(height: 10),
                _DetailTile(
                  label: 'Email',
                  value: email,
                  textColor: textColor,
                  subtleColor: subtleColor,
                ),
                const SizedBox(height: 10),
                _DetailTile(
                  label: 'Account',
                  value: account,
                  textColor: textColor,
                  subtleColor: subtleColor,
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // TODO: navigate to main home screen
                  },
                  child: const Text(
                    'These are my details!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Not my details!',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    const positions = [
      Offset(-68, -30),
      Offset(68, -30),
      Offset(-60, 40),
      Offset(60, 40),
      Offset(0, -72),
      Offset(0, 72),
    ];
    const sizes = [10.0, 8.0, 12.0, 8.0, 10.0, 8.0];
    const opacities = [0.5, 0.3, 0.6, 0.3, 0.4, 0.3];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: 80 + positions[i].dx - sizes[i] / 2,
        top: 80 + positions[i].dy - sizes[i] / 2,
        child: Container(
          width: sizes[i],
          height: sizes[i],
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: opacities[i]),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subtleColor;

  const _DetailTile({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subtleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('$label  ', style: TextStyle(color: subtleColor, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
