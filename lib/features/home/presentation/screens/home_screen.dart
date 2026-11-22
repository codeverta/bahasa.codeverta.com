import 'package:bahasa_master/features/home/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

/// Compatibility wrapper untuk pemanggil lama.
///
/// Navigasi utama baru menggunakan [DashboardScreen] melalui MainScaffold.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.openLearn,
    required this.openProfile,
    super.key,
  });

  final VoidCallback openLearn;
  final VoidCallback openProfile;

  @override
  Widget build(BuildContext context) =>
      DashboardScreen(openLearn: openLearn, openProfile: openProfile);
}
