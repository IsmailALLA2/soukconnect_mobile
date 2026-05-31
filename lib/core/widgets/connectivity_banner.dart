import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sizer.dart';

/// Listens to connectivity changes and shows a sticky red banner when offline.
/// Auto-hides with a green flash when connectivity is restored.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => ConnectivityBannerState();
}

class ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _offline = false;
  bool _showReconnected = false;
  late final AnimationController _bannerCtrl;
  late final Animation<Offset> _slide;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOutCubic));

    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _onChanged(results);

    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final connected = results.any(
      (r) => r != ConnectivityResult.none,
    );
    if (!mounted) return;
    if (!connected && !_offline) {
      setState(() => _offline = true);
      _bannerCtrl.forward();
    } else if (connected && _offline) {
      _bannerCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _offline = false;
          _showReconnected = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showReconnected = false);
        });
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_offline)
          AnimatedBuilder(
            animation: _slide,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _slide.value.dy * -40),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                color: AppColors.error,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 16, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      'Pas de connexion internet',
                      style: AppTextStyles.labelSmall(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_showReconnected)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            color: AppColors.success,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_rounded,
                    size: 16, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  'Connecté',
                  style: AppTextStyles.labelSmall(color: AppColors.white),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
