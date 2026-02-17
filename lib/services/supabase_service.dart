import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;
  static bool _useMock = true;

  static bool get useMock => _useMock;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(url: url, anonKey: anonKey);
    _useMock = false;
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
