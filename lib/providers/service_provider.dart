import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../core/services/firebase_service.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  bool _isLoading = false;
  String? _errorMessage;
  ServiceCategory? _selectedCategory;
  String _searchQuery = '';

  List<ServiceModel> get services => _filteredServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ServiceCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadServices() async {
    _setLoading(true);
    _setError(null);
    
    try {
      QuerySnapshot snapshot = await FirebaseService.servicesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      _services = snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar servicios');
      _setLoading(false);
    }
  }

  Future<void> loadServicesByProvider(String providerId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      QuerySnapshot snapshot = await FirebaseService.servicesCollection
          .where('providerId', isEqualTo: providerId)
          .where('isActive', isEqualTo: true)
          .get();

      _services = snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar servicios del proveedor');
      _setLoading(false);
    }
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.servicesCollection
          .doc(serviceId)
          .get();

      if (doc.exists) {
        return ServiceModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _setError('Error al obtener servicio');
      return null;
    }
  }

  Future<bool> createService(ServiceModel service) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.servicesCollection
          .doc(service.id)
          .set(service.toMap());

      _services.add(service);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear servicio');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.servicesCollection
          .doc(service.id)
          .update(service.toMap());

      int index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = service;
        _applyFilters();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al actualizar servicio');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.servicesCollection
          .doc(serviceId)
          .update({'isActive': false});

      _services.removeWhere((s) => s.id == serviceId);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al eliminar servicio');
      _setLoading(false);
      return false;
    }
  }

  void setCategory(ServiceCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredServices = _services.where((service) {
      bool matchesCategory = _selectedCategory == null || 
          service.category == _selectedCategory;
      
      bool matchesSearch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();

    notifyListeners();
  }

  List<ServiceModel> getPopularServices() {
    return _services
        .where((service) => service.rating >= 4.0)
        .take(5)
        .toList();
  }

  List<ServiceModel> getServicesByCategory(ServiceCategory category) {
    return _services
        .where((service) => service.category == category)
        .toList();
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _applyFilters();
  }

  void clearError() {
    _setError(null);
  }
}
