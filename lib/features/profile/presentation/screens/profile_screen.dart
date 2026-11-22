import 'dart:typed_data';

import 'package:bahasa_master/core/app_review/rate_app_link.dart';
import 'package:bahasa_master/core/widgets/legal_links.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/home/presentation/controllers/home_controller.dart';
import 'package:bahasa_master/features/profile/data/gamification_repository.dart';
import 'package:bahasa_master/features/profile/presentation/screens/attributions_screen.dart';
import 'package:bahasa_master/features/profile/presentation/widgets/gamification_widgets.dart';
import 'package:bahasa_master/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _imagePicker = ImagePicker();
  bool _uploadingPhoto = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/settings/display'),
                icon: const Icon(Icons.text_fields_rounded),
                label: Text(context.l10n.profileDisplaySettings),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('replay-onboarding'),
                onPressed: () => context.push('/onboarding?preview=1'),
                icon: const Icon(Icons.auto_stories_outlined),
                label: Text(context.l10n.profileAppGuide),
              ),
              const SizedBox(height: 12),
              Text(context.l10n.profileSignInTo),
              const LegalLinks(),
              const AttributionsLink(),
              const RateAppLink(),
            ],
          ),
        ),
      );
    }
    final gamification = ref.watch(gamificationProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(authControllerProvider.notifier).refreshUser();
        await ref
            .refresh(gamificationProvider.future)
            .then<void>((_) {}, onError: (Object error, StackTrace stack) {});
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        key: const PageStorageKey('profile-scroll'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.profileProfile,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: context.l10n.profileSettings,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _ProfileHeader(
                  user: user,
                  uploadingPhoto: _uploadingPhoto,
                  onChangePhoto: _uploadingPhoto ? null : _chooseProfilePhoto,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.profilePhotosAre,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                gamification.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => GamificationError(
                    retry: () => ref.invalidate(gamificationProvider),
                  ),
                  data: (data) => GamificationStats(data: data),
                ),
                if (!user.isLifetime && !user.isPremium) ...[
                  const SizedBox(height: 24),
                  _LifetimeCard(colorScheme: colorScheme),
                ],
                const SizedBox(height: 28),
                Text(
                  context.l10n.profileGamification,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                gamification.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (data) => Column(
                    children: [
                      ListTile(
                        key: const Key('profile-leaderboard-link'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Text(
                          '🏆',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(context.l10n.leaderboardTitle),
                        subtitle: Text(context.l10n.profileSeeThis),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/leaderboard'),
                      ),
                      for (final a in data.achievements.take(3))
                        AchievementTile(achievement: a),
                      TextButton.icon(
                        onPressed: () => context.push('/achievements'),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: Text(
                          context.l10n.profileViewAllAchievements(
                            data.unlockedCount,
                            data.achievements.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _ProfileMenu(),
                const SizedBox(height: 16),
                const LegalLinks(),
                const AttributionsLink(),
                const RateAppLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.profileChooseFrom),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.profileTakeA),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final l10n = context.l10n;

    setState(() => _uploadingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (photo == null || !mounted) return;
      final compressed = await FlutterImageCompress.compressWithFile(
        photo.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 82,
      );
      if (compressed == null || compressed.isEmpty) {
        throw AuthException(l10n.profilePhotoUnprocessable);
      }
      if (compressed.length > 8 * 1024 * 1024) {
        throw AuthException(l10n.profilePhotoTooLarge);
      }
      await ref
          .read(authControllerProvider.notifier)
          .uploadProfilePhoto(Uint8List.fromList(compressed));
      ref.invalidate(homeDashboardProvider);
      _showPhotoMessage(l10n.profilePhotoUpdated);
    } on AuthException catch (error) {
      _showPhotoMessage(error.message);
    } on Object {
      _showPhotoMessage(l10n.profilePhotoFailed);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showPhotoMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.uploadingPhoto,
    required this.onChangePhoto,
  });

  final AuthenticatedUser? user;
  final bool uploadingPhoto;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Semantics(
          button: onChangePhoto != null,
          label: context.l10n.profileChangeProfile,
          child: InkWell(
            onTap: onChangePhoto,
            customBorder: const CircleBorder(),
            child: Stack(
              children: [
                ProfileAvatar(
                  radius: 38,
                  displayName: user?.displayName ?? '',
                  photoUrl: user?.photoUrl,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: colorScheme.primary,
                      child: uploadingPhoto
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? context.l10n.profileDefaultName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? context.l10n.profileLoadingProfile,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 7),
              _PlanBadge(
                premium:
                    (user?.isPremium ?? false) || (user?.isLifetime ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.premium});
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE59E24).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        premium
            ? context.l10n.profilePlanLifetime
            : context.l10n.profilePlanFree,
        style: const TextStyle(
          color: Color(0xFFB87500),
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LifetimeCard extends StatelessWidget {
  const _LifetimeCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondary, const Color(0xFF3538A8)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.all_inclusive_rounded,
              color: Color(0xFFFFD166),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.commonLifetimeAccess,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.profileOnePayment,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/premium'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(context.l10n.profileView),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.auto_stories_outlined,
            title: context.l10n.profileAppGuide,
            onTap: () => context.push('/onboarding?preview=1'),
          ),
          const Divider(height: 1, indent: 68),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: context.l10n.profileSettings,
            onTap: () => context.push('/settings'),
          ),
          const Divider(height: 1, indent: 68),
          _ProfileMenuTile(
            icon: Icons.bar_chart_rounded,
            title: context.l10n.profileLearningStatistics,
            onTap: () => context.push('/achievements'),
          ),
          const Divider(height: 1, indent: 68),
          _ProfileMenuTile(
            icon: Icons.credit_card_rounded,
            title: context.l10n.profilePlansPayments,
            onTap: () => context.push('/premium'),
          ),
          const Divider(height: 1, indent: 68),
          _ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: context.l10n.profileHelp,
            onTap: () => openLegalPage(context, '/support'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  }) : iconColor = null;

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
