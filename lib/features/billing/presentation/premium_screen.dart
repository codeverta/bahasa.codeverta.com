import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/billing/presentation/billing_controller.dart';
import 'package:bahasa_master/features/billing/presentation/lifetime_offer.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/shared/presentation/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({this.offer, this.offerFrom, super.key});

  /// Set when opened as the skippable offer after login or periodically
  /// (lib/features/billing/presentation/lifetime_offer.dart): adds a close
  /// button and "Continue for free".
  final LifetimeOfferSource? offer;

  /// Where the offer continues to when skipped after login.
  final String? offerFrom;

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _left = false;

  bool get _hasAccess {
    final user = ref.read(authControllerProvider).user;
    return ref.read(billingControllerProvider).premium ||
        (user?.isLifetime ?? false) ||
        (user?.isPremium ?? false);
  }

  /// Leaves the offer: back to Home for the periodic one, otherwise on
  /// to the page the login was for.
  void _leaveOffer({required bool skipped}) {
    final offer = widget.offer;
    if (offer == null || _left || !mounted) return;
    _left = true;
    ref.read(analyticsServiceProvider).logEvent(
      skipped ? 'lifetime_offer_skip' : 'lifetime_offer_purchase',
      {'source': offer.wire},
    );
    if (offer == LifetimeOfferSource.periodic && context.canPop()) {
      context.pop();
    } else {
      context.go(lifetimeOfferTarget(widget.offerFrom));
    }
  }

  void _gainedAccess() {
    if (widget.offer == null || _left || !_hasAccess) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(context.l10n.billingLifetimeAccess)),
    );
    _leaveOffer(skipped: false);
  }

  @override
  void initState() {
    super.initState();
    // Lifetime may already be known by the time the offer opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gainedAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    // A purchase, restore or promo claim that completes while the offer is
    // open continues straight on.
    ref
      ..listen(billingControllerProvider.select((s) => s.premium), (_, next) {
        if (next) _gainedAccess();
      })
      ..listen(
        authControllerProvider.select(
          (s) => (s.user?.isLifetime ?? false) || (s.user?.isPremium ?? false),
        ),
        (_, next) {
          if (next) _gainedAccess();
        },
      );
    final auth = ref.watch(authControllerProvider);
    final billing = ref.watch(billingControllerProvider);
    final controller = ref.read(billingControllerProvider.notifier);
    final theme = Theme.of(context);
    final price =
        billing.product?.price ??
        (billing.busy
            ? context.l10n.billingCheckingStore
            : context.l10n.billingStorePrice);

    return PopScope(
      canPop: offer == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveOffer(skipped: true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.commonLifetimeAccess),
          automaticallyImplyLeading: offer == null,
          leading: offer == null
              ? null
              : IconButton(
                  key: const Key('lifetime-offer-close'),
                  tooltip: context.l10n.billingContinueFor,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => _leaveOffer(skipped: true),
                ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  StaggeredEntrance(
                    child: _LifetimeHero(active: billing.premium),
                  ),
                  const SizedBox(height: 16),
                  const _BenefitGrid(),
                  const SizedBox(height: 14),
                  _PriceNote(context.l10n.billingNoteSameAccount),
                  _PriceNote(context.l10n.billingNoteOneTime),
                  _PriceNote(context.l10n.billingNotePrice),
                  _PriceNote(context.l10n.billingNoteFreeContent),
                  const SizedBox(height: 6),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(
                        context.l10n.billingAboutYour,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      children: [
                        Text(
                          context.l10n.billingCanceledOr,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          children: [
                            TextButton(
                              onPressed: () => _help(
                                context,
                                'https://support.google.com/googleplay/answer/2479637',
                              ),
                              child: Text(context.l10n.billingGooglePlay),
                            ),
                            TextButton(
                              onPressed: () => _help(
                                context,
                                'https://support.apple.com/118223',
                              ),
                              child: Text(context.l10n.billingAppStore),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Price and buy button stay visible without scrolling.
            _CheckoutBar(
              price: price,
              message: billing.message,
              authenticated: auth.isAuthenticated,
              children: [
                if (!auth.isAuthenticated)
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(context.l10n.billingSignIn),
                  )
                else ...[
                  if (billing.premium) ...[
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () {
                        final from = GoRouterState.of(
                          context,
                        ).uri.queryParameters['from'];
                        context.go(
                          from != null &&
                                  (from.startsWith('/learn/') ||
                                      RegExp(r'^/anki/[^?#]+$').hasMatch(from))
                              ? from
                              : '/home',
                        );
                      },
                      child: Text(context.l10n.billingExploreMy),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (!billing.premium && billing.ownedBy != null) ...[
                    _OwnedElsewhere(
                      owner: billing.ownedBy!,
                      onSwitch: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton.icon(
                    key: const Key('buy-lifetime'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed:
                        billing.ready &&
                            !billing.busy &&
                            !billing.pending &&
                            !billing.premium &&
                            billing.ownedBy == null
                        ? () {
                            if (offer != null) {
                              ref.read(analyticsServiceProvider).logEvent(
                                'lifetime_offer_buy_tap',
                                {'source': offer.wire},
                              );
                            }
                            controller.buy();
                          }
                        : null,
                    icon: billing.busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_open),
                    label: Text(
                      billing.premium
                          ? context.l10n.billingAccessActive
                          : billing.pending
                          ? context.l10n.billingPaymentPending
                          : context.l10n.billingGetLifetime,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextButton(
                          onPressed: billing.busy ? null : controller.restore,
                          child: Text(
                            context.l10n.billingRestorePurchases,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Text('·', style: theme.textTheme.bodySmall),
                      Flexible(
                        child: TextButton(
                          onPressed: billing.busy ? null : controller.retry,
                          child: Text(
                            context.l10n.billingTryVerification,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (offer != null && !billing.premium)
                    TextButton(
                      key: const Key('lifetime-offer-skip'),
                      onPressed: () => _leaveOffer(skipped: true),
                      child: Text(context.l10n.billingContinueFor),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _help(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.billingCouldNot)));
    }
  }
}

/// Sticky bottom panel: price and buy button.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.price,
    required this.message,
    required this.authenticated,
    required this.children,
  });

  final String price;
  final String? message;
  final bool authenticated;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sakura = SakuraColors.of(context);
    final dark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: sakura.shadow.withValues(alpha: dark ? 0.5 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          key: const Key('lifetime-price-panel'),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          context.l10n.billingOnePayment,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: sakura.goldSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 14,
                            color: sakura.goldText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIFETIME',
                            style: TextStyle(
                              color: sakura.goldText,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    message!,
                    key: const Key('billing-message'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown instead of a checkout that Google Play would refuse: this Play
/// account already owns Lifetime for another app account.
class _OwnedElsewhere extends StatelessWidget {
  const _OwnedElsewhere({required this.owner, required this.onSwitch});
  final String owner;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final who = owner.isEmpty
        ? context.l10n.billingOwnedElsewhereUnnamed
        : context.l10n.billingOwnedElsewhereNamed(owner);
    return Container(
      key: const Key('billing-owned-elsewhere'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            who,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('billing-switch-account'),
              onPressed: onSwitch,
              icon: const Icon(Icons.switch_account_rounded),
              label: Text(context.l10n.billingSignInWithAnother),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifetimeHero extends StatelessWidget {
  const _LifetimeHero({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final sakura = SakuraColors.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: sakura.heroStart,
        borderRadius: BorderRadius.circular(24),
      ),
      // The card is 188 tall by default but grows with large accessibility
      // text instead of overflowing.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/explore/lifetime-access.webp',
              key: const Key('lifetime-illustration'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              cacheWidth: 1200,
              semanticLabel: context.l10n.billingLearnIndonesian,
              errorBuilder: (_, __, ___) => Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 72,
                    color: sakura.gold,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    sakura.heroStart,
                    sakura.heroStart.withValues(alpha: .9),
                    sakura.heroEnd.withValues(alpha: .25),
                  ],
                  stops: const [0, .45, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 148),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: sakura.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active
                                ? Icons.verified_rounded
                                : Icons.workspace_premium_rounded,
                            size: 14,
                            color: sakura.onGold,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              active
                                  ? context.l10n.billingLifetimeActive
                                  : context.l10n.billingOnePaymentLifetime,
                              style: TextStyle(
                                color: sakura.onGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FractionallySizedBox(
                    widthFactor: 0.72,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      active
                          ? context.l10n.billingLifetimeAccessIs
                          : context.l10n.billingUnlockMore,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FractionallySizedBox(
                    widthFactor: 0.72,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.billingStudyRead,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lifetime Access benefits in a compact two-column grid.
class _BenefitGrid extends StatelessWidget {
  const _BenefitGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        Icons.block_rounded,
        l10n.billingBenefitNoAdsTitle,
        l10n.billingBenefitNoAdsBody,
      ),
      (
        Icons.auto_awesome_rounded,
        l10n.billingBenefitAiTitle,
        l10n.billingBenefitAiBody,
      ),
      (
        Icons.download_for_offline_rounded,
        l10n.billingBenefitOfflineTitle,
        l10n.billingBenefitOfflineBody,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (index, item) in items.indexed)
              SizedBox(
                width: width,
                child: StaggeredEntrance(
                  index: index + 1,
                  child: _BenefitTile(
                    icon: item.$1,
                    title: item.$2,
                    subtitle: item.$3,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SakuraCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            maxLines: 2,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _PriceNote extends StatelessWidget {
  const _PriceNote(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: SakuraColors.of(context).success,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ),
      ],
    ),
  );
}
