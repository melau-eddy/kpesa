import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  // 0 = Deriv, 1 = MT5, 2 = Binance
  int _selectedTab = 0;
  String _amountStr = '0';
  bool _isKesInput = true;

  static const _accent = Color.fromARGB(255, 55, 194, 21);
  static const double _exchangeRate = 133.77375;

  double get _usdAmount {
    final parsed = double.tryParse(_amountStr) ?? 0;
    return _isKesInput ? (parsed / _exchangeRate) : parsed;
  }

  double get _kesAmount {
    final parsed = double.tryParse(_amountStr) ?? 0;
    return _isKesInput ? parsed : (parsed * _exchangeRate);
  }

  String get _displayAmount {
    if (_amountStr.isEmpty) return '0';
    return _amountStr;
  }

  void _onDigit(String digit) {
    setState(() {
      if (digit == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
        return;
      }

      if (_amountStr == '0') {
        _amountStr = digit;
      } else if (_amountStr.length < 12) {
        _amountStr += digit;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  void _showDepositDialog() {
    bool _isMpesaSelected = false; // Move state variable outside

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final cardBg = isDark
            ? const Color(0xFF232323)
            : const Color.fromARGB(255, 240, 240, 240);
        final subtleColor = isDark ? Colors.white70 : Colors.black54;

        return Dialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Account',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can set your default deposit account in the account setting page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // M-PESA Account Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMpesaSelected = !_isMpesaSelected;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          border: Border.all(
                            color: _isMpesaSelected
                                ? _accent // K-Pesa Green highlight
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Placeholder for M-PESA logo (using text for now)
                            Text(
                              'M-PESA',
                              style: TextStyle(
                                color: Colors.greenAccent[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'M-PESA',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '254793814776',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Radio button outline
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isMpesaSelected
                                    ? _accent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _isMpesaSelected
                                      ? _accent
                                      : subtleColor,
                                  width: 2,
                                ),
                              ),
                              child: _isMpesaSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Proceed Button
                    TextButton(
                      onPressed: _isMpesaSelected
                          ? () {
                              // TODO: Implement actual proceed
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing Deposit via M-PESA...'),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: _isMpesaSelected
                              ? _accent
                              : Colors.white38, // Dimmed as in screenshot
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel Deposit Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel Deposit',
                        style: TextStyle(
                          color: _accent, // K-Pesa Green
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color.fromARGB(255, 240, 240, 240);
    final keyBg = isDark
        ? const Color.fromARGB(255, 50, 50, 50)
        : const Color.fromARGB(255, 220, 220, 220);

    final usdVal = _usdAmount;
    final kesVal = _kesAmount;
    final canDeposit = usdVal >= 5;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28, color: textColor),
                  ),
                  Text(
                    'Deposit',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 28), // For balance
                ],
              ),

              const SizedBox(height: 24), // Replaced 48 with 24 to fix overflow

              // ── "To" section ────────────────────────────────
              Center(
                child: Text(
                  'To',
                  style: TextStyle(color: subtleColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              // ── Segmented toggle ──────────────────────────
              _buildSegmentedToggle(isDark, cardBg, textColor),

              const SizedBox(height: 24),

              // ── Amount display (Converted USD) ────────────
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: 0,
                                end: _isKesInput ? usdVal : kesVal),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Text(
                                _isKesInput
                                    ? value.toStringAsFixed(2)
                                    : value.toStringAsFixed(0),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -1,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _isKesInput ? 'USD' : 'KES',
                              style: TextStyle(
                                color: subtleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _isKesInput = !_isKesInput;
                                  _amountStr = '0';
                                });
                              },
                              child: Icon(
                                Icons.import_export_rounded,
                                color: subtleColor,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1 USD = ${_exchangeRate.toStringAsFixed(5)} KES',
                        style: TextStyle(color: subtleColor, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Input Amount (centered with divider) ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isKesInput ? 'KES' : 'USD',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _displayAmount,
                    style: TextStyle(
                      color: subtleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: isDark ? Colors.white24 : Colors.black26,
                thickness: 1,
              ),

              const SizedBox(height: 12),

              // ── Minimum deposit note ───────────────────────
              Text(
                'Minimum deposit amount is 5 USD',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ── Number pad ─────────────────────────────────
              _buildNumberPad(keyBg, textColor),

              const SizedBox(height: 24),

              // ── Deposit button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDeposit ? _accent : const Color(0xFF232323),
                    foregroundColor: canDeposit
                        ? Colors.white
                        : (isDark ? Colors.white38 : Colors.black38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: canDeposit
                      ? () {
                          if (_selectedTab == 0) { // Deriv specifically requested
                            _showDepositDialog();
                          } else {
                            final destination =
                                ['Deriv', 'MT5', 'Binance'][_selectedTab];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Depositing \$${usdVal.toStringAsFixed(2)} USD to $destination',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Text(
                        'Deposit',
                        style: TextStyle(
                          color: canDeposit ? Colors.white : Colors.white24,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: canDeposit ? Colors.white : Colors.white24,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Segmented toggle widget ────────────────────────────────────────────────

  Widget _buildSegmentedToggle(bool isDark, Color cardBg, Color textColor) {
    final labels = ['Deriv', 'MT5', 'Binance'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isActive = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? _accent : Colors.transparent, // K-Pesa Accent
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white60 : Colors.black54),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Number pad widget ─────────────────────────────────────────────────────

  Widget _buildNumberPad(Color keyBg, Color textColor) {
    const double spacing = 12.0;
    const double keyHeight = 54.0; // Flat, oval looking keys

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _padRow(['1', '2', '3'], const Color(0xFF282828), textColor, keyHeight, spacing),
        const SizedBox(height: spacing),
        _padRow(['4', '5', '6'], const Color(0xFF282828), textColor, keyHeight, spacing),
        const SizedBox(height: spacing),
        _padRow(['7', '8', '9'], const Color(0xFF282828), textColor, keyHeight, spacing),
        const SizedBox(height: spacing),
        _padRow(['.', '0', '⌫'], const Color(0xFF282828), textColor, keyHeight, spacing),
      ],
    );
  }

  Widget _padRow(List<String> keys, Color keyBg, Color textColor,
      double keyHeight, double spacing) {
    final List<Widget> children = [];

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];

      Widget child;
      if (key.isEmpty) {
        child = const SizedBox.shrink();
      } else {
        child = GestureDetector(
          onTap: () {
            if (key == '⌫') {
              _onBackspace();
            } else {
              _onDigit(key);
            }
          },
          child: Container(
            height: keyHeight,
            decoration: BoxDecoration(
              color: keyBg,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: key == '⌫'
                ? Icon(Icons.backspace_outlined, color: textColor, size: 24)
                : Text(
                    key,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      }

      children.add(Expanded(child: child));

      if (i < keys.length - 1) {
        children.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
