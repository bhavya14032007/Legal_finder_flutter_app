import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ai_fab.dart';

/// Persistent Bottom Navigation Shell with AI Advisor Floating Action Button
class ScaffoldWithNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D18),
        border: Border.all(
          color: const Color(0x336366F1),
          width: 1.5,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        floatingActionButton: const AiFab(extended: true),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Container(
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFF080B14),
            border: Border(
              top: BorderSide(
                color: Color(0xFF1B233D),
                width: 1.2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                index: 0,
                currentIndex: currentIndex,
                label: 'Home',
                icon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
                onTap: () => _onItemTapped(0),
              ),
              _NavBarItem(
                index: 1,
                currentIndex: currentIndex,
                label: 'Explore',
                icon: Icons.explore_rounded,
                unselectedIcon: Icons.explore_outlined,
                onTap: () => _onItemTapped(1),
              ),
              _NavBarItem(
                index: 2,
                currentIndex: currentIndex,
                label: 'Saved',
                icon: Icons.bookmark_rounded,
                unselectedIcon: Icons.bookmark_border_rounded,
                onTap: () => _onItemTapped(2),
              ),
              _NavBarItem(
                index: 3,
                currentIndex: currentIndex,
                label: 'Me',
                icon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                onTap: () => _onItemTapped(3),
              ),
            ],
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
                color: isSelected ? const Color(0xFF1B233E) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFF38436E),
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
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
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
