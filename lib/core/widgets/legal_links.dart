import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _legalBaseUrl = String.fromEnvironment(
  'LEGAL_BASE_URL',
  defaultValue: 'https://bahasa.codeverta.com',
);

final _legalPages = <String, String Function(AppLocalizations)>{
  '/privacy-policy': (l10n) => l10n.legalPrivacyPolicy,
  '/terms-of-service': (l10n) => l10n.legalTermsOfService,
  '/refund-policy': (l10n) => l10n.legalRefundPolicy,
  '/delete-account': (l10n) => l10n.legalDataDeletion,
  '/support': (l10n) => l10n.legalSupport,
};

Future<void> openLegalPage(BuildContext context, String path) async {
  try {
    final uri = Uri.parse(_legalBaseUrl).resolve(path);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
  } catch (_) {
    // The device may not have a browser capable of handling the URL.
  }
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.legalThePage)));
  }
}

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (final page in _legalPages.entries)
          TextButton(
            onPressed: () => openLegalPage(context, page.key),
            child: Text(page.value(context.l10n)),
          ),
      ],
    );
  }
}
