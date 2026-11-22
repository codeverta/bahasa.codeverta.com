import 'dart:async';

import 'package:bahasa_master/core/app_update/app_update_controller.dart';
import 'package:bahasa_master/core/app_update/app_update_policy.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _foreground = true;
  bool _openingStore = false;
  String? _storeError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(appUpdateControllerProvider.notifier).check());
      }
    });
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_foreground && mounted) {
        unawaited(ref.read(appUpdateControllerProvider.notifier).check());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(ref.read(appUpdateControllerProvider.notifier).check());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _openStore(AppUpdateState state) async {
    if (_openingStore) return;
    setState(() {
      _openingStore = true;
      _storeError = null;
    });
    try {
      var opened = false;
      if (state.device!.platform == 'android') {
        try {
          opened = await launchUrl(
            Uri.parse('market://details?id=com.codeverta.bahasa'),
            mode: LaunchMode.externalApplication,
          ).timeout(const Duration(seconds: 8));
        } on Object {
          // Devices without the native Play Store still get the HTTPS listing.
        }
      }
      if (!opened) {
        opened = await launchUrl(
          Uri.parse(state.policy!.storeUrl),
          mode: LaunchMode.externalApplication,
        ).timeout(const Duration(seconds: 8));
      }
      if (!opened) throw StateError('Store unavailable');
    } on Object {
      if (mounted) {
        setState(() => _storeError = context.l10n.appUpdateStoreOpenFailed);
      }
    } finally {
      if (mounted) setState(() => _openingStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUpdateControllerProvider);
    // Cached lessons must remain usable while an online version check is still
    // pending. A confirmed mandatory-update dialog continues to block access.
    final obscured = state.showDialog;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: obscured,
          child: ExcludeSemantics(
            excluding: obscured,
            child: AbsorbPointer(absorbing: obscured, child: widget.child),
          ),
        ),
        if (state.showDialog) ...[
          const ModalBarrier(dismissible: false, color: Colors.black54),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(child: _dialog(context, state)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _dialog(BuildContext context, AppUpdateState state) {
    final device = state.device!;
    final policy = state.policy!;
    final needsUpdate = state.requirement == AppUpdateRequirement.update;
    final canContinue =
        state.requirement == AppUpdateRequirement.unsupportedAllowed;
    final store = device.platform == 'android' ? 'Play Store' : 'App Store';
    const androidVersions = {
      21: '5.0',
      22: '5.1',
      23: '6',
      24: '7',
      25: '7.1',
      26: '8',
      27: '8.1',
      28: '9',
      29: '10',
      30: '11',
      31: '12',
      32: '12L',
      33: '13',
      34: '14',
      35: '15',
      36: '16',
    };
    final androidMinimum = androidVersions[policy.minimumAndroidApi];
    final requirement = device.platform == 'android'
        ? androidMinimum == null
              ? context.l10n.appUpdateANewer
              : context.l10n.appUpdateRequirementAndroid(androidMinimum)
        : context.l10n.appUpdateRequirementIos(policy.minimumIOSVersion);
    final instructions = device.platform == 'android'
        ? context.l10n.appUpdateOpenSettings
        : context.l10n.appUpdateOpenSettingsGeneral;
    return AlertDialog(
      title: Text(
        needsUpdate
            ? context.l10n.appUpdateUpdateBahasa
            : context.l10n.appUpdateYourDevice,
      ),
      icon: Icon(needsUpdate ? Icons.system_update : Icons.phonelink_erase),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              needsUpdate
                  ? context.l10n.appUpdateUnsupportedVersion(store)
                  : context.l10n.appUpdateRequirementNotMet(
                      requirement,
                      device.platform == 'android' ? 'Android' : 'iOS',
                      device.osVersion,
                    ),
            ),
            const SizedBox(height: 12),
            if (needsUpdate)
              Text(
                context.l10n.appUpdateVersions(
                  device.version,
                  policy.latestVersion,
                ),
              )
            else ...[
              Text(instructions),
              const SizedBox(height: 12),
              Text(
                canContinue
                    ? context.l10n.appUpdateYouCan
                    : context.l10n.appUpdateIfNo,
              ),
            ],
            if (policy.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(policy.message),
            ],
            if (needsUpdate)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(context.l10n.appUpdateIfThe),
              ),
            if (state.error != null || _storeError != null) ...[
              const SizedBox(height: 12),
              Text(
                _storeError ?? state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.checking
              ? null
              : () => ref.read(appUpdateControllerProvider.notifier).check(),
          child: Text(
            state.checking
                ? context.l10n.appUpdateChecking
                : context.l10n.appUpdateCheckAgain,
          ),
        ),
        if (canContinue)
          FilledButton(
            onPressed: () => ref
                .read(appUpdateControllerProvider.notifier)
                .continueOnLegacyDevice(),
            child: Text(context.l10n.appUpdateContinueWith),
          ),
        if (needsUpdate)
          FilledButton(
            onPressed: _openingStore ? null : () => _openStore(state),
            child: Text(
              _openingStore
                  ? context.l10n.appUpdateOpeningStore
                  : context.l10n.appUpdateUpdateNow,
            ),
          ),
      ],
    );
  }
}
