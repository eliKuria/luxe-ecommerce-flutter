import 'dart:io';
import 'package:luxe/core/network/supa_service.dart';
import 'package:luxe/features/profile/domain/order.dart';
import 'package:luxe/features/profile/domain/profile_repository.dart';
import 'package:luxe/features/profile/domain/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client = SupaService.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in to view your profile.');
    }
    return user.id;
  }

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', _userId)
          .maybeSingle();

      if (response == null) {
        final user = _client.auth.currentUser!;
        final email = user.email ?? '';
        final fullName = user.userMetadata?['full_name'] as String?;
        final avatarUrl = user.userMetadata?['avatar_url'] as String?;

        final newProfile = {
          'id': _userId,
          'email': email,
          'full_name': fullName,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await _client.from('profiles').insert(newProfile);
        
        return UserProfile(
          id: _userId,
          email: email,
          fullName: fullName,
          avatarUrl: avatarUrl,
          createdAt: DateTime.now(),
        );
      }
      
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('We couldn\'t load your profile. Please check your connection and try again.');
    }
  }

  @override
  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('profiles').update(updates).eq('id', _userId);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '$_userId/avatar.$fileExt';
    
    await _client.storage.from('avatars').uploadBinary(
      fileName,
      await file.readAsBytes(),
      fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
    );

    final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
    
    await updateProfile(avatarUrl: imageUrl);

    return imageUrl;
  }

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('We couldn\'t load your orders. Please check your connection and try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
