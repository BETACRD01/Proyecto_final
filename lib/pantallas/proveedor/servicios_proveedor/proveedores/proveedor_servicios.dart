// lib/caracteristicas/servicios_proveedor/proveedores/proveedor_servicio.dart

import 'package:flutter/foundation.dart';
import '../modelos/modelo_servicio.dart';

class ProveedorServicio extends ChangeNotifier {
  List<ModeloServicio> _servicios = [];
  List<ModeloServicio> _serviciosFiltrados = [];
  bool _estaCargando = false;
  String? _mensajeError;
  String _consultaBusqueda = '';

  // Getters
  List<ModeloServicio> get servicios => _consultaBusqueda.isEmpty 
      ? List.unmodifiable(_servicios) 
      : List.unmodifiable(_serviciosFiltrados);
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  String get consultaBusqueda => _consultaBusqueda;
  
  List<ModeloServicio> get serviciosActivos => 
      servicios.where((servicio) => servicio.estaActivo).toList();
  
  List<ModeloServicio> get serviciosInactivos => 
      servicios.where((servicio) => !servicio.estaActivo).toList();

  int get totalServicios => servicios.length;
  int get totalServiciosActivos => serviciosActivos.length;
  double get calificacionPromedio {
    if (servicios.isEmpty) return 0.0;
    double suma = servicios.fold(0.0, (sum, servicio) => sum + servicio.calificacion);
    return suma / servicios.length;
  }

  // Método agregado para compatibilidad con pantalla_inicio.dart
  Future<void> loadServices() async {
    await cargarServiciosDelProveedor('usuario_ejemplo');
  }

  // Método agregado para búsqueda
  void setSearchQuery(String query) {
    _consultaBusqueda = query.trim();
    
    if (_consultaBusqueda.isEmpty) {
      _serviciosFiltrados.clear();
    } else {
      _serviciosFiltrados = buscarPorNombre(_consultaBusqueda);
    }
    
    notifyListeners();
  }

  // Limpiar búsqueda
  void limpiarBusqueda() {
    _consultaBusqueda = '';
    _serviciosFiltrados.clear();
    notifyListeners();
  }

  // Métodos para gestionar el estado de carga
  void _establecerCargando(bool cargando) {
    _estaCargando = cargando;
    notifyListeners();
  }

  void _establecerError(String? error) {
    _mensajeError = error;
    notifyListeners();
  }

