import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/features/profile/data/profile_repository_impl.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/profile_repository.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';
import 'package:luxe/features/profile/domain/user_role.dart';

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

// Single order detail provider
final orderDetailProvider = FutureProvider.family<Order, int>((ref, id) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getOrderById(id);
});

// User role provider
final userRoleProvider = Provider<UserRole>((ref) {
  final profile = ref.watch(profileControllerProvider).valueOrNull;
  return profile?.role ?? UserRole.customer;
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

  Future<void> updateRole(UserRole role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateRole(role);
      return _repository.getProfile();
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}
