import 'dart:async';

import 'package:bahasa_master/core/app_review/app_review_service.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tombol "Beri rating aplikasi" yang membuka halaman aplikasi di store.
/// Disembunyikan di platform yang tidak punya halaman store (web, desktop,
/// atau iOS selama [appStoreId] belum diisi).
class RateAppLink extends ConsumerWidget {
  const RateAppLink({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!storeListingAvailable()) return const SizedBox.shrink();
    return ListTile(
      key: const Key('rate-app'),
      leading: const Icon(Icons.star_outline_rounded, size: 21),
      title: Text(
        context.l10n.reviewRateThis,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: () => unawaited(_open(ref)),
    );
  }

  Future<void> _open(WidgetRef ref) async {
    try {
      await ref
          .read(storeReviewClientProvider)
          .openStoreListing(appStoreId: appStoreId.isEmpty ? null : appStoreId);
    } on Object {
      // Store tidak bisa dibuka (misalnya tidak ada Play Store): abaikan.
    }
  }
}
