import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/core/network/supa_service.dart';

final splashControllerProvider = Provider((ref) => SplashController());

class SplashController {
  Future<String> initApp() async {
    // Minimum delay for animation (2 seconds as requested)
    final minDelay = Future.delayed(const Duration(seconds: 2));

    // Check for session
    // SupaService.client is synchronous but we want to simulate "checking" or async work if needed
    // In this case, just getting the property is instant, but the delay governs the UI.
    final session = SupaService.client.auth.currentSession;

    await minDelay;

    if (session != null) {
      return '/catalog'; // Renaming Shop to Catalog as requested
    } else {
      return '/login';
    }
  }
}
