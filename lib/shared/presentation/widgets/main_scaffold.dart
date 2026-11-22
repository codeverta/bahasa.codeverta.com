import 'dart:async';

import 'package:bahasa_master/core/ads/ad_widgets.dart';
import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/core/localization/app_localizations.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/billing/presentation/lifetime_offer.dart';
import 'package:bahasa_master/features/home/presentation/screens/dashboard_screen.dart';
import 'package:bahasa_master/features/learn/presentation/screens/learn_hub_screen.dart';
import 'package:bahasa_master/features/profile/presentation/screens/profile_screen.dart';
import 'package:bahasa_master/shared/presentation/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  Future<bool> _ensureAuthenticated() async {
    if (ref.read(authControllerProvider).isAuthenticated) return true;
    final result = await context.push<bool>('/login');
    return result ?? false;
  }

  Future<void> _selectDestination(int index) async {
    if (index == 0 || await _ensureAuthenticated()) {
      if (mounted) {
        setState(() => _selectedIndex = index);
        const tabs = ['home', 'learn', 'profile'];
        if (index >= 0 && index < tabs.length) {
          ref.read(analyticsServiceProvider).logTab(tabs[index]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screens = [
      // On the app's launch, may open the skippable Lifetime screen.
      LifetimeOfferLaunchCheck(
        child: DashboardScreen(
          active: _selectedIndex == 0,
          openLearn: () => _selectDestination(1),
          openProfile: () => _selectDestination(2),
        ),
      ),
      const LearnHubScreen(),
      const ProfileScreen(),
    ];
    ref.listen<AuthenticationState>(authControllerProvider, (previous, next) {
      if ((previous?.isAuthenticated ?? false) &&
          !next.isAuthenticated &&
          mounted) {
        setState(() => _selectedIndex = 0);
      }
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AuthGate(
          authorize: _ensureAuthenticated,
          child: IndexedStack(index: _selectedIndex, children: screens),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: const {0, 1}.contains(_selectedIndex),
            maintainState: true,
            child: const AdBannerSlot(),
          ),
          // The Profile tab never shows an ad.
          _buildNavigationBar(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, ColorScheme colorScheme) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 25,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Beranda'.localized(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_library_outlined),
            selectedIcon: const Icon(Icons.local_library_rounded),
            label: 'Belajar'.localized(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Profil'.localized(context),
          ),
        ],
      ),
    );
  }
}
