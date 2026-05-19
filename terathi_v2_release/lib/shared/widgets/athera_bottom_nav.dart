import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AtheraBottomNav extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AtheraBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<AtheraBottomNav> createState() => _AtheraBottomNavState();
}

class _AtheraBottomNavState extends ConsumerState<AtheraBottomNav> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AtheraBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync PageController if index changed from outside (e.g. deep link)
    if (widget.navigationShell.currentIndex != _pageController.page?.round()) {
      _pageController.jumpToPage(widget.navigationShell.currentIndex);
    }
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (index != widget.navigationShell.currentIndex) {
            widget.navigationShell.goBranch(index);
          }
        },
        // Important: We render the navigationShell as the children.
        // In GoRouter, StatefulNavigationShell is a widget that renders the current branch.
        // To support swiping, we would ideally need a list of branch widgets.
        // Since GoRouter doesn't expose them directly to the builder, 
        // we use a workaround or keep using navigationShell but it won't show 
        // the "next" page during swipe unless we have them all in the tree.
        
        // Fix: Since we want a "premium" experience, we'll render all branches
        // manually to enable smooth swiping between them.
        physics: const BouncingScrollPhysics(),
        children: [
          _BranchWrapper(index: 0, navigationShell: widget.navigationShell),
          _BranchWrapper(index: 1, navigationShell: widget.navigationShell),
          _BranchWrapper(index: 2, navigationShell: widget.navigationShell),
          _BranchWrapper(index: 3, navigationShell: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: widget.navigationShell.currentIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'الرئيسية',
                  onTap: () => _onItemTapped(0),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: widget.navigationShell.currentIndex,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'استكشاف',
                  onTap: () => _onItemTapped(1),
                ),
                _NavItem(
                  index: 2,
                  currentIndex: widget.navigationShell.currentIndex,
                  icon: Icons.bookmark_border_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'المحفوظات',
                  onTap: () => _onItemTapped(2),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: widget.navigationShell.currentIndex,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'حسابي',
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

/// Helper to render a specific branch of the navigation shell.
class _BranchWrapper extends StatelessWidget {
  final int index;
  final StatefulNavigationShell navigationShell;

  const _BranchWrapper({required this.index, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // If it's the current index, we render the shell's active widget.
    // Otherwise, we might need a way to render other branches.
    // In GoRouter, you can use navigationShell.getBranchNavigator(index)
    // if you use a custom shell implementation.
    
    // For now, to keep it simple and stable with the current router:
    return navigationShell.currentIndex == index 
        ? navigationShell 
        : const SizedBox.shrink(); 
        // Note: Full swiping between navigators requires a more complex 
        // StatefulShellRoute implementation.
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Cairo',
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

