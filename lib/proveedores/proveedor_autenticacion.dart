import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/modelo_usuario.dart';
import '../nucleo/servicios/servicio_autenticacion.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Constructor mejorado
  AuthProvider() {
    _initializeAuth();
  }

  // ✅ Inicialización mejorada con listener de Firebase Auth
  Future<void> _initializeAuth() async {
    try {
      print('🔄 Iniciando AuthProvider...');

      // Esperar a que Firebase esté listo
      await Firebase.initializeApp();
      await Future.delayed(const Duration(milliseconds: 200));

      // ✅ CLAVE: Escuchar cambios de autenticación de Firebase
      FirebaseAuth.instance
          .authStateChanges()
          .listen((User? firebaseUser) async {
        print('🔥 Firebase Auth cambió: ${firebaseUser?.email ?? "null"}');

        if (firebaseUser != null) {
          // Usuario autenticado, cargar sus datos
          await _loadUserData(firebaseUser.uid);
        } else {
          // Usuario no autenticado
          _currentUser = null;
          _setLoading(false);
        }
      });

      // Verificar estado inicial
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        print('👤 Usuario ya autenticado: ${currentFirebaseUser.email}');
        await _loadUserData(currentFirebaseUser.uid);
      } else {
        print('❌ No hay usuario autenticado');
        _setLoading(false);
      }

      _isInitialized = true;
      print('✅ AuthProvider inicializado');
      notifyListeners();
    } catch (e) {
      print('❌ Error inicializando AuthProvider: $e');
      _isInitialized = true;
      _setLoading(false);
      _setError('Error al inicializar autenticación');
    }
  }

  // ✅ Cargar datos del usuario desde Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      _setLoading(true);
      print('📄 Cargando datos del usuario: $userId');

      final userData = await AuthService.getCurrentUserData();
      if (userData != null) {
        _currentUser = userData;
        print('✅ Datos cargados para: ${userData.name}');
        _clearError();
      } else {
        print('❌ No se encontraron datos del usuario en Firestore');
        _setError('No se encontraron datos del usuario');
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      _setError('Error al cargar datos del usuario');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ✅ Método público mejorado para verificar auth
  Future<void> checkAuthStatus() async {
    if (!_isInitialized) {
      print('⏳ AuthProvider no inicializado, esperando...');
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && _currentUser == null) {
      print('🔄 Recargando datos del usuario...');
      await _loadUserData(firebaseUser.uid);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    _successMessage = null;

    try {
      print('🔐 Intentando login: $email');

      // El AuthService maneja Firebase Auth y retorna UserModel
      _currentUser = await AuthService.signInUser(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        print('✅ Login exitoso: ${_currentUser!.name}');
        _setSuccess('¡Bienvenido de vuelta, ${_currentUser!.name}!');
        _setLoading(false);
        return true;
      } else {
        print('❌ Login fallido: credenciales incorrectas');
        _setError('Credenciales incorrectas');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      String errorMessage = _getAuthErrorMessage(e.toString());
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
    _clearError();
    _successMessage = null;

    try {
      print('📝 Registrando usuario: $email');

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
        print('✅ Registro exitoso: ${registeredUser.email}');

        // ✅ NO auto-login, solo mensaje de éxito
        _setSuccess(
            '¡Cuenta creada exitosamente! Ya puedes iniciar sesión con tu email 📧');
        _setLoading(false);
        return true;
      } else {
        print('❌ Registro fallido');
        _setError('Error al crear la cuenta');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      String errorMessage = _getAuthErrorMessage(e.toString());
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  // 🔹 NUEVO MÉTODO PARA REGISTRO CON DATOS EXTRA
  Future<bool> signUpWithExtraData(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();
    _successMessage = null;

    try {
      print('📝 Registrando usuario con datos completos: ${userData['email']}');

      UserModel? registeredUser =
          await AuthService.registerUserWithExtraData(userData);

      if (registeredUser != null) {
        print('✅ Registro exitoso: ${registeredUser.email}');
        _setSuccess(
            '¡Cuenta creada exitosamente! Ya puedes iniciar sesión con tu email 📧');
        _setLoading(false);
        return true;
      } else {
        print('❌ Registro fallido');
        _setError('Error al crear la cuenta');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      String errorMessage = _getAuthErrorMessage(e.toString());
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      print('🚪 Cerrando sesión...');
      await AuthService.signOut();
      _currentUser = null;
      _clearError();
      _setSuccess('Sesión cerrada correctamente');
      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      _setError('Error al cerrar sesión: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();
    _successMessage = null;

    try {
      print('🔄 Actualizando perfil: ${updatedUser.name}');

      bool success = await AuthService.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        _setSuccess('Perfil actualizado correctamente');
        print('✅ Perfil actualizado');
        _setLoading(false);
        return true;
      } else {
        print('❌ Error actualizando perfil');
        _setError('Error al actualizar perfil');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Error en updateProfile: $e');
      _setError('Error al actualizar perfil: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza solo la URL de la imagen de perfil
  Future<bool> updateProfileImageUrl(String imageUrl) async {
    _setLoading(true);
    _clearError();
    _successMessage = null;

    try {
      if (_currentUser == null) {
        _setError('No hay usuario autenticado');
        _setLoading(false);
        return false;
      }

      print('🖼️ Actualizando imagen de perfil: $imageUrl');

      // Actualizar en AuthService/Firestore
      bool success =
          await AuthService.updateProfileImage(_currentUser!.id, imageUrl);

      if (success) {
        // Actualizar usuario local
        _currentUser = _currentUser!.copyWith(profileImageUrl: imageUrl);
        _setSuccess('Imagen de perfil actualizada');
        print('✅ Imagen de perfil actualizada');
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar imagen');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Error updating profile image: $e');
      _setError('Error al actualizar imagen: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    _successMessage = null;

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

  // ✅ Método para forzar recarga de datos
  Future<void> refreshUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    }
  }

  // Métodos de utilidad
  String _getAuthErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Usuario no encontrado. Verifica tu email.';
    } else if (error.contains('wrong-password')) {
      return 'Contraseña incorrecta.';
    } else if (error.contains('invalid-email')) {
      return 'El formato del email no es válido.';
    } else if (error.contains('user-disabled')) {
      return 'Esta cuenta ha sido deshabilitada.';
    } else if (error.contains('too-many-requests')) {
      return 'Demasiados intentos. Intenta más tarde.';
    } else if (error.contains('email-already-in-use')) {
      return 'Este email ya está registrado. Usa otro email o inicia sesión.';
    } else if (error.contains('weak-password')) {
      return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
    } else if (error.contains('network-request-failed')) {
      return 'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
    }
    return 'Error de autenticación';
  }

  void clearError() => _clearError();
  void clearSuccess() => _successMessage = null;
  void clearMessages() {
    _clearError();
    _successMessage = null;
  }

  // Getters adicionales útiles
  bool get isProvider => _currentUser?.userType == UserType.provider;
  bool get isClient => _currentUser?.userType == UserType.client;
  bool get isAdmin => _currentUser?.userType == UserType.admin;
  String? get userId => _currentUser?.id;
  String get userName => _currentUser?.name ?? 'Usuario';
  String get userEmail => _currentUser?.email ?? '';
}
