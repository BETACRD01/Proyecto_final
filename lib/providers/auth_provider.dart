import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await AuthService.getCurrentUserData();
      _setError(null);
    } catch (e) {
      _setError('Error al verificar autenticación');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      _currentUser = await AuthService.signInUser(
        email: email,
        password: password,
      );
      
      if (_currentUser != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al iniciar sesión');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required UserType userType,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      _currentUser = await AuthService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
        city: city,
        userType: userType,
      );
      
      if (_currentUser != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear la cuenta');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al registrar usuario');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService.signOut();
      _currentUser = null;
      _setError(null);
    } catch (e) {
      _setError('Error al cerrar sesión');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _setError(null);
    
    try {
      bool success = await AuthService.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar perfil');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar perfil');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      bool success = await AuthService.resetPassword(email);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al enviar email de recuperación');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al restablecer contraseña');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
