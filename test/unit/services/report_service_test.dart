import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/report_service.dart';

void main() {
  group('ReportService（モックモード）', () {
    late ReportService service;

    setUp(() {
      service = ReportService();
    });

    test('createReportが例外なく完了する', () async {
      await expectLater(
        service.createReport(
          contentType: 'thread',
          contentId: 'thread-1',
          reason: 'スパム・宣伝',
        ),
        completes,
      );
    });

    test('contentTypeがpostでも例外なく完了する', () async {
      await expectLater(
        service.createReport(
          contentType: 'post',
          contentId: 'post-1',
          reason: '不適切な内容',
        ),
        completes,
      );
    });

    test('detailsを指定しても例外なく完了する', () async {
      await expectLater(
        service.createReport(
          contentType: 'thread',
          contentId: 'thread-1',
          reason: 'その他',
          details: '詳細な理由をここに記載',
        ),
        completes,
      );
    });

    test('全ての通報理由で例外なく完了する', () async {
      final reasons = [
        'スパム・宣伝',
        '不適切な内容',
        '誹謗中傷',
        '個人情報の掲載',
        'その他',
      ];

      for (final reason in reasons) {
        await expectLater(
          service.createReport(
            contentType: 'thread',
            contentId: 'thread-1',
            reason: reason,
          ),
          completes,
        );
      }
    });
  });
}
