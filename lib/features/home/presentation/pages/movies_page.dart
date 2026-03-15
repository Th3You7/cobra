import 'package:flutter/material.dart';

/// Movies section - placeholder.
class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: const Center(
        child: Text('Coming soon'),
      ),
    );
  }
}
