import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens.dart';
import '../models/station.dart';
import '../providers/thread_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/thread_card.dart';
import 'create_thread_screen.dart';
import 'thread_detail_screen.dart';

class BoardScreen extends ConsumerWidget {
  final Station station;

  const BoardScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsState = ref.watch(threadsProvider(station.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${station.name}駅'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(threadsProvider(station.id).notifier).refresh();
        },
        child: threadsState.when(
          data: (threads) {
            if (threads.isEmpty) {
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
                    'まだスレッドがありません',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '最初のスレッドを作成してみましょう！',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(
                top: AppSpacing.xs,
                bottom: AppSpacing.xs * 10,
              ),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ThreadCard(
                  thread: thread,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ThreadDetailScreen(thread: thread),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Center(
                child: ErrorView(
                  error: error,
                  onRetry: () =>
                      ref.read(threadsProvider(station.id).notifier).refresh(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateThreadScreen(stationId: station.id),
            ),
          );
          if (created == true) {
            ref.read(threadsProvider(station.id).notifier).refresh();
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('スレッド作成'),
      ),
    );
  }
}
