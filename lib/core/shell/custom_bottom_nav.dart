import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Floating navbar: pill shape, frosted glass (blur) so background shows through.
/// Selected item: orange pill with white icon + label.
/// Unselected items: white circles with orange outline icon only.
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItem> items;

  static const double _horizontalMargin = 20;
  static const double _bottomMargin = 12;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalMargin,
        0,
        _horizontalMargin,
        _bottomMargin + bottomSafe,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SizedBox(
                height: _circleSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final selected = index == currentIndex;
                    return _NavItem(
                      item: item,
                      selected: selected,
                      onTap: () => onTap(index),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nav bar content height: icon (24) + equal space above/below.
const double _circleSize = 66;

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CustomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const double _iconSize = 24;

  /// İkon (24) üst ve altında eşit boşluk: (54 - 24) / 2 = 15
  static const double _iconVerticalPadding = 20;

  Widget _buildIcon(Color color) {
    if (item.assetPath != null) {
      return Image.asset(
        item.assetPath!,
        width: _iconSize,
        height: _iconSize,
        color: color,
      );
    }
    return Icon(item.icon, size: _iconSize, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: selected
              ? const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: _iconVerticalPadding,
                )
              : const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandOrange : Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: selected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(AppColors.brandWhite),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandWhite,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: _circleSize,
                  height: _circleSize,
                  child: Center(
                    child: _buildIcon(AppColors.brandOrange),
                  ),
                ),
        ),
      ),
    );
  }
}

class CustomNavItem {
  const CustomNavItem({this.icon, this.assetPath, required this.label})
      : assert(icon != null || assetPath != null);
  final IconData? icon;
  final String? assetPath;
  final String label;
}
