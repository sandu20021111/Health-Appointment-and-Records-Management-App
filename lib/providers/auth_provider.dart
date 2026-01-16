import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUserModel;
  bool _isLoading = false;

  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authService.currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _fetchUserDetails(user.uid);
      } else {
        _currentUserModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    _isLoading = true;
    notifyListeners();
    _currentUserModel = await _authService.getUserDetails(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    String? error = await _authService.signIn(email: email, password: password);
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> register({
    required String email,
    required String password,
    required UserModel userModel,
  }) async {
    _isLoading = true;
    notifyListeners();
    String? error = await _authService.signUp(
      email: email,
      password: password,
      userModel: userModel,
    );
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUserModel = null;
    notifyListeners();
  }
}
