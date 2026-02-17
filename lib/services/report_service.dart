import 'package:flutter/foundation.dart';

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

    final data = {
      'content_type': contentType,
      'content_id': contentId,
      'reason': reason,
      if (details != null) 'details': details,
    };

    await SupabaseService.client.from('reports').insert(data);
  }
}
