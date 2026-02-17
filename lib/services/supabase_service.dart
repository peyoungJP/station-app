import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _initialized = false;
  static bool _useMock = true;

  static bool get useMock => _useMock;

  static bool get hasConfig => _url.isNotEmpty && _anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (_initialized) return;
    if (!hasConfig) return;

    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _useMock = false;
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
