import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../design_system/tokens.dart';
import '../models/thread.dart';
import '../providers/thread_provider.dart';
import '../services/report_service.dart';
import '../widgets/post_item.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  final Thread thread;

  const ThreadDetailScreen({super.key, required this.thread});

  @override
  ConsumerState<ThreadDetailScreen> createState() =>
      _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    setState(() => _isSending = true);

    await ref
        .read(postsProvider(widget.thread.id).notifier)
        .addPost(body: body);

    _replyController.clear();
    setState(() => _isSending = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showReportDialog(String contentType, String contentId) {
    final reasons = [
      'スパム・宣伝',
      '不適切な内容',
      '誹謗中傷',
      '個人情報の掲載',
      'その他',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('通報理由を選択'),
          children: reasons
              .map(
                (reason) => SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context);
                    final messenger = ScaffoldMessenger.of(this.context);
                    await ReportService().createReport(
                      contentType: contentType,
                      contentId: contentId,
                      reason: reason,
                    );
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('通報を受け付けました')),
                      );
                    }
                  },
                  child: Text(reason),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider(widget.thread.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.thread.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'スレッドを通報',
            onPressed: () =>
                _showReportDialog('thread', widget.thread.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.thread.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.thread.body,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm')
                      .format(widget.thread.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: postsState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return Center(
                    child: Text(
                      'まだ返信がありません',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostItem(
                      post: posts[index],
                      index: index,
                      onReport: () =>
                          _showReportDialog('post', posts[index].id),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('エラー: $error')),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: '返信を入力...',
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 4,
                        vertical: AppSpacing.xs,
                      ),
                      isDense: true,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 1000,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendReply(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendReply,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
