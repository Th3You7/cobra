import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

/// Shared colors and sizes for Live, Movies, Series (reference UI: dark purple + amber).
const streamingPanelWidthCategories = 220.0;
const streamingDarkPurple = Color(0xFF2D1B4E);
const streamingLightPurple = Color(0xFF3D2B5C);
const streamingTabHighlight = Color(0xFFFFB300);

/// Which tab is active for navigation highlighting.
enum StreamingTab { home, live, movies, series }

/// Wraps streaming routes so the top bar is a single shared component built by the router.
/// Use with [ShellRoute] so navigation bar taps use the shell's context and work reliably.
class StreamingShell extends StatelessWidget {
  const StreamingShell({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Reusable top bar for Live, Movies, Series: profile, tabs (navigational), search, logo.
class StreamingTopBar extends StatelessWidget {
  const StreamingTopBar({
    super.key,
    required this.activeTab,
    this.appTitle = 'Cobra IPTV',
  });

  final StreamingTab activeTab;
  final String appTitle;

  static void _navigate(BuildContext context, String path) {
    GoRouter.of(context).go(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: streamingDarkPurple,
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Material(
            color: streamingTabHighlight,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.person, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _StreamingTab(
            label: 'Home',
            isSelected: activeTab == StreamingTab.home,
            onTap: () => _navigate(context, AppConstants.homeRoute),
          ),
          _StreamingTab(
            label: 'Live',
            isSelected: activeTab == StreamingTab.live,
            onTap: () => _navigate(context, AppConstants.homeLiveRoute),
          ),
          _StreamingTab(
            label: 'Movies',
            isSelected: activeTab == StreamingTab.movies,
            onTap: () => _navigate(context, AppConstants.homeMoviesRoute),
          ),
          _StreamingTab(
            label: 'Series',
            isSelected: activeTab == StreamingTab.series,
            onTap: () => _navigate(context, AppConstants.homeSeriesRoute),
          ),
          const Spacer(),
          SizedBox(
            width: 200,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            appTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingTab extends StatelessWidget {
  const _StreamingTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? streamingTabHighlight : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? streamingTabHighlight : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
