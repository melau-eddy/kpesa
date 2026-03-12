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
  bool _showUsd = true;

  static const _accent = Color.fromARGB(255, 55, 194, 21);
  static const double _exchangeRate = 133.77375;

  double get _usdAmount {
    final parsed = double.tryParse(_amountStr) ?? 0;
    return _showUsd ? parsed : parsed / _exchangeRate;
  }

  double get _kesAmount {
    final parsed = double.tryParse(_amountStr) ?? 0;
    return _showUsd ? parsed * _exchangeRate : parsed;
  }

  String get _displayAmount {
    final parsed = double.tryParse(_amountStr) ?? 0;
    if (_amountStr == '0') return '0.00';
    // If the user typed digits, show as USD amount
    if (_showUsd) {
      return parsed.toStringAsFixed(2);
    } else {
      return parsed.toStringAsFixed(2);
    }
  }

  void _onDigit(String digit) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = digit;
      } else if (_amountStr.length < 8) {
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

  void _toggleCurrency() {
    setState(() {
      _showUsd = !_showUsd;
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: textColor, size: 26),
                    ),
                  ),
                  Text(
                    'Deposit',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── "To" label ────────────────────────────────
              Text(
                'To',
                style: TextStyle(color: subtleColor, fontSize: 14),
              ),
              const SizedBox(height: 10),

              // ── Segmented toggle ──────────────────────────
              _buildSegmentedToggle(isDark, cardBg, textColor),

              const SizedBox(height: 28),

              // ── Amount display ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0,
                        end: double.tryParse(_amountStr) ?? 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Text(
                        _amountStr == '0' ? '0.00' : value.toStringAsFixed(2),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showUsd ? 'USD' : 'KES',
                    style: TextStyle(
                      color: subtleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _toggleCurrency,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.swap_vert_rounded,
                        color: subtleColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '1 USD = ${_exchangeRate.toStringAsFixed(5)} KES',
                style: TextStyle(color: subtleColor, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // ── KES equivalent ────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12),
                    bottom: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _showUsd ? 'KES' : 'USD',
                      style: TextStyle(
                        color: subtleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0,
                          end: _showUsd ? kesVal : usdVal),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Minimum deposit note ───────────────────────
              Text(
                'Minimum deposit amount is 5 USD',
                style: TextStyle(
                  color: subtleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // ── Number pad ─────────────────────────────────
              Expanded(
                child: _buildNumberPad(keyBg, textColor),
              ),

              const SizedBox(height: 12),

              // ── Deposit button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDeposit
                        ? _accent
                        : (isDark
                            ? const Color.fromARGB(255, 50, 50, 50)
                            : const Color.fromARGB(255, 200, 200, 200)),
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
                          // TODO: Implement deposit action
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
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
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
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
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
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? _accent : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.0;
        final keyWidth = (constraints.maxWidth - spacing * 2) / 3;
        final keyHeight =
            (constraints.maxHeight - spacing * 3) / 4;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _padRow(['1', '2', '3'], keyBg, textColor, keyWidth, keyHeight,
                spacing),
            SizedBox(height: spacing),
            _padRow(['4', '5', '6'], keyBg, textColor, keyWidth, keyHeight,
                spacing),
            SizedBox(height: spacing),
            _padRow(['7', '8', '9'], keyBg, textColor, keyWidth, keyHeight,
                spacing),
            SizedBox(height: spacing),
            _padRow(['', '0', '⌫'], keyBg, textColor, keyWidth, keyHeight,
                spacing),
          ],
        );
      },
    );
  }

  Widget _padRow(List<String> keys, Color keyBg, Color textColor,
      double keyWidth, double keyHeight, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        final i = entry.key;
        final key = entry.value;
        final isLast = i == keys.length - 1;
        final isFirst = i == 0;

        if (key.isEmpty) {
          return SizedBox(width: keyWidth, height: keyHeight);
        }

        return Padding(
          padding: EdgeInsets.only(
            right: !isLast ? spacing : 0,
            left: isFirst ? 0 : 0,
          ),
          child: GestureDetector(
            onTap: () {
              if (key == '⌫') {
                _onBackspace();
              } else {
                _onDigit(key);
              }
            },
            child: Container(
              width: keyWidth,
              height: keyHeight,
              decoration: BoxDecoration(
                color: keyBg,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: key == '⌫'
                  ? Icon(Icons.backspace_outlined,
                      color: textColor, size: 24)
                  : Text(
                      key,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
