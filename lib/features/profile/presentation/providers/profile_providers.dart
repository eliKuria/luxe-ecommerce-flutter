import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/profile/data/profile_repository_impl.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/profile_repository.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';

// Repository provider
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepositoryImpl());

// Profile data provider
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile>(
        ProfileController.new);

// Orders provider
final ordersProvider = FutureProvider<List<Order>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getOrders();
});

class ProfileController extends AsyncNotifier<UserProfile> {
  late final ProfileRepository _repository;

  @override
  Future<UserProfile> build() async {
    _repository = ref.watch(profileRepositoryProvider);
    return _repository.getProfile();
  }

  Future<void> updateName(String fullName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateProfile(fullName: fullName);
      return _repository.getProfile();
    });
  }

  Future<void> uploadAvatar(File file) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.uploadAvatar(file);
      return _repository.getProfile();
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}
