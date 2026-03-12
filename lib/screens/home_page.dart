import 'package:flutter/material.dart';
import 'deposit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _accentColor => const Color.fromARGB(255, 55, 194, 21);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleColor = isDark ? Colors.white70 : Colors.black54;
    final cardBgColor = isDark
        ? const Color.fromARGB(255, 40, 40, 40)
        : const Color.fromARGB(255, 245, 245, 245);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textColor),
              const SizedBox(height: 32),
              _buildBalanceCard(isDark),
              const SizedBox(height: 24),
              _buildActionButtons(isDark),
              const SizedBox(height: 32),
              _buildTransactionsSection(cardBgColor, textColor, subtleColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Eddy Kimani',
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 100, 100, 100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor,
            _accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deriv Balance',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '0.00 USD',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MT5 Balance',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '0.00 USD',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DepositPage()),
              );
            },
            child: const Text(
              'Deposit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              side: BorderSide(
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              // TODO: Implement withdraw logic
            },
            child: Text(
              'Withdraw',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(
    Color cardBgColor,
    Color textColor,
    Color subtleColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedMoneyWidget(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'No Transactions',
                      style: TextStyle(
                        color: subtleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedMoneyWidget extends StatelessWidget {
  final AnimationController animationController;

  const AnimatedMoneyWidget({
    required this.animationController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Falling coin 1
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -50 + (50 * (animationController.value * 2 % 1)),
                  -100 + (200 * animationController.value),
                ),
                child: Opacity(
                  opacity: 1 - (animationController.value * 0.3),
                  child: Transform.rotate(
                    angle: animationController.value * 12.56,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 255, 200, 50),
                            const Color.fromARGB(255, 255, 150, 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 255, 150, 0)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '\$',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Falling coin 2
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final offsetValue = (animationController.value - 0.33) % 1;
              return Transform.translate(
                offset: Offset(
                  50 + (50 * (offsetValue * 2 % 1)),
                  -100 + (200 * offsetValue),
                ),
                child: Opacity(
                  opacity: 1 - (offsetValue * 0.3),
                  child: Transform.rotate(
                    angle: offsetValue * 12.56,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 255, 200, 50),
                            const Color.fromARGB(255, 255, 150, 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 255, 150, 0)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '\$',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Falling coin 3
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final offsetValue = (animationController.value - 0.66) % 1;
              return Transform.translate(
                offset: Offset(
                  0 + (50 * (offsetValue * 2 % 1)),
                  -100 + (200 * offsetValue),
                ),
                child: Opacity(
                  opacity: 1 - (offsetValue * 0.3),
                  child: Transform.rotate(
                    angle: offsetValue * 12.56,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 255, 200, 50),
                            const Color.fromARGB(255, 255, 150, 0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 255, 150, 0)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '\$',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Sparkles/stars
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -60 * (2 * (animationController.value % 0.5) - 1),
                  -80 + (160 * animationController.value),
                ),
                child: Opacity(
                  opacity: 1 - (animationController.value * 0.5),
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
          // Central money bag icon
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: const Color.fromARGB(255, 76, 175, 80).withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
