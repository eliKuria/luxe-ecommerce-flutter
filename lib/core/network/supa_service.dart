import 'package:supabase_flutter/supabase_flutter.dart';

class SupaService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
