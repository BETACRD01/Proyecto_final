import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/services/firebase_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _providers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get providers => _providers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadProviders() async {
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

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar proveedores');
      _setLoading(false);
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.usersCollection
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _setError('Error al obtener usuario');
      return null;
    }
  }

  Future<List<UserModel>> searchProviders(String query) async {
    try {
      QuerySnapshot snapshot = await FirebaseService.usersCollection
          .where('userType', isEqualTo: UserType.provider.index)
          .where('isActive', isEqualTo: true)
          .get();

      List<UserModel> allProviders = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return allProviders.where((provider) {
        return provider.name.toLowerCase().contains(query.toLowerCase()) ||
               provider.services.any((service) => 
                   service.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    } catch (e) {
      _setError('Error al buscar proveedores');
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
}
