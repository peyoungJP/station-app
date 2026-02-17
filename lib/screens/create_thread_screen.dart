import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens.dart';
import '../providers/thread_provider.dart';

class CreateThreadScreen extends ConsumerStatefulWidget {
  final String stationId;

  const CreateThreadScreen({super.key, required this.stationId});

  @override
  ConsumerState<CreateThreadScreen> createState() =>
      _CreateThreadScreenState();
}

class _CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSubmitting = false;

  static const int _maxTitleLength = 50;
  static const int _maxBodyLength = 1000;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await ref.read(threadsProvider(widget.stationId).notifier).createThread(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('スレッド作成'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('投稿'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'タイトル',
                hintText: 'スレッドのタイトルを入力',
                border: const OutlineInputBorder(),
                counterText:
                    '${_titleController.text.length}/$_maxTitleLength',
              ),
              maxLength: _maxTitleLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: '本文',
                hintText: 'スレッドの内容を入力',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                counterText:
                    '${_bodyController.text.length}/$_maxBodyLength',
              ),
              maxLines: 8,
              minLines: 4,
              maxLength: _maxBodyLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '本文を入力してください';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '投稿は匿名で行われます。個人情報の記載はお控えください。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
