import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection/service_locator.dart';

/// Add Playlist screen: tabs for M3U URL or Xtream Codes API, form and submit.
class AddPlaylistPage extends ConsumerStatefulWidget {
  const AddPlaylistPage({super.key});

  @override
  ConsumerState<AddPlaylistPage> createState() => _AddPlaylistPageState();
}

class _AddPlaylistPageState extends ConsumerState<AddPlaylistPage> {
  static const int _tabM3u = 0;
  static const int _tabXtream = 1;

  int _selectedTab = _tabM3u;

  final _m3uUrlController = TextEditingController();
  final _m3uNameController = TextEditingController();

  final _xtreamUrlController = TextEditingController();
  final _xtreamNameController = TextEditingController();
  final _xtreamUsernameController = TextEditingController();
  final _xtreamPasswordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _m3uUrlController.dispose();
    _m3uNameController.dispose();
    _xtreamUrlController.dispose();
    _xtreamNameController.dispose();
    _xtreamUsernameController.dispose();
    _xtreamPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(playlistNotifierProvider.notifier);
      if (_selectedTab == _tabM3u) {
        final url = _m3uUrlController.text.trim();
        if (url.isEmpty) {
          setState(() {
            _errorMessage = 'Enter M3U URL';
            _isSubmitting = false;
          });
          return;
        }
        if (!Validators.isValidUrl(url)) {
          setState(() {
            _errorMessage = 'Enter a valid URL (e.g. https://example.com/playlist.m3u)';
            _isSubmitting = false;
          });
          return;
        }
        await notifier.addM3uSource(
          url: url,
          name: _m3uNameController.text.trim().isEmpty ? null : _m3uNameController.text.trim(),
        );
      } else {
        final serverUrl = _xtreamUrlController.text.trim();
        final username = _xtreamUsernameController.text.trim();
        final password = _xtreamPasswordController.text;
        if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
          setState(() {
            _errorMessage = 'Fill URL + Port, Username and Password';
            _isSubmitting = false;
          });
          return;
        }
        if (!Validators.isValidUrl(serverUrl)) {
          setState(() {
            _errorMessage = 'Enter a valid server URL (e.g. http://server:8080)';
            _isSubmitting = false;
          });
          return;
        }
        await notifier.addXtreamSource(
          serverUrl: serverUrl,
          username: username,
          password: password,
          name: _xtreamNameController.text.trim().isEmpty ? null : _xtreamNameController.text.trim(),
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSubmitting = false;
        });
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.2);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('ADD PLAYLIST'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tabs: ADD M3U URL | XTREAM-CODES-API
            Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'ADD M3U URL',
                    isSelected: _selectedTab == _tabM3u,
                    onTap: () => setState(() => _selectedTab = _tabM3u),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabChip(
                    label: 'XTREAM-CODES-API',
                    isSelected: _selectedTab == _tabXtream,
                    onTap: () => setState(() => _selectedTab = _tabXtream),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form card
            Container(
              padding: const EdgeInsets.all(ThemeConfig.paddingMedium),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
                border: Border.all(color: borderColor),
              ),
              child: _selectedTab == _tabM3u ? _buildM3uForm(theme) : _buildXtreamForm(theme),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),

            // ADD PLAYLIST button
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ADD PLAYLIST'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3uForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormLabel(label: 'Playlist Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _m3uNameController,
          decoration: _inputDecoration(theme, 'name'),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _FormLabel(label: 'M3U URL'),
        const SizedBox(height: 6),
        TextField(
          controller: _m3uUrlController,
          decoration: _inputDecoration(theme, 'https://example.com/playlist.m3u'),
          style: theme.textTheme.bodyLarge,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildXtreamForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormLabel(label: 'Playlist Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _xtreamNameController,
          decoration: _inputDecoration(theme, 'name'),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _FormLabel(label: 'URL + Port'),
        const SizedBox(height: 6),
        TextField(
          controller: _xtreamUrlController,
          decoration: _inputDecoration(theme, 'http://server_domain:8080'),
          style: theme.textTheme.bodyLarge,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _FormLabel(label: 'Username'),
        const SizedBox(height: 6),
        TextField(
          controller: _xtreamUsernameController,
          decoration: _inputDecoration(theme, 'Username'),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _FormLabel(label: 'Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _xtreamPasswordController,
          decoration: _inputDecoration(theme, 'Password'),
          style: theme.textTheme.bodyLarge,
          obscureText: true,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      filled: true,
      fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;

  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
