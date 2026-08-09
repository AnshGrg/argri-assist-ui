import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../models/user_profile_update_model.dart';
import '../repos/profile_repo.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepo _profileRepo;

  ProfileController({required ProfileRepo profileRepo}) : _profileRepo = profileRepo;

  UserProfileModel? _userProfile;
  UserProfileModel? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile({String? accessToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _profileRepo.getUserProfile(accessToken: accessToken);
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserProfileUpdateModel request, {String? accessToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _profileRepo.updateProfile(request, accessToken: accessToken);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
