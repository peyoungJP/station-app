import 'package:flutter/foundation.dart';

import '../models/report.dart';
import 'supabase_service.dart';

class ReportService {
  Future<void> createReport({
    required String contentType,
    required String contentId,
    required String reason,
    String? details,
  }) async {
    if (SupabaseService.useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('Report created (mock): $contentType/$contentId - $reason');
      return;
    }

    final report = Report(
      id: '',
      contentType: contentType,
      contentId: contentId,
      reason: reason,
      details: details,
    );

    await SupabaseService.client.from('reports').insert(report.toJson());
  }
}
