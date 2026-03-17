import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/channel.dart';
import '../widgets/streaming_theme.dart';

/// Informational page for a movie or series: poster, Watch button, favorite, title, metadata.
/// Pass [Channel] via route extra. Watch button opens full-screen player.
class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key, this.channel});

  /// Passed via GoRouter state.extra.
  final Channel? channel;

  @override
  Widget build(BuildContext context) {
    if (channel == null) {
      return Scaffold(
        backgroundColor: streamingDarkPurple,
        appBar: AppBar(
          backgroundColor: streamingDarkPurple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Content not found', style: TextStyle(color: Colors.white70))),
      );
    }

    final theme = Theme.of(context);
    final isSeries = channel!.type == 'series';

    return Scaffold(
      backgroundColor: streamingDarkPurple,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: channel!.streamIcon != null && channel!.streamIcon!.isNotEmpty
                          ? Image.network(
                              channel!.streamIcon!,
                              width: 280,
                              height: 420,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _posterPlaceholder(theme),
                            )
                          : _posterPlaceholder(theme),
                    ),
                    const SizedBox(width: 32),
                    // Info + Watch
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => context.push(
                                  AppConstants.playerRoute,
                                  extra: {'url': channel!.streamUrl, 'title': channel!.name},
                                ),
                                icon: const Icon(Icons.play_arrow, size: 28),
                                label: Text(isSeries ? 'Watch Season' : 'Watch'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: streamingTabHighlight,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filled(
                                onPressed: () {},
                                icon: const Icon(Icons.star_border),
                                style: IconButton.styleFrom(
                                  backgroundColor: streamingLightPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            channel!.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (channel!.groupTitle != null && channel!.groupTitle!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              channel!.groupTitle!,
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _metadataRow(theme, 'Year / Genre', '—'),
                          const SizedBox(height: 8),
                          _metadataRow(theme, 'Cast', '—'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(3, (_) => const Icon(Icons.star, color: streamingTabHighlight, size: 20)),
                              const Icon(Icons.star_border, color: Colors.white54, size: 20),
                              const Icon(Icons.star_border, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              Text('3.0', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _metadataRow(theme, 'Date Added', '—'),
                          const SizedBox(height: 16),
                          Text(
                            'Plot',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            channel!.groupTitle ?? 'No plot available.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.4),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder(ThemeData theme) {
    return Container(
      width: 280,
      height: 420,
      color: streamingLightPurple,
      child: Icon(Icons.movie, size: 80, color: theme.colorScheme.primary),
    );
  }

  Widget _metadataRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54)),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70))),
      ],
    );
  }
}
