import 'package:flutter_test/flutter_test.dart';
import 'package:agri_assist/features/profile/models/user_profile_model.dart';
import 'package:agri_assist/features/profile/models/user_profile_update_model.dart';
import 'package:agri_assist/features/profile/repos/profile_repo.dart';
import 'package:agri_assist/features/profile/controllers/profile_controller.dart';

void main() {
  group('Profile feature tests', () {
    test('UserProfileModel serialization and deserialization', () {
      final json = {
        'id': 42,
        'username': 'johndoe',
        'email': 'john@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'is_staff': false,
        'date_joined': '2026-01-01T00:00:00Z',
        'profile': {
          'phone_number': '+977 9800000000',
          'city': 'Kathmandu',
          'created_at': '2026-01-01T00:00:00Z',
        },
      };

      final profile = UserProfileModel.fromJson(json);

      expect(profile.id, 42);
      expect(profile.username, 'johndoe');
      expect(profile.email, 'john@example.com');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.fullName, 'John Doe');
      expect(profile.profile?.city, 'Kathmandu');
      expect(profile.profile?.phoneNumber, '+977 9800000000');

      expect(profile.toJson(), json);
    });

    test('UserProfileUpdateModel serialization', () {
      final updateModel = UserProfileUpdateModel(
        firstName: 'Aarav',
        lastName: 'Sharma',
        email: 'aarav.sharma@example.com',
        phoneNumber: '+977 9812345678',
        city: 'Chitwan',
      );

      final json = updateModel.toJson();
      expect(json['first_name'], 'Aarav');
      expect(json['last_name'], 'Sharma');
      expect(json['email'], 'aarav.sharma@example.com');
      expect(json['phone_number'], '+977 9812345678');
      expect(json['city'], 'Chitwan');
    });

    test('MockProfileRepo returns valid UserProfileModel and updates profile', () async {
      final repo = MockProfileRepo();
      final profile = await repo.getUserProfile();

      expect(profile.username, 'ramesh_kumar');
      expect(profile.email, 'ramesh.kumar@email.com');

      final updateReq = UserProfileUpdateModel(
        firstName: 'Ram',
        city: 'Lalitpur',
      );

      final updatedProfile = await repo.updateProfile(updateReq);
      expect(updatedProfile.firstName, 'Ram');
      expect(updatedProfile.profile?.city, 'Lalitpur');
    });

    test('ProfileController fetchUserProfile and updateProfile workflow', () async {
      final controller = ProfileController(profileRepo: MockProfileRepo());
      expect(controller.userProfile, null);

      await controller.fetchUserProfile();
      expect(controller.userProfile?.fullName, 'Ramesh Kumar');

      final updateReq = UserProfileUpdateModel(
        firstName: 'Hari',
        city: 'Kathmandu',
      );

      final success = await controller.updateProfile(updateReq);
      expect(success, true);
      expect(controller.userProfile?.firstName, 'Hari');
      expect(controller.userProfile?.profile?.city, 'Kathmandu');
    });
  });
}
