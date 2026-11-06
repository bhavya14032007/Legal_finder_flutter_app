import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_translations.dart';
import '../../core/widgets/ai_fab.dart';

/// Persistent Bottom Navigation Shell with AI Advisor Floating Action Button
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final navBg = isDark ? AppColors.darkBackground : Colors.white;
    final navBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final shellBorder = isDark ? const Color(0x337955F5) : const Color(0x1F7955F5);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: shellBorder,
          width: 1.5,
        ),
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: navigationShell,
        floatingActionButton: const AiFab(extended: true),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: navBg,
              border: Border(
                top: BorderSide(
                  color: navBorder,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  index: 0,
                  currentIndex: currentIndex,
                  label: ref.tr('nav_home'),
                  icon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  onTap: () => _onItemTapped(0),
                ),
                _NavBarItem(
                  index: 1,
                  currentIndex: currentIndex,
                  label: ref.tr('nav_explore'),
                  icon: Icons.explore_rounded,
                  unselectedIcon: Icons.explore_outlined,
                  onTap: () => _onItemTapped(1),
                ),
                _NavBarItem(
                  index: 2,
                  currentIndex: currentIndex,
                  label: ref.tr('nav_saved'),
                  icon: Icons.bookmark_rounded,
                  unselectedIcon: Icons.bookmark_border_rounded,
                  onTap: () => _onItemTapped(2),
                ),
                _NavBarItem(
                  index: 3,
                  currentIndex: currentIndex,
                  label: ref.tr('nav_me'),
                  icon: Icons.person_rounded,
                  unselectedIcon: Icons.person_outline_rounded,
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final IconData unselectedIcon;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.unselectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final selectedBg = isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE);
    final selectedBorder = isDark ? const Color(0xFF3730A3) : const Color(0xFFDDD6FE);
    final selectedColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF7955F5);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: selectedBorder,
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? icon : unselectedIcon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
