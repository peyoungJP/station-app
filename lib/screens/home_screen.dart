import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens.dart';
import '../providers/location_provider.dart';
import '../providers/nearby_location_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/location_card.dart';
import 'board_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
    });
  }

  Future<void> _fetchLocation() async {
    await ref.read(locationProvider.notifier).fetchLocation();
    await ref.read(nearbyLocationsProvider.notifier).fetchNearbyLocations();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final locationsState = ref.watch(nearbyLocationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('駅掲示板'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLocation,
        child: locationState.when(
          data: (position) {
            if (position == null) {
              return _buildPermissionRequest(theme);
            }

            return locationsState.when(
              data: (locations) {
                if (locations.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: AppSpacing.xs,
                    bottom: AppSpacing.sm,
                  ),
                  itemCount: locations.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.xs,
                          AppSpacing.sm,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          '近くの掲示板',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final location = locations[index - 1];
                    return LocationCard(
                      location: location,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BoardScreen(location: location),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => ListView(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: ErrorView(
                      error: error,
                      onRetry: () => ref
                          .read(nearbyLocationsProvider.notifier)
                          .fetchNearbyLocations(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: AppSpacing.sm),
                const Text('位置情報を取得中...'),
              ],
            ),
          ),
          error: (error, _) {
            if (error is LocationPermissionDeniedException) {
              return _buildPermissionDenied(theme);
            }
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: ErrorView(error: error, onRetry: _fetchLocation),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermissionRequest(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '位置情報を許可してください',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '近くの掲示板を見つけるために位置情報が必要です。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _fetchLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('位置情報を取得'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_disabled,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '位置情報が許可されていません',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '設定アプリから位置情報の使用を許可してください。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _fetchLocation,
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          Icons.forum_outlined,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '近くに掲示板が見つかりません',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '別の場所で再度お試しください。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}

