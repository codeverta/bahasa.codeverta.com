import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:bahasa_master/l10n/l10n.dart';

/// Distinct destinations, even when an older API has no banners yet.
/// Subscribers see Anki in place of the purchase offer.
List<HomeBanner> homeBannersFor(
  HomeDashboard data, {
  required bool lifetime,
  required AppLocalizations l10n,
}) {
  final defaults = [
    HomeBanner(
      id: 'learn',
      title: l10n.homeBannerLearnTitle,
      description: l10n.homeBannerLearnDescription,
      imageUrl: '',
      action: 'learn',
      buttonLabel: l10n.homeBannerLearnButton,
    ),
  ];
  final anki = HomeBanner(
    id: 'anki',
    title: l10n.homeBannerAnkiTitle,
    description: l10n.homeBannerAnkiDescription,
    imageUrl: '',
    action: 'anki',
    buttonLabel: l10n.homeBannerAnkiButton,
  );
  final plan =
      data.plans.where((p) => p.billingType == 'lifetime').firstOrNull ??
      data.plans.where((p) => p.recommended).firstOrNull;
  final offer = !lifetime && plan != null
      ? HomeBanner(
          id: 'lifetime-offer',
          title: plan.name,
          description: l10n.homeBannerOfferDescription,
          imageUrl: '',
          action: 'premium',
          buttonLabel: l10n.homeBannerOfferButton,
        )
      : null;
  HomeBanner configured(HomeBanner fallback) =>
      data.banners.where((b) => b.action == fallback.action).firstOrNull ??
      fallback;
  return [
    if (offer != null) offer,
    ...defaults.map(configured),
    if (offer == null) configured(anki),
  ];
}
