import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/channel.dart';
import '../../../../injection/service_locator.dart';
import '../widgets/streaming_theme.dart';

/// Series: same layout as Live — top bar (Series tab), left sidebar (categories), grid of series cards.
/// Tap card → content detail page → Watch opens player.
class SeriesPage extends ConsumerStatefulWidget {
  const SeriesPage({super.key});

  @override
  ConsumerState<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends ConsumerState<SeriesPage> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(seriesCategoriesProvider);
    final channelsAsync = ref.watch(seriesChannelsProvider);

    return Scaffold(
      backgroundColor: streamingDarkPurple,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: streamingPanelWidthCategories,
            child: categoriesAsync.when(
              data: (categories) => _buildSidebar(
                context,
                theme,
                categories,
                channelsAsync.valueOrNull ?? [],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white70))),
            ),
          ),
          Container(width: 1, color: Colors.white12),
          Expanded(
            child: channelsAsync.when(
              data: (allChannels) => _buildGrid(context, theme, allChannels),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white70))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    ThemeData theme,
    List<Category> categories,
    List<Channel> allChannels,
  ) {
    final totalCount = allChannels.length;
    final categoryCounts = <String, int>{};
    for (final c in allChannels) {
      if (c.categoryId != null) {
        categoryCounts[c.categoryId!] = (categoryCounts[c.categoryId!] ?? 0) + 1;
      }
    }

    final items = <_SidebarItem>[
      _SidebarItem(id: null, name: 'Recently Viewed', count: 0),
      _SidebarItem(id: null, name: 'All', count: totalCount),
      _SidebarItem(id: null, name: 'Favorite', count: 0),
      ...categories.map((c) => _SidebarItem(id: c.id, name: c.name, count: categoryCounts[c.id] ?? 0)),
    ];

    return Container(
      color: streamingDarkPurple,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          IconButton(
            onPressed: () => context.go(AppConstants.homeRoute),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.white70, size: 22),
            title: const Text('Search', style: TextStyle(color: Colors.white70, fontSize: 14)),
            onTap: () {},
          ),
          const Divider(color: Colors.white12),
          ...items.map((item) {
            final isSelected = (item.name == 'All' && _selectedCategoryId == null) ||
                (item.id != null && _selectedCategoryId == item.id);
            return Material(
              color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
              child: ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isSelected ? 1 : 0.85),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${item.count}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ),
                onTap: () => setState(() {
                  if (item.name == 'All') _selectedCategoryId = null;
                  else _selectedCategoryId = item.id;
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ThemeData theme, List<Channel> allChannels) {
    final filtered = _selectedCategoryId == null
        ? allChannels
        : allChannels.where((c) => c.categoryId == _selectedCategoryId).toList();

    return Container(
      color: streamingLightPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: 'added',
                  dropdownColor: streamingDarkPurple,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  items: const [
                    DropdownMenuItem(value: 'added', child: Text('Order by added')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(width: 16),
                Text(
                  'All(${filtered.length})',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final channel = filtered[index];
                return _SeriesCard(
                  channel: channel,
                  onTap: () => context.push(AppConstants.homeContentDetailRoute, extra: channel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String? id;
  final String name;
  final int count;
  _SidebarItem({this.id, required this.name, required this.count});
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.channel, required this.onTap});

  final Channel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: channel.streamIcon != null && channel.streamIcon!.isNotEmpty
                    ? Image.network(
                        channel.streamIcon!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _placeholder(theme),
                      )
                    : _placeholder(theme),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: streamingTabHighlight.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('0.0', style: theme.textTheme.labelSmall?.copyWith(color: Colors.black87)),
            ),
            const SizedBox(height: 4),
            Text(
              channel.name,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: Colors.white12,
      child: Icon(Icons.tv, size: 48, color: theme.colorScheme.primary),
    );
  }
}
