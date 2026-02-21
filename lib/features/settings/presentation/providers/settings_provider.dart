import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Settings State ──
class SettingsState {
  final bool orderNotifications;
  final bool promotionNotifications;
  final bool newArrivalNotifications;
  final bool analyticsEnabled;

  const SettingsState({
    this.orderNotifications = true,
    this.promotionNotifications = true,
    this.newArrivalNotifications = false,
    this.analyticsEnabled = true,
  });

  SettingsState copyWith({
    bool? orderNotifications,
    bool? promotionNotifications,
    bool? newArrivalNotifications,
    bool? analyticsEnabled,
  }) {
    return SettingsState(
      orderNotifications: orderNotifications ?? this.orderNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      newArrivalNotifications: newArrivalNotifications ?? this.newArrivalNotifications,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}

// ── Settings Notifier ──
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleOrderNotifications(bool value) {
    state = state.copyWith(orderNotifications: value);
  }

  void togglePromotionNotifications(bool value) {
    state = state.copyWith(promotionNotifications: value);
  }

  void toggleNewArrivalNotifications(bool value) {
    state = state.copyWith(newArrivalNotifications: value);
  }

  void toggleAnalytics(bool value) {
    state = state.copyWith(analyticsEnabled: value);
  }
}

// ── Provider ──
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