  void limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }

  // Cargar servicios del proveedor
  Future<bool> cargarServiciosDelProveedor(String proveedorId) async {
    _establecerCargando(true);
    _establecerError(null);

    try {
      // Simular llamada a API - reemplazar con tu implementación real
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Datos de ejemplo - reemplazar con datos reales de la API
      _servicios = _obtenerServiciosEjemplo(proveedorId);
      
      _establecerCargando(false);
      return true;
    } catch (e) {
      _establecerError('Error al cargar servicios: ${e.toString()}');
      _establecerCargando(false);
      return false;
    }
  }

  // Agregar nuevo servicio
  Future<bool> agregarServicio(ModeloServicio servicio) async {
    _establecerCargando(true);
    _establecerError(null);

    try {
      // Validar el servicio
      if (!servicio.esValido) {
        throw Exception('Datos del servicio no válidos');
      }

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Crear servicio con ID generado
      final nuevoServicio = servicio.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      _servicios.add(nuevoServicio);
      
      // Actualizar filtrados si hay búsqueda activa
      if (_consultaBusqueda.isNotEmpty) {
        setSearchQuery(_consultaBusqueda);
      }
      
      _establecerCargando(false);
      return true;
    } catch (e) {
      _establecerError('Error al agregar servicio: ${e.toString()}');
      _establecerCargando(false);
      return false;
    }
  }

  // Actualizar servicio existente
  Future<bool> actualizarServicio(ModeloServicio servicio) async {
    _establecerCargando(true);
    _establecerError(null);

    try {
      // Validar el servicio
      if (!servicio.esValido) {
        throw Exception('Datos del servicio no válidos');
      }

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 800));

      final indice = _servicios.indexWhere((s) => s.id == servicio.id);
      if (indice == -1) {
        throw Exception('Servicio no encontrado');
      }

      _servicios[indice] = servicio.copyWith(
        fechaActualizacion: DateTime.now(),
      );

      // Actualizar filtrados si hay búsqueda activa
      if (_consultaBusqueda.isNotEmpty) {
        setSearchQuery(_consultaBusqueda);
      }

      _establecerCargando(false);
      return true;
    } catch (e) {
      _establecerError('Error al actualizar servicio: ${e.toString()}');
      _establecerCargando(false);
      return false;
    }
  }

  // Eliminar servicio
  Future<bool> eliminarServicio(String servicioId) async {
    _establecerCargando(true);
    _establecerError(null);

    try {
      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 800));

      final indice = _servicios.indexWhere((s) => s.id == servicioId);
      if (indice == -1) {
        throw Exception('Servicio no encontrado');
      }

      _servicios.removeAt(indice);
      
      // Actualizar filtrados si hay búsqueda activa
      if (_consultaBusqueda.isNotEmpty) {
        setSearchQuery(_consultaBusqueda);
      }
      
      _establecerCargando(false);
      return true;
    } catch (e) {
      _establecerError('Error al eliminar servicio: ${e.toString()}');
      _establecerCargando(false);
      return false;
    }
  }

  // Cambiar estado del servicio (activo/inactivo)
  Future<bool> cambiarEstadoServicio(String servicioId, bool nuevoEstado) async {
    final servicio = _servicios.firstWhere(
      (s) => s.id == servicioId,
      orElse: () => throw Exception('Servicio no encontrado'),
    );

    return await actualizarServicio(servicio.copyWith(estaActivo: nuevoEstado));
  }

  // Obtener servicio por ID
  ModeloServicio? obtenerServicioPorId(String servicioId) {
    try {
      return _servicios.firstWhere((s) => s.id == servicioId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar servicios por categoría
  List<ModeloServicio> filtrarPorCategoria(String categoria) {
    return _servicios.where((s) => s.categoria == categoria).toList();
  }

  // Buscar servicios por nombre
  List<ModeloServicio> buscarPorNombre(String termino) {
    final terminoLower = termino.toLowerCase();
    return _servicios.where((s) => 
      s.nombre.toLowerCase().contains(terminoLower) ||
      s.descripcion.toLowerCase().contains(terminoLower)
    ).toList();
  }

  // Limpiar todos los servicios
  void limpiarServicios() {
    _servicios.clear();
    _serviciosFiltrados.clear();
    _consultaBusqueda = '';
    _mensajeError = null;
    notifyListeners();
  }

// Agregar este método a tu clase ProveedorServicio:
Future<void> loadServicesByProvider(String userId) async {
  await cargarServiciosDelProveedor(userId);
}

  // Datos de ejemplo - remover en producción
  List<ModeloServicio> _obtenerServiciosEjemplo(String proveedorId) {
    return [
      ModeloServicio(
        id: '1',
        nombre: 'Plomería Residencial',
        descripcion: 'Reparación y mantenimiento de sistemas de plomería en hogares',
        categoria: 'plomeria',
        precioPorHora: 25.0,
        estaActivo: true,
        calificacion: 4.5,
        totalCalificaciones: 12,
        proveedorId: proveedorId,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 30)),
        fechaActualizacion: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ModeloServicio(
        id: '2',
        nombre: 'Electricidad Básica',
        descripcion: 'Instalación y reparación de sistemas eléctricos básicos',
        categoria: 'electricidad',
        precioPorHora: 30.0,
        estaActivo: true,
        calificacion: 4.8,
        totalCalificaciones: 8,
        proveedorId: proveedorId,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 45)),
        fechaActualizacion: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ModeloServicio(
        id: '3',
        nombre: 'Jardinería',
        descripcion: 'Mantenimiento de jardines y áreas verdes',
        categoria: 'jardineria',
        precioPorHora: 15.0,
        estaActivo: false,
        calificacion: 4.2,
        totalCalificaciones: 15,
        proveedorId: proveedorId,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 60)),
        fechaActualizacion: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}