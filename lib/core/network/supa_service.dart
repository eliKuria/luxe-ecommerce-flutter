import 'package:luxe/core/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Secrets.supabaseUrl,
      anonKey: Secrets.supabaseAnonKey,
    );
  }
}
