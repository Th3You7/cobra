import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/home_grid_item.dart';

/// Ordered list of home grid tiles: Live, Movies, Series, Catch Up, Playlist, Settings.
const List<HomeGridItem> homeGridItems = [
  HomeGridItem(
    label: 'Live',
    icon: Icons.live_tv,
    route: AppConstants.homeLiveRoute,
  ),
  HomeGridItem(
    label: 'Movies',
    icon: Icons.movie,
    route: AppConstants.homeMoviesRoute,
  ),
  HomeGridItem(
    label: 'Series',
    icon: Icons.tv,
    route: AppConstants.homeSeriesRoute,
  ),
  HomeGridItem(
    label: 'Catch Up',
    icon: Icons.history,
    route: AppConstants.homeCatchupRoute,
  ),
  HomeGridItem(
    label: 'Playlist',
    icon: Icons.playlist_add,
    route: AppConstants.homePlaylistRoute,
  ),
  HomeGridItem(
    label: 'Settings',
    icon: Icons.settings,
    route: AppConstants.homeSettingsRoute,
  ),
];
