import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/source.dart';
import '../../../../injection/service_locator.dart';

/// Playlist screen: grid of source cards + Add Playlist card.
/// Each card shows name/URL, type, status; Remove (with confirmation) and Retry (when error).
class PlaylistPage extends ConsumerWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(sourcesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
      ),
      body: sourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error: $err', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
          ),
        ),
        data: (sources) => _PlaylistGrid(sources: sources),
      ),
    );
  }
}

class _PlaylistGrid extends StatelessWidget {
  final List<Source> sources;

  const _PlaylistGrid({required this.sources});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.paddingMedium),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: sources.length + 1,
        itemBuilder: (context, index) {
          if (index == sources.length) {
            return _AddPlaylistCard(onTap: () => context.push(AppConstants.homePlaylistAddRoute));
          }
          return _SourceCard(source: sources[index]);
        },
      ),
    );
  }
}

class _AddPlaylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                'Add Playlist',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends ConsumerWidget {
  final Source source;

  const _SourceCard({required this.source});

  static String _truncateUrl(String url, {int maxLen = 32}) {
    if (url.length <= maxLen) return url;
    return '${url.substring(0, maxLen)}...';
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Connected';
      case 'syncing':
        return 'Syncing';
      case 'error':
        return 'Error';
      case 'removing':
        return 'Removing';
      default:
        return 'Idle';
    }
  }

  static Color _statusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'success':
        return Colors.blue;
      case 'syncing':
        return Colors.orange;
      case 'error':
        return theme.colorScheme.error;
      case 'removing':
        return Colors.grey;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = source.name?.trim().isNotEmpty == true ? source.name! : _truncateUrl(source.url);
    final typeLabel = source.type == 'xtream' ? 'Xtream' : 'M3U';
    final statusLabel = _statusLabel(source.syncStatus);
    final statusColor = _statusColor(context, source.syncStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'remove') _showRemoveDialog(context, ref, source);
                    if (value == 'retry') ref.read(playlistNotifierProvider.notifier).retrySync(source.id);
                  },
                  itemBuilder: (context) => [
                    if (source.syncStatus == 'error')
                      const PopupMenuItem(value: 'retry', child: Text('Retry')),
                    const PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              typeLabel,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref, Source source) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove playlist?'),
        content: const Text(
          'This will remove this source and all its channels. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(playlistNotifierProvider.notifier).removeSource(source.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
