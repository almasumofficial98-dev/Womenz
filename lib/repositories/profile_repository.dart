import '../models/user_profile.dart';

class ProfileRepository {
  UserProfile _profile = UserProfile();

  Future<UserProfile> getProfile() async {
    return _profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
  }

  Future<void> resetProfile() async {
    _profile = UserProfile();
  }
}
