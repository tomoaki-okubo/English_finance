import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ad_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startAdAndNavigate();
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timeoutTimer?.cancel();
    context.go('/');
  }

  void _startAdAndNavigate() {
    // Set a maximum fallback timeout (e.g. 4 seconds) in case ad loading takes too long
    _timeoutTimer = Timer(const Duration(seconds: 4), () {
      _navigateToMain();
    });

    // Try showing App Open Ad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.showAppOpenAd(
        onAdDismissed: () {
          _navigateToMain();
        },
      );
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const Gap(28),
            const Text(
              '金融英語ドリル',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const Gap(8),
            Text(
              '- Finance English -',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1.0,
              ),
            ),
            const Gap(48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
