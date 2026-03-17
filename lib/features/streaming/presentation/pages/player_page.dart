import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';

/// Full-screen player for a single stream (from detail Watch button).
/// Route extra: Map with 'url' (String) and 'title' (String).
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, this.url, this.title});

  final String? url;
  final String? title;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _setupPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  dynamic _controller;

  void _setupPlayer() {
    final url = widget.url?.trim();
    if (url == null || url.isEmpty) return;
    try {
      final dataSource = BetterPlayerDataSource.network(
        url,
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
  Widget build(BuildContext context) {
    final title = widget.title ?? 'Playback';

    return Material(
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white54),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                ],
              ),
            )
          else
            Stack(
              fit: StackFit.expand,
              children: [
                BetterPlayer(controller: _controller!),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
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
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      ),
    );
  }
}
