import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/shared/presentation/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Home quick menu: an icon grid so every feature is reachable without
/// scrolling. Learn and Profile stay in the bottom navigation.
class HomeQuickMenu extends StatelessWidget {
  const HomeQuickMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <HomeQuickMenuItem>[
      HomeQuickMenuItem(
        id: 'anki',
        label: 'Anki',
        light: const Color(0xFF0F8A7E),
        dark: const Color(0xFF5EEAD4),
        onTap: () => context.push('/anki'),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Four columns on phones; tablets get one row of eight.
        final columns = constraints.maxWidth >= 600 ? 8 : 4;
        final spacing = constraints.maxWidth < 330 ? 2.0 : 6.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          key: const Key('home-quick-menu'),
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: width,
                child: StaggeredEntrance(
                  index: i,
                  step: const Duration(milliseconds: 35),
                  child: _QuickMenuTile(item: items[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

@immutable
class HomeQuickMenuItem {
  const HomeQuickMenuItem({
    required this.id,
    required this.label,
    required this.light,
    required this.dark,
    required this.onTap,
    this.accentLight,
    this.accentDark,
    this.premium = false,
  });

  final String id;
  final String label;
  final Color light;
  final Color dark;
  final Color? accentLight;
  final Color? accentDark;
  final bool premium;
  final VoidCallback onTap;
}

class _QuickMenuTile extends StatelessWidget {
  const _QuickMenuTile({required this.item});

  final HomeQuickMenuItem item;

  static const _tile = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? item.dark : item.light;
    final accent = isDark
        ? (item.accentDark ?? const Color(0xFFFF8593))
        : (item.accentLight ?? const Color(0xFFD7263D));
    final surface = theme.colorScheme.surface;
    final label = item.label;
    return Pressable(
      key: Key('home-quick-${item.id}'),
      onTap: item.onTap,
      scale: 0.9,
      borderRadius: BorderRadius.circular(18),
      semanticsLabel: item.premium
          ? context.l10n.homeQuickMenuPremiumLabel(label)
          : label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _tile + 6,
            height: _tile + 6,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: _tile,
                    height: _tile,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: color.withValues(
                              alpha: isDark ? 0.16 : 0.12,
                            ),
                          ),
                        ),
                        // Soft "pressed edge" along the bottom of the tile.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 3,
                          child: ColoredBox(
                            color: color.withValues(alpha: 0.22),
                          ),
                        ),
                        Center(
                          child: SvgPicture.string(
                            homeQuickMenuSvg(
                              item.id,
                              color: color,
                              accent: accent,
                              surface: surface,
                            ),
                            width: 30,
                            height: 30,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.premium)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _PremiumCrown(ring: theme.scaffoldBackgroundColor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCrown extends StatelessWidget {
  const _PremiumCrown({required this.ring});

  final Color ring;

  @override
  Widget build(BuildContext context) {
    final sakura = SakuraColors.of(context);
    return Container(
      key: const Key('home-quick-premium'),
      width: 21,
      height: 21,
      decoration: BoxDecoration(
        color: sakura.gold,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.workspace_premium_rounded,
        size: 12,
        color: sakura.onGold,
      ),
    );
  }
}

String _hex(Color color) {
  final argb = color.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Builds the custom duotone icon for [id] (32×32 grid) with theme colors.
String homeQuickMenuSvg(
  String id, {
  required Color color,
  required Color accent,
  required Color surface,
}) {
  final body = _homeQuickMenuIcons[id] ?? '';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" '
          'fill="none" stroke="{C}" stroke-width="1.9" '
          'stroke-linecap="round" stroke-linejoin="round">$body</svg>'
      .replaceAll('{C}', _hex(color))
      .replaceAll('{A}', _hex(accent))
      .replaceAll('{S}', _hex(surface));
}

const _homeQuickMenuIcons = <String, String>{
  'anki':
      '<rect fill="{C}" fill-opacity="0.24" x="10" y="4" width="16" height="20" rx="2.5" transform="rotate(12 18 14)"/><rect fill="{S}" x="5" y="8" width="16" height="20" rx="2.5"/><circle fill="{A}" stroke="none" cx="13" cy="15.5" r="3.2"/><path d="M9.5 22.5h7"/>',
};
