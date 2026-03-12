import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'deriv_no_account_screen.dart';
import 'deriv_success_screen.dart';
import 'mpesa_phone_screen.dart';
import '../services/auth_storage.dart';

// ─── Circular Chain Painter ───────────────────────────────────────────────────

class CircularChainPainter extends CustomPainter {
  final Color color;
  final Offset center;
  final double orbitRadius;
  final double tubeHalfWidth;
  final int linkCount;

  const CircularChainPainter({
    required this.color,
    required this.center,
    required this.orbitRadius,
    required this.tubeHalfWidth,
    required this.linkCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawTube(canvas);
    _drawLinks(canvas);
  }

  void _drawTube(Canvas canvas) {
    // Donut-shaped fill via even-odd path rule
    final path = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: orbitRadius + tubeHalfWidth),
      )
      ..addOval(
        Rect.fromCircle(center: center, radius: orbitRadius - tubeHalfWidth),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(28)
        ..style = PaintingStyle.fill,
    );

    final edgePaint = Paint()
      ..color = color.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, orbitRadius + tubeHalfWidth, edgePaint);
    canvas.drawCircle(center, orbitRadius - tubeHalfWidth, edgePaint);
  }

  void _drawLinks(Canvas canvas) {
    // Clip to just outside the tube so links don't bleed too far
    canvas.save();
    canvas.clipPath(
      Path()..addOval(
        Rect.fromCircle(
          center: center,
          radius: orbitRadius + tubeHalfWidth * 1.6,
        ),
      ),
    );

    // Two passes: back links (low opacity) then front links (high opacity)
    for (final front in [false, true]) {
      for (int i = 0; i < linkCount; i++) {
        final isFront = i.isEven;
        if (front != isFront) continue;

        // Static angle — no progress offset, chain never moves
        final angle = (i / linkCount) * 2 * pi;
        final lx = center.dx + orbitRadius * cos(angle);
        final ly = center.dy + orbitRadius * sin(angle);

        canvas.save();
        canvas.translate(lx, ly);
        // Rotate so the +X axis points radially outward at this angle
        canvas.rotate(angle);

        canvas.drawOval(
          // Long axis = radial (X after rotation), short axis = tangential (Y)
          Rect.fromCenter(
            center: Offset.zero,
            width: tubeHalfWidth * 1.9, // radial span
            height: tubeHalfWidth * 1.2, // tangential span
          ),
          Paint()
            ..color = color.withAlpha(isFront ? 210 : 60)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );

        canvas.restore();
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CircularChainPainter old) => false; // chain is static
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  // PKCE state — generated on launch, verified on callback
  String? _codeVerifier;
  String? _expectedState;

  // Binance flow state
  bool _waitingForBinanceId = false;
  Timer? _clipboardTimer;

  static const _accent = Color.fromARGB(255, 55, 194, 21);

  // Logo angles on the circle (screen coords: Y down, angle CW from +X)
  static const double _kpesaA = -pi / 2; // top
  static const double _derivA = -pi / 2 + 2 * pi / 3; // bottom-right (~30°)
  static const double _binanceA = -pi / 2 + 4 * pi / 3; // bottom-left (~150°)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _linkSub = _appLinks.uriLinkStream.listen(_onDeepLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardTimer?.cancel();
    _linkSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ── PKCE helpers ─────────────────────────────────────────────────────────────

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  // ── OAuth launch ─────────────────────────────────────────────────────────────

  Future<void> _launchDerivOAuth() async {
    _codeVerifier = _generateCodeVerifier();
    _expectedState = _generateState();

    final uri = Uri.https('oauth.deriv.com', '/oauth2/authorize', {
      'response_type': 'code',
      'app_id': '00010190',
      'redirect_uri': 'https://k-pesa.tech/deriv-callback',
      'scope': 'read trade trading_information payments',
      'state': _expectedState!,
      'code_challenge': _generateCodeChallenge(_codeVerifier!),
      'code_challenge_method': 'S256',
    });

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open Deriv')));
      }
    }
  }

  // ── Deep-link callback ───────────────────────────────────────────────────────
  // Deriv redirects to https://k-pesa.tech/deriv-callback?code=AUTH_CODE&state=...

  void _onDeepLink(Uri uri) {
    if (uri.host != 'k-pesa.tech' || uri.path != '/deriv-callback') return;

    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (state != _expectedState) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: invalid state')),
        );
      }
      return;
    }

    if (code != null && _codeVerifier != null) {
      _exchangeCodeForToken(code);
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    // ── Step 1: exchange auth code for tokens ─────────────────────────────────
    final tokenRes = await http.post(
      Uri.parse('https://oauth.deriv.com/oauth2/token'),
      body: {
        'grant_type': 'authorization_code',
        'client_id': '00010190',
        'code_verifier': _codeVerifier!,
        'code': code,
        'redirect_uri': 'https://k-pesa.tech/deriv-callback',
      },
    );

    if (!mounted) return;

    if (tokenRes.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed (${tokenRes.statusCode})')),
      );
      return;
    }

    final tokenData = jsonDecode(tokenRes.body) as Map<String, dynamic>;
    final accessToken = tokenData['access_token'] as String?;
    final refreshToken = tokenData['refresh_token'] as String?;
    final idToken = tokenData['id_token'] as String?;
    final expiresIn = (tokenData['expires_in'] as num?)?.toInt() ?? 3600;

    if (accessToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: no access token')),
        );
      }
      return;
    }

    // ── Step 2: save tokens securely ─────────────────────────────────────────
    await AuthStorage.instance.saveTokens(
      accessToken: accessToken,
      expiresIn: expiresIn,
      refreshToken: refreshToken,
      idToken: idToken,
    );

    // ── Step 3: fetch user info ───────────────────────────────────────────────
    final userRes = await http.get(
      Uri.parse('https://oauth.deriv.com/oauth2/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (!mounted) return;

    final String name;
    final String email;
    final String account;
    bool hasLiveAccount = false;

    if (userRes.statusCode == 200) {
      final user = jsonDecode(userRes.body) as Map<String, dynamic>;
      name = (user['name'] ?? user['given_name'] ?? '').toString();
      email = (user['email'] ?? '').toString();

      // CR prefix = live account, VRTC = virtual/demo
      final accounts = user['accounts'] as List? ?? [];
      final live = accounts.cast<Map>().firstWhere(
        (a) =>
            ((a['loginid'] ?? a['account'] ?? '') as String).startsWith('CR'),
        orElse: () => {},
      );
      hasLiveAccount = live.isNotEmpty;
      account = (live['loginid'] ?? live['account'] ?? '').toString();
    } else {
      name = (tokenData['name'] ?? '').toString();
      email = (tokenData['email'] ?? '').toString();
      account = '';
    }

    // ── Step 4: save profile securely ────────────────────────────────────────
    await AuthStorage.instance.saveProfile(
      account: account,
      name: name,
      email: email,
    );

    // ── Step 5: navigate ──────────────────────────────────────────────────────
    if (!mounted) return;

    if (hasLiveAccount) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              DerivSuccessScreen(name: name, email: email, account: account),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DerivNoAccountScreen()),
      );
    }
  }

  // ── Binance flow ─────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForBinanceId) {
      _checkClipboard();
    }
  }

  Future<void> _launchBinanceFlow() async {
    // Step 1 — pre-navigation popup
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3BA2F).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_rounded,
                color: Color(0xFFF3BA2F),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Copy your Binance UID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Binance will open next. Follow these steps:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const _StepRow(
              number: '1',
              text: 'Tap the profile icon (top-left)',
            ),
            const SizedBox(height: 6),
            const _StepRow(
              number: '2',
              text: 'Your UID is shown below your name',
            ),
            const SizedBox(height: 6),
            const _StepRow(
              number: '3',
              text: 'Tap the copy icon next to the UID',
            ),
            const SizedBox(height: 6),
            const _StepRow(number: '4', text: 'Return to this app'),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3BA2F),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK, Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Step 2 — open Binance app to the profile page
    try {
      await launchUrl(
        Uri.parse('bnc://app.binance.com/mp/app'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    // Step 3 — start polling clipboard every 2 s
    _waitingForBinanceId = true;
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkClipboard(),
    );
  }

  Future<void> _checkClipboard() async {
    if (!_waitingForBinanceId || !mounted) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) return;

    // Binance UIDs are typically 6-12 digit numbers
    if (RegExp(r'^\d{6,12}$').hasMatch(text)) {
      _clipboardTimer?.cancel();
      _waitingForBinanceId = false;
      if (mounted) _showBinanceCopiedDialog(text);
    }
  }

  void _showBinanceCopiedDialog(String binanceId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: _accent,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Binance ID Copied!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Successfully detected your Binance ID:\n$binanceId\n\nPress Continue to complete your K-PESA signup.',
              style: const TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MpesaPhoneScreen(binanceId: binanceId),
                  ),
                );
              }
            },
            child: const Text('Continue K-PESA Signup'),
          ),
        ],
      ),
    );
  }

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
                  'Sign up',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(height: 290, child: _buildChainScene(subtleColor)),
                const SizedBox(height: 24),
                Text(
                  'Please link your Deriv or Binance account to \n start sending and receiving money from M-pesa to Binance or Deriv with ease.',
                  style: TextStyle(
                    color: subtleColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _launchDerivOAuth,
                  child: const Text(
                    'Continue to Deriv',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    side: BorderSide(color: _accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _launchBinanceFlow,
                  child: Text(
                    "Don't have Deriv, continue to Binance",
                    style: TextStyle(fontSize: 15, color: _accent),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16, color: _accent),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Animation scene ─────────────────────────────────────────────────────────

  Widget _buildChainScene(Color subtleColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) =>
              _buildFrame(constraints.maxWidth, _controller.value, subtleColor),
        );
      },
    );
  }

  Widget _buildFrame(double width, double progress, Color subtleColor) {
    const sceneH = 290.0;
    const cy = 140.0; // vertical centre of the ring
    const orbitR = 88.0; // radius of the orbit circle
    const tubeHW = 17.0; // tube half-width (radial)
    final cx = width / 2;

    // ── Coin angles (two coins, 180° apart) ──
    final coinA1 = progress * 2 * pi;
    final coinA2 = coinA1 + pi;

    // ── Per-logo proximity → drives scale & glow ──
    final kpesaP = _maxProx(coinA1, coinA2, _kpesaA);
    final derivP = _maxProx(coinA1, coinA2, _derivA);
    final binanceP = _maxProx(coinA1, coinA2, _binanceA);

    // Scale: idle = 0.85, fully approached = 1.35
    double scaleOf(double p) => 0.85 + 0.50 * p;

    // ── Logo centre positions on the ring ──
    Offset onRing(double a) =>
        Offset(cx + orbitR * cos(a), cy + orbitR * sin(a));

    final kpesaC = onRing(_kpesaA);
    final derivC = onRing(_derivA);
    final binanceC = onRing(_binanceA);

    // ── Coin positions ──
    final coins = [
      Offset(cx + orbitR * cos(coinA1), cy + orbitR * sin(coinA1)),
      Offset(cx + orbitR * cos(coinA2), cy + orbitR * sin(coinA2)),
    ];

    return SizedBox(
      width: width,
      height: sceneH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1 ── Circular tube + chain links (lowest Z)
          Positioned.fill(
            child: CustomPaint(
              painter: CircularChainPainter(
                color: _accent,
                center: Offset(cx, cy),
                orbitRadius: orbitR,
                tubeHalfWidth: tubeHW,
                linkCount: 24,
              ),
            ),
          ),

          // 2 ── Coins (behind logos → disappear when they reach a logo)
          for (final c in coins)
            Positioned(left: c.dx - 13, top: c.dy - 13, child: _coin()),

          // 3 ── K-Pesa logo (top) — 90×56 landscape badge
          Positioned(
            left: kpesaC.dx - 45,
            top: kpesaC.dy - 28,
            child: Transform.scale(
              scale: scaleOf(kpesaP),
              child: _badge(
                asset: 'assets/k-pesa_logo.png',
                w: 90,
                h: 56,
                radius: 10,
                label: 'K-PESA',
                glowColor: _accent,
                glow: kpesaP,
                labelColor: subtleColor,
              ),
            ),
          ),

          // 4 ── Deriv logo (bottom-right) — 64×64 square badge
          Positioned(
            left: derivC.dx - 32,
            top: derivC.dy - 32,
            child: Transform.scale(
              scale: scaleOf(derivP),
              child: _badge(
                asset: 'assets/deriv.png',
                w: 64,
                h: 64,
                radius: 14,
                label: 'DERIV',
                glowColor: const Color(0xFFFF444F),
                glow: derivP,
                labelColor: subtleColor,
              ),
            ),
          ),

          // 5 ── Binance logo (bottom-left) — 64×64 square badge
          Positioned(
            left: binanceC.dx - 32,
            top: binanceC.dy - 32,
            child: Transform.scale(
              scale: scaleOf(binanceP),
              child: _badge(
                asset: 'assets/binance.png',
                w: 64,
                h: 64,
                radius: 14,
                label: 'BINANCE',
                glowColor: const Color(0xFFF3BA2F),
                glow: binanceP,
                labelColor: subtleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Greatest proximity of either coin to [logoAngle], in [0, 1].
  double _maxProx(double a1, double a2, double logoAngle) =>
      max(_prox(a1, logoAngle), _prox(a2, logoAngle));

  /// Angular proximity of one coin to a logo angle. 1 = same spot, 0 = far.
  double _prox(double coinAngle, double logoAngle) {
    double diff = (coinAngle - logoAngle).abs() % (2 * pi);
    if (diff > pi) diff = 2 * pi - diff;
    const threshold = pi / 2.2; // ≈ 82° approach zone
    return (1.0 - diff / threshold).clamp(0.0, 1.0);
  }

  Widget _coin() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          center: Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(200),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required String asset,
    required double w,
    required double h,
    required double radius,
    required String label,
    required Color glowColor,
    required double glow,
    required Color labelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: glow > 0.05
                ? [
                    BoxShadow(
                      color: glowColor.withAlpha((glow * 200).round()),
                      blurRadius: 18,
                      spreadRadius: 3 * glow,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.asset(asset, width: w, height: h, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Binance instruction step row ──────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFF3BA2F),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }
}
