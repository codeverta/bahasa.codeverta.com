import 'package:bahasa_master/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AttributionsLink extends StatelessWidget {
  const AttributionsLink({super.key});
  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('open-attributions'),
    leading: const Icon(Icons.source_outlined, size: 21),
    title: Text(
      'Sumber data & atribusi'.localized(context),
      style: const TextStyle(fontSize: 13),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: () => context.push('/attributions'),
  );
}

class AttributionsScreen extends StatelessWidget {
  const AttributionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Sumber data & atribusi'.localized(context))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Dibangun bersama banyak sumber'.localized(context),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          'Terima kasih kepada penerbit, pembuat dataset, dan komunitas yang menjadi sumber konten Bahasa Master. Hak cipta tetap milik masing-masing pemilik.'
              .localized(context),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: 'Bahasa Master',
          ),
          icon: const Icon(Icons.code_rounded),
          label: Text('Lisensi perangkat lunak open source'.localized(context)),
        ),
      ],
    ),
  );
}
