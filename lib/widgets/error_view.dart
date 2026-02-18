import 'package:flutter/material.dart';

import '../design_system/tokens.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.error, this.onRetry});

  String _resolveMessage() {
    final msg = error.toString().toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('networkerror') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection refused') ||
        msg.contains('timeoutexception')) {
      return '通信エラーが発生しました。通信環境を確認してください。';
    }
    return 'サーバーエラーが発生しました。しばらくしてからお試しください。';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'エラーが発生しました',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _resolveMessage(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('再試行'),
            ),
          ],
        ],
      ),
    );
  }
}
