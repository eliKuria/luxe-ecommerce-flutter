import 'dart:io';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';
import 'package:luxe/features/profile/domain/user_role.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile({String? fullName});
  Future<String> uploadAvatar(File file);
  Future<List<Order>> getOrders();
  Future<Order> getOrderById(int id);
  Future<void> updateRole(UserRole role);
  Future<void> verifyAccount();
  Future<void> signOut();
}
