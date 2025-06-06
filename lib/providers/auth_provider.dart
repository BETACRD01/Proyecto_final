import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage; // ✅ Agregado para mensajes de éxito
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage =>
      _successMessage; // ✅ Getter para mensaje de éxito
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // ✅ Constructor sin inicialización automática
  AuthProvider() {
    _initializeWhenFirebaseReady();
  }

  // ✅ Esperar a que Firebase esté listo antes de verificar auth
  Future<void> _initializeWhenFirebaseReady() async {
    try {
      // Asegurar que Firebase esté inicializado
      await Firebase.initializeApp();

      // Pequeña pausa para asegurar que todo esté listo
      await Future.delayed(const Duration(milliseconds: 100));

      // Ahora verificar el estado de autenticación
      await checkAuthStatus();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint("Error al inicializar AuthProvider: $e");
      }
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null; // ✅ Limpiar mensaje de éxito si hay error
    notifyListeners();
  }

  void _setSuccess(String? success) {
    _successMessage = success;
    _errorMessage = null; // ✅ Limpiar mensaje de error si hay éxito
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    // Solo verificar si Firebase está inicializado
    if (!_isInitialized) {
      if (kDebugMode) {
        debugPrint("Firebase aún no está listo, esperando...");
      }
      return;
    }

    _setLoading(true);
    try {
      _currentUser = await AuthService.getCurrentUserData();
      _setError(null);

      if (kDebugMode) {
        debugPrint(
            "Estado de auth verificado: ${_currentUser?.email ?? 'No autenticado'}");
      }
    } catch (e) {
      _setError('Error al verificar autenticación');
      if (kDebugMode) {
        debugPrint("Error en checkAuthStatus: $e");
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    try {
      _currentUser = await AuthService.signInUser(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        _setSuccess('¡Bienvenido de vuelta, ${_currentUser!.name}!');
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Manejo específico de errores de Firebase Auth
      String errorMessage = 'Error al iniciar sesión';

      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Usuario no encontrado. Verifica tu email.';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Contraseña incorrecta.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'El formato del email no es válido.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'Esta cuenta ha sido deshabilitada.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Demasiados intentos. Intenta más tarde.';
      }

      _setError(errorMessage);
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
    _setSuccess(null);

    try {
      if (kDebugMode) {
        debugPrint("🔄 Iniciando registro para: $email");
      }

      // ✅ Registrar usuario SIN establecer sesión automática
      UserModel? registeredUser = await AuthService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
        city: city,
        userType: userType,
      );

      if (registeredUser != null) {
        // ✅ NO establecer _currentUser (sin login automático)
        // _currentUser = registeredUser; // <-- Esta línea comentada

        // ✅ Mensaje de éxito personalizado
        _setSuccess(
            '¡Cuenta creada exitosamente! Ya puedes iniciar sesión con tu email 📧');

        if (kDebugMode) {
          debugPrint(
              "✅ Usuario registrado exitosamente: ${registeredUser.email}");
        }

        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear la cuenta');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Manejo específico de errores de Firebase Auth
      String errorMessage = 'Error al registrar usuario';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage =
            'Este email ya está registrado. Usa otro email o inicia sesión.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'El formato del email no es válido.';
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = 'El registro con email/contraseña no está habilitado.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage =
            'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
      }

      _setError(errorMessage);
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
      _setSuccess('Sesión cerrada correctamente');
    } catch (e) {
      _setError('Error al cerrar sesión: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    try {
      bool success = await AuthService.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        _setSuccess('Perfil actualizado correctamente');
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar perfil');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar perfil: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    try {
      bool success = await AuthService.resetPassword(email);
      if (success) {
        _setSuccess('Email de recuperación enviado a $email');
        _setLoading(false);
        return true;
      } else {
        _setError('Error al enviar email de recuperación');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al restablecer contraseña: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }

  void clearSuccess() {
    _setSuccess(null);
  }

  void clearMessages() {
    _setError(null);
    _setSuccess(null);
  }

  // ✅ Método público para reinicializar si es necesario
  Future<void> reinitialize() async {
    _isInitialized = false;
    await _initializeWhenFirebaseReady();
  }
}
