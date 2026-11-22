import 'dart:async';

import 'package:bahasa_master/core/auth/offline_access.dart';
import 'package:bahasa_master/core/localization/app_language.dart';
import 'package:bahasa_master/core/network/dio_client.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/billing/data/billing_repository.dart';
import 'package:bahasa_master/features/home/presentation/controllers/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseGateway {
  Stream<List<PurchaseDetails>> get purchases;
  Future<bool> available();
  Future<ProductDetailsResponse> products(Set<String> ids);
  Future<bool> buy(PurchaseParam param);
  Future<void> restore(String token);
  Future<void> complete(PurchaseDetails purchase);
}

class NativePurchaseGateway implements PurchaseGateway {
  final InAppPurchase store = InAppPurchase.instance;
  @override
  Stream<List<PurchaseDetails>> get purchases => store.purchaseStream;
  @override
  Future<bool> available() => store.isAvailable();
  @override
  Future<ProductDetailsResponse> products(Set<String> ids) =>
      store.queryProductDetails(ids);
  @override
  Future<bool> buy(PurchaseParam param) =>
      store.buyNonConsumable(purchaseParam: param);
  @override
  Future<void> restore(String token) =>
      store.restorePurchases(applicationUserName: token);
  @override
  Future<void> complete(PurchaseDetails purchase) =>
      store.completePurchase(purchase);
}

class BillingState {
  const BillingState({
    this.product,
    this.priceIdr,
    this.premium = false,
    this.busy = false,
    this.pending = false,
    this.message,
    this.ready = false,
    this.ownedBy,
  });
  final ProductDetails? product;
  final int? priceIdr;
  final bool premium;
  final bool busy;
  final bool pending;
  final bool ready;
  final String? message;

  /// Set when the Play account on this device already owns Lifetime for
  /// another app account: that account's masked email, or '' when the server
  /// did not name it. Buying is impossible until the user switches accounts.
  final String? ownedBy;
}

final billingControllerProvider =
    StateNotifierProvider<BillingController, BillingState>((ref) {
      final platform =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? 'android'
          : !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : '';
      final controller = BillingController(
        repository: BillingRepository(
          ref.watch(dioProvider),
          offlineAccess: ref.watch(offlineAccessStoreProvider),
        ),
        gateway: platform.isEmpty ? null : NativePurchaseGateway(),
        platform: platform,
        offlineAccess: ref.watch(offlineAccessStoreProvider),
        onChanged: () async {
          await ref.read(authControllerProvider.notifier).refreshUser();
          ref.invalidate(homeDashboardProvider);
        },
      );
      ref.listen(authControllerProvider.select((s) => s.user?.id), (_, id) {
        unawaited(controller.setUser(id));
      });
      unawaited(controller.setUser(ref.read(authControllerProvider).user?.id));
      return controller;
    });

