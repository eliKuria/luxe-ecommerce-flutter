import 'dart:io';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile({String? fullName});
  Future<String> uploadAvatar(File file);
  Future<List<Order>> getOrders();
  Future<void> signOut();
}
