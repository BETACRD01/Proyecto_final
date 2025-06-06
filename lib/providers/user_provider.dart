import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../core/services/firebase_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _providers = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<UserModel> get providers => _providers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // ✅ Constructor sin inicialización automática
  UserProvider() {
    _initializeWhenFirebaseReady();
  }

  // ✅ Esperar a que Firebase esté listo
  Future<void> _initializeWhenFirebaseReady() async {
    try {
      // Asegurar que Firebase esté inicializado
      await Firebase.initializeApp();

      // Pequeña pausa para asegurar que Firestore esté listo
      await Future.delayed(const Duration(milliseconds: 100));

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) {
        debugPrint("✅ UserProvider inicializado correctamente");
      }
    } catch (e) {
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint("❌ Error al inicializar UserProvider: $e");
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
    notifyListeners();
  }

  // ✅ Verificar inicialización antes de usar Firestore
  Future<bool> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeWhenFirebaseReady();
    }
    return _isInitialized;
  }

  Future<void> loadProviders() async {
    // ✅ Verificar que Firebase esté listo
    if (!await _ensureInitialized()) {
      _setError('Firebase no está inicializado');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      QuerySnapshot snapshot = await FirebaseService.usersCollection
          .where('userType', isEqualTo: UserType.provider.index)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      _providers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint("✅ Cargados ${_providers.length} proveedores");
      }

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar proveedores: ${e.toString()}');
      _setLoading(false);

      if (kDebugMode) {
        debugPrint("❌ Error en loadProviders: $e");
      }
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    // ✅ Verificar que Firebase esté listo
    if (!await _ensureInitialized()) {
      _setError('Firebase no está inicializado');
      return null;
    }

    try {
      DocumentSnapshot doc =
          await FirebaseService.usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _setError('Error al obtener usuario: ${e.toString()}');

      if (kDebugMode) {
        debugPrint("❌ Error en getUserById: $e");
      }

      return null;
    }
  }

  Future<List<UserModel>> searchProviders(String query) async {
    // ✅ Verificar que Firebase esté listo
    if (!await _ensureInitialized()) {
      _setError('Firebase no está inicializado');
      return [];
    }

    try {
      QuerySnapshot snapshot = await FirebaseService.usersCollection
          .where('userType', isEqualTo: UserType.provider.index)
          .where('isActive', isEqualTo: true)
          .get();

      List<UserModel> allProviders = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      List<UserModel> results = allProviders.where((provider) {
        return provider.name.toLowerCase().contains(query.toLowerCase()) ||
            provider.services.any((service) =>
                service.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      if (kDebugMode) {
        debugPrint("✅ Búsqueda '$query': ${results.length} resultados");
      }

      return results;
    } catch (e) {
      _setError('Error al buscar proveedores: ${e.toString()}');

      if (kDebugMode) {
        debugPrint("❌ Error en searchProviders: $e");
      }

      return [];
    }
  }

  List<UserModel> getTopRatedProviders() {
    return _providers
        .where((provider) => provider.rating >= 4.0)
        .take(5)
        .toList();
  }

  List<UserModel> getProvidersByService(String service) {
    return _providers
        .where((provider) => provider.services.contains(service))
        .toList();
  }

  void clearError() {
    _setError(null);
  }

  // ✅ Método público para reinicializar si es necesario
  Future<void> reinitialize() async {
    _isInitialized = false;
    await _initializeWhenFirebaseReady();
  }
}
