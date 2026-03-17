import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/channel.dart';
import '../../../../injection/service_locator.dart';

// Live page palette (reference UI: dark purple panels, amber accent)
const _livePanelWidthCategories = 220.0;
const _livePanelWidthChannels = 280.0;
const _liveDarkPurple = Color(0xFF2D1B4E);
const _liveLightPurple = Color(0xFF3D2B5C);
const _liveTabHighlight = Color(0xFFFFB300);

/// Live TV: categories (left), channels (middle), player (right). Top bar with tabs and search.
class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  /// null = "All"
  String? _selectedCategoryId;
  Channel? _selectedChannel;

  @override
  void initState() {
    super.initState();
    // Streaming screens: landscape only, no portrait.
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
    final categoriesAsync = ref.watch(liveCategoriesProvider);
    final channelsAsync = ref.watch(liveChannelsProvider);

    return Scaffold(
      backgroundColor: _liveDarkPurple,
      body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _livePanelWidthCategories,
              child: categoriesAsync.when(
                data: (categories) => _buildCategoriesPanel(
                  context,
                  theme,
                  categories,
                  channelsAsync.valueOrNull ?? [],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white70))),
              ),
            ),
            Container(
              width: 1,
              color: Colors.white12,
            ),
            SizedBox(
              width: _livePanelWidthChannels,
              child: channelsAsync.when(
                data: (allChannels) => _buildChannelsPanel(
                  context,
                  theme,
                  allChannels,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white70))),
              ),
            ),
            Container(
              width: 1,
              color: Colors.white12,
            ),
            Expanded(
              child: _buildPlayerColumn(context, theme),
            ),
          ],
        ),
    );
  }

  Widget _buildCategoriesPanel(
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

    final items = <_CategoryItem>[
      _CategoryItem(id: null, name: 'All', count: totalCount),
      ...categories.map((c) => _CategoryItem(id: c.id, name: c.name, count: categoryCounts[c.id] ?? 0)),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedCategoryId == item.id;
        return Material(
          color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selectedCategoryId = item.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isSelected ? 1 : 0.85),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.count}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelsPanel(BuildContext context, ThemeData theme, List<Channel> allChannels) {
    final filtered = _selectedCategoryId == null
        ? allChannels
        : allChannels.where((c) => c.categoryId == _selectedCategoryId).toList();

    return Container(
      color: _liveLightPurple,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final channel = filtered[index];
          final isSelected = _selectedChannel?.id == channel.id;
          return Material(
            color: isSelected ? _liveTabHighlight.withValues(alpha: 0.35) : Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedChannel = channel),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isSelected ? 1 : 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: channel.streamIcon != null && channel.streamIcon!.isNotEmpty
                          ? Image.network(
                              channel.streamIcon!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _channelIconPlaceholder(theme),
                            )
                          : _channelIconPlaceholder(theme),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        channel.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: isSelected ? 1 : 0.9),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _channelIconPlaceholder(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      color: Colors.white12,
      child: Icon(Icons.live_tv, size: 18, color: theme.colorScheme.primary),
    );
  }

  Widget _buildPlayerColumn(BuildContext context, ThemeData theme) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: _selectedChannel == null
                ? Center(
                    child: Text(
                      'Select a channel',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white54),
                    ),
                  )
                : _LivePlayer(
                    streamUrl: _selectedChannel!.streamUrl,
                    channelName: _selectedChannel!.name,
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: _liveDarkPurple, border: Border(top: BorderSide(color: Colors.white12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Catch Up'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _liveLightPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, size: 18),
                  label: const Text('Add to Favorite'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _liveLightPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _liveLightPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String? id;
  final String name;
  final int count;
  _CategoryItem({this.id, required this.name, required this.count});
}

/// Wraps better_player with channel name overlay.
class _LivePlayer extends StatefulWidget {
  final String streamUrl;
  final String channelName;

  const _LivePlayer({required this.streamUrl, required this.channelName});

  @override
  State<_LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<_LivePlayer> {
  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void didUpdateWidget(_LivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) _setupPlayer();
  }

  dynamic _controller;

  void _setupPlayer() {
    _controller?.dispose();
    try {
      final dataSource = BetterPlayerDataSource.network(
        widget.streamUrl,
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: 5000,
          maxBufferMs: AppConfig.videoBufferDuration.inMilliseconds,
          bufferForPlaybackMs: 2000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
      );
      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: AppConfig.autoPlay,
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: true,
            showControlsOnInitialize: false,
          ),
        ),
        betterPlayerDataSource: dataSource,
      );
    } catch (_) {
      _controller = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              widget.channelName,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        BetterPlayer(controller: _controller!),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Text(
              widget.channelName,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