class BillingController extends StateNotifier<BillingState>
    with WidgetsBindingObserver {
  BillingController({
    required this.repository,
    required this.gateway,
    required this.platform,
    required this.onChanged,
    this.offlineAccess,
  }) : super(const BillingState()) {
    WidgetsBinding.instance.addObserver(this);
    subscription = gateway?.purchases.listen(
      (items) {
        unawaited(handle(items));
      },
      onError: (Object error) =>
          showMessage(appL10n().billingStoreConnectionLost),
    );
  }
  final BillingRepository repository;
  final PurchaseGateway? gateway;
  final String platform;
  final Future<void> Function() onChanged;
  final OfflineAccessStore? offlineAccess;
  StreamSubscription<List<PurchaseDetails>>? subscription;
  Future<void> queue = Future<void>.value();
  BillingAccount? account;
  String? user;
  final Map<String, PurchaseDetails> retryPurchases = {};
  final Set<String> completed = {};
  final Map<String, PurchaseDetails> waitingForLogin = {};
  bool restoring = false;
  bool recovering = false;
  Timer? checkoutTimeout;

  /// See [BillingState.ownedBy].
  String? ownedBy;

  void showMessage(String? message, {bool busy = false, bool pending = false}) {
    if (!mounted) return;
    if (!busy) checkoutTimeout?.cancel();
    state = BillingState(
      ownedBy: ownedBy,
      product: state.product,
      priceIdr: state.priceIdr,
      premium: state.premium,
      ready: state.ready,
      busy: busy,
      pending: pending,
      message: message,
    );
  }

  Future<void> setUser(String? id) async {
    if (id == user) return;
    user = id;
    account = null;
    ownedBy = null;
    retryPurchases.clear();
    completed.clear();
    state = const BillingState();
    if (id != null) await refresh();
    if (id != null &&
        user == id &&
        account != null &&
        waitingForLogin.isNotEmpty) {
      final waiting = waitingForLogin.values.toList();
      waitingForLogin.clear();
      await handle(waiting);
    }
    if (id != null &&
        user == id &&
        platform == 'android' &&
        account != null &&
        account!.platforms.contains(platform)) {
      try {
        await gateway?.restore(account!.accountToken);
      } on Object {
        showMessage(appL10n().billingCheckOldPurchasesFailed);
      }
    }
  }

  Future<void> refresh() async {
    final id = user;
    if (id == null) {
      showMessage(appL10n().billingSignInToBuy);
      return;
    }
    showMessage(appL10n().billingCheckingAccess, busy: true);
    try {
      final info = await repository.status(userId: id);
      if (!mounted || user != id) return;
      account = info;
      if (info.premium) ownedBy = null;
      state = BillingState(
        ownedBy: ownedBy,
        premium: info.premium,
        priceIdr: info.priceIdr,
        busy: true,
      );
      if (gateway == null ||
          !info.platforms.contains(platform) ||
          !await gateway!.available()) {
        if (mounted && user == id) {
          state = BillingState(
            ownedBy: ownedBy,
            premium: info.premium,
            priceIdr: info.priceIdr,
            message: appL10n().billingStoreUnavailable,
          );
        }
        await onChanged();
        return;
      }
      final result = await gateway!.products({info.productId});
      if (!mounted || user != id) return;
      final found = result.productDetails
          .where((p) => p.id == info.productId)
          .firstOrNull;
      state = BillingState(
        ownedBy: ownedBy,
        premium: info.premium,
        product: found,
        priceIdr: info.priceIdr,
        ready: found != null,
        message: found == null ? appL10n().billingProductUnavailable : null,
      );
      await onChanged();
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) await onChanged();
      if (mounted && user == id) {
        final offlinePremium =
            await offlineAccess?.canReadPremium(id) ?? state.premium;
        if (!mounted || user != id) return;
        state = BillingState(
          ownedBy: ownedBy,
          product: state.product,
          priceIdr: state.priceIdr,
          premium: offlinePremium,
          ready: state.ready,
          message: error.response?.statusCode == 403
              ? appL10n().billingSharedDemoAccount
              : appL10n().billingSessionProblem,
        );
      }
    } on Object {
      if (mounted && user == id) {
        final offlinePremium =
            await offlineAccess?.canReadPremium(id) ?? state.premium;
        if (!mounted || user != id) return;
        state = BillingState(
          ownedBy: ownedBy,
          product: state.product,
          priceIdr: state.priceIdr,
          premium: offlinePremium,
          ready: state.ready,
          message: appL10n().billingAccessCheckFailed,
        );
      }
    }
  }

  Future<void> buy() async {
    if (state.busy ||
        state.pending ||
        state.premium ||
        ownedBy != null ||
        !state.ready ||
        account == null ||
        user == null) {
      return;
    }
    showMessage(appL10n().billingCompletePayment, busy: true);
    checkoutTimeout?.cancel();
    checkoutTimeout = Timer(const Duration(seconds: 90), () {
      showMessage(appL10n().billingStoreNoResult);
    });
    try {
      final started = await gateway!.buy(
        PurchaseParam(
          productDetails: state.product!,
          applicationUserName: account!.accountToken,
        ),
      );
      if (!started) {
        // Google Play refuses to start checkout when this Play account already
        // owns Lifetime ("You already own this item"). Restore it instead:
        // either it belongs to this app account (or to none yet, like a
        // redeemed promo code) and unlocks now, or the owner is named.
        await recoverOwned(appL10n().billingPlayDidNotContinue);
      }
    } on Object {
      showMessage(appL10n().billingPaymentCouldNotStart);
    }
  }

  Future<void> restore() async {
    if (state.busy || gateway == null || account == null || user == null) {
      return;
    }
    restoring = true;
    showMessage(appL10n().billingRestoring, busy: true);
    try {
      await gateway!
          .restore(account!.accountToken)
          .timeout(const Duration(seconds: 25));
      await queue;
      if (restoring) {
        await refresh();
        showMessage(
          state.premium
              ? appL10n().billingLifetimeAccess
              : appL10n().billingRestoreNothingFound,
        );
      }
    } on Object {
      showMessage(appL10n().billingRestoreFailed);
    } finally {
      restoring = false;
    }
  }

  /// Restores this Play account's purchases after Google Play reported the
  /// item as already owned. Shows [fallback] when nothing was found.
  Future<void> recoverOwned(String fallback) async {
    if (recovering) return;
    final id = user;
    if (gateway == null || account == null || id == null) {
      showMessage(fallback);
      return;
    }
    recovering = true;
    showMessage(appL10n().billingCheckingExistingLifetime, busy: true);
    try {
      await gateway!
          .restore(account!.accountToken)
          .timeout(const Duration(seconds: 25));
      // Restored purchases reach the stream listener asynchronously.
      await Future<void>.delayed(Duration.zero);
      await queue;
    } on Object catch (error) {
      debugPrint('Restore after already-owned failed: $error');
    } finally {
      recovering = false;
    }
    if (!mounted || user != id) return;
    // Verification replaces the busy message with its own outcome.
    if (state.busy && !state.premium && ownedBy == null) showMessage(fallback);
  }

  Future<void> retry() async {
    await refresh();
    await handle(retryPurchases.values.toList());
  }

  Future<void> handle(List<PurchaseDetails> items) async {
    queue = queue.then((_) => _handle(items)).catchError((Object error) {
      showMessage(appL10n().billingPurchaseNotFinished);
    });
    await queue;
  }

  Future<void> _handle(List<PurchaseDetails> items) async {
    for (final purchase in items) {
      // Google Play can report a canceled or failed billing launch without a
      // PurchaseWrapper, so the plugin emits a PurchaseDetails with an empty
      // product ID. Handle those results before filtering by product ID.
      if (purchase.productID.isEmpty &&
          purchase.status == PurchaseStatus.canceled) {
        showMessage(appL10n().billingPaymentCanceledNoCharge);
        if (purchase.pendingCompletePurchase) {
          await gateway!.complete(purchase);
        }
        continue;
      }
      if (purchase.productID.isEmpty &&
          purchase.status == PurchaseStatus.error &&
          '${purchase.error?.message}'.contains('itemAlreadyOwned')) {
        if (purchase.pendingCompletePurchase) {
          await gateway!.complete(purchase);
        }
        // Runs after this queue entry so it can wait for the restore.
        unawaited(
          Future<void>(() => recoverOwned(appL10n().billingPlayOwnedNotFound)),
        );
        continue;
      }
      if (purchase.productID.isEmpty &&
          purchase.status == PurchaseStatus.error) {
        showMessage(appL10n().billingPlayCouldNotStart);
        if (purchase.pendingCompletePurchase) {
          await gateway!.complete(purchase);
        }
        continue;
      }
      if (account == null || user == null) {
        waitingForLogin['${purchase.productID}:${purchase.purchaseID}'] =
            purchase;
        continue;
      }
      if (purchase.productID != account!.productId) {
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.pending:
          showMessage(appL10n().billingPaymentAwaitingApproval, pending: true);
          continue;
        case PurchaseStatus.canceled:
          showMessage(appL10n().billingPaymentCanceledNoAccess);
          if (purchase.pendingCompletePurchase) {
            await gateway!.complete(purchase);
          }
          continue;
        case PurchaseStatus.error:
          showMessage(appL10n().billingPaymentFailed);
          if (purchase.pendingCompletePurchase) {
            await gateway!.complete(purchase);
          }
          continue;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          break;
      }
      final key =
          '${purchase.productID}:${purchase.purchaseID ?? purchase.verificationData.serverVerificationData}';
      if (completed.contains(key)) continue;
      retryPurchases[key] = purchase;
      final id = user;
      showMessage(appL10n().billingVerifying, busy: true);
      try {
        final result = await repository.verify(
          platform: platform,
          productId: purchase.productID,
          proof: purchase.verificationData.serverVerificationData,
          transactionId: platform == 'ios' ? purchase.purchaseID : null,
          userId: id,
        );
        if (!mounted || user != id) continue;
        if (result == 'pending') {
          showMessage(appL10n().billingPaymentStillPending, pending: true);
          continue;
        }
        // Finish only after server verification and durable ownership have succeeded.
        if (purchase.pendingCompletePurchase) await gateway!.complete(purchase);
        completed.add(key);
        retryPurchases.remove(key);
        restoring = false;
        await refresh();
        if (!mounted || user != id) continue;
        showMessage(
          result == 'purchased'
              ? appL10n().billingLifetimeActivated
              : appL10n().billingPurchaseRevoked,
        );
      } on DioException catch (error) {
        if (error.response?.statusCode == 401) await onChanged();
        if (!mounted || user != id) continue;
        final body = error.response?.data;
        final failure = body is Map ? body['error'] : null;
        if (error.response?.statusCode == 409 &&
            failure is Map &&
            failure['code'] == 'purchase_owned') {
          // Owned by another app account: nothing to retry. It is verified
          // again on the next restore, after the user switches accounts.
          retryPurchases.remove(key);
          restoring = false;
          ownedBy = '${failure['owner'] ?? ''}';
          showMessage(null);
          continue;
        }
        showMessage(
          error.response?.statusCode == 402
              ? appL10n().billingPurchaseOtherAccount
              : appL10n().billingVerificationUnfinished,
        );
      } on Object {
        if (mounted && user == id) {
          showMessage(appL10n().billingPurchaseNotFinished);
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        user != null &&
        !this.state.busy) {
      unawaited(retry());
      // The user may have switched the Play Store account to buy again.
      if (ownedBy != null) unawaited(recheckOwnership());
    }
  }

  /// Clears the "owned by another account" lock and restores again, so a
  /// switched Play account can buy. A purchase still owned elsewhere sets it
  /// again.
  Future<void> recheckOwnership() async {
    final token = account?.accountToken;
    if (gateway == null || token == null) return;
    ownedBy = null;
    showMessage(state.message, busy: state.busy, pending: state.pending);
    try {
      await gateway!.restore(token);
    } on Object catch (error) {
      debugPrint('Ownership recheck failed: $error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    checkoutTimeout?.cancel();
    unawaited(subscription?.cancel());
    super.dispose();
  }
}
