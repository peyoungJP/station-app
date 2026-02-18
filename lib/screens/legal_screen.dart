import 'package:flutter/material.dart';

import '../design_system/tokens.dart';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory LegalScreen.termsOfService() {
    return const LegalScreen(
      title: '利用規約',
      lastUpdated: '2026年3月1日',
      sections: [
        LegalSection(
          heading: '第1条（はじめに）',
          body:
              'ここ板（以下「本サービス」）は、現在地周辺の場所に紐づいた匿名掲示板サービスです。'
              '本規約に同意いただいた上でご利用ください。本サービスを利用した場合、本規約に同意したものとみなします。',
        ),
        LegalSection(
          heading: '第2条（禁止事項）',
          body: '以下の行為を禁止します。\n\n'
              '・他者への誹謗中傷、差別的発言\n'
              '・個人情報（氏名・住所・電話番号等）の掲載\n'
              '・スパム・広告・商用目的の投稿\n'
              '・違法または有害なコンテンツの投稿\n'
              '・本サービスの運営を妨げる行為\n'
              '・その他、公序良俗に反する行為',
        ),
        LegalSection(
          heading: '第3条（投稿内容の管理）',
          body: '運営者は、以下の場合に予告なく投稿を削除することができます。\n\n'
              '・本規約の禁止事項に該当する投稿\n'
              '・他のユーザーから通報を受けた投稿\n'
              '・その他、運営者が不適切と判断した投稿\n\n'
              '削除に関する異議申し立てはお受けできません。',
        ),
        LegalSection(
          heading: '第4条（免責事項）',
          body: '運営者は、ユーザーが投稿したコンテンツの正確性・完全性・適法性について保証しません。'
              '本サービスの利用により生じたいかなる損害についても、運営者は責任を負いません。',
        ),
        LegalSection(
          heading: '第5条（利用規約の変更）',
          body: '運営者は、必要に応じて本規約を変更することがあります。'
              '変更後の規約は本アプリ内に表示した時点で効力を生じます。',
        ),
      ],
    );
  }

  factory LegalScreen.privacyPolicy() {
    return const LegalScreen(
      title: 'プライバシーポリシー',
      lastUpdated: '2026年3月1日',
      sections: [
        LegalSection(
          heading: '取得する情報',
          body: '本サービスは以下の情報を取得します。\n\n'
              '【位置情報】\n'
              'ネイティブアプリ（iOS/Android）では、近隣の駅を検索するために現在地の位置情報を取得します。'
              'Web版ではQRコードで直接ページにアクセスするため、位置情報は取得しません。\n\n'
              '【アクセスログ】\n'
              'サービス改善のため、Firebase Analytics によりページビューや利用状況を収集します。'
              '個人を特定する情報は含まれません。',
        ),
        LegalSection(
          heading: '情報の利用目的',
          body: '取得した情報は以下の目的に利用します。\n\n'
              '・近隣の駅・イベント会場の掲示板を表示するため\n'
              '・サービスの利用状況を分析し、改善するため',
        ),
        LegalSection(
          heading: '第三者への提供',
          body: '取得した情報は、以下の場合を除き第三者に提供しません。\n\n'
              '・法令に基づく開示要求があった場合\n'
              '・Firebase Analytics（Google LLC）へのアクセスログ送信\n\n'
              'Firebase Analytics のプライバシーポリシーについては Google LLC の定めによります。',
        ),
        LegalSection(
          heading: 'お問い合わせ',
          body: '本ポリシーに関するお問い合わせは、アプリ内の通報機能またはストアのレビュー欄よりご連絡ください。',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        children: [
          Text(
            '最終更新日：$lastUpdated',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sections.map((section) => _LegalSectionWidget(section: section)),
        ],
      ),
    );
  }
}

class _LegalSectionWidget extends StatelessWidget {
  final LegalSection section;

  const _LegalSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            section.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
