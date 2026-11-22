import 'package:bahasa_master/core/ads/ads_controller.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Adaptive banner. Renders nothing unless ads are on, the user is free, and
/// consent allows ad requests, so the layout never reserves empty space.
/// Where a banner sits: [main] above the bottom navigation (Home,
/// Learn), [quizResult] on lesson results, [practiceResult] at the end of Anki.
enum BannerAdPlacement { main, quizResult, practiceResult }

class AdBannerSlot extends ConsumerStatefulWidget {
  const AdBannerSlot({this.placement = BannerAdPlacement.main, super.key});

  final BannerAdPlacement placement;

  @override
  ConsumerState<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends ConsumerState<AdBannerSlot> {
  BannerAd? _ad;
  String? _unit;
  bool _loaded = false;
  int _width = 0;

  Future<void> _load(String unit, int width) async {
    if (_unit == unit && _width == width && _ad != null) return;
    _ad?.dispose();
    _unit = unit;
    _width = width;
    _loaded = false;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) return;
    final ad = BannerAd(
      adUnitId: unit,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(adsReadyProvider).valueOrNull;
    final placement = switch (widget.placement) {
      BannerAdPlacement.main => config?.banner,
      BannerAdPlacement.quizResult => config?.quizResultBanner,
      BannerAdPlacement.practiceResult => config?.practiceResultBanner,
    };
    if (placement == null || !placement.usable) {
      _ad?.dispose();
      _ad = null;
      _unit = null;
      return const SizedBox.shrink();
    }
    final width = MediaQuery.sizeOf(context).width.truncate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load(placement.unitId, width);
    });
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return Semantics(
      label: context.l10n.adsAd,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
