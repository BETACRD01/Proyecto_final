// lib/pantallas/cliente/client/chat/controladores/controlador_chat.dart

import 'package:flutter/material.dart';
import '../modelos/modelo_conversacion.dart';
import '../servicios/servicio_chat.dart';
import '../utilidades/utilidades_chat.dart';

class ControladorChat extends ChangeNotifier {
  
  // Estado
  List<ModeloConversacion> _conversaciones = [];
  bool _estaCargando = false;
  String? _error;
  String _consultaBusqueda = '';
  bool _disposed = false;                    // ✅ AGREGAR: Control de disposed

  // Getters
  List<ModeloConversacion> get conversaciones => _conversaciones;
  bool get estaCargando => _estaCargando;
  String? get error => _error;
  String get consultaBusqueda => _consultaBusqueda;
  bool get disposed => _disposed;            // ✅ AGREGAR: Getter para disposed
  
  // Conversaciones filtradas por búsqueda
  List<ModeloConversacion> get conversacionesFiltradas {
    if (_consultaBusqueda.isEmpty) return _conversaciones;
    
    final consulta = UtilidadesChat.limpiarConsultaBusqueda(_consultaBusqueda);
    return _conversaciones.where((conversacion) =>
      conversacion.nombreProveedor.toLowerCase().contains(consulta) ||
      conversacion.nombreServicio.toLowerCase().contains(consulta) ||
      conversacion.ultimoMensaje.toLowerCase().contains(consulta)
    ).toList();
  }

  // Total de conversaciones no leídas
  int get totalNoLeidos => _conversaciones
      .where((c) => c.mensajesNoLeidos > 0)
      .length;

  // Mensaje de estado para el header
  String get mensajeEstado => UtilidadesChat.obtenerMensajeEstado(totalNoLeidos);

  // Constructor
  ControladorChat() {
    cargarConversaciones();
  }

  // ===================== MÉTODOS HELPER PARA NOTIFICACIONES =====================

  void _notificarSiNoEstaDispuesto() {       // ✅ AGREGAR: Helper para notificaciones seguras
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ===================== MÉTODOS DE CARGA =====================

  Future<void> cargarConversaciones() async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _establecerCargando(true);
    _limpiarError();
    
    try {
      _conversaciones = await ServicioChat.obtenerConversaciones();
      _notificarSiNoEstaDispuesto();         // ✅ CAMBIO: Notificación segura
    } catch (e) {
      _establecerError('Error al cargar conversaciones: ${e.toString()}');
    } finally {
      _establecerCargando(false);
    }
  }

  Future<void> actualizarConversaciones() async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    try {
      _conversaciones = await ServicioChat.obtenerConversaciones();
      _notificarSiNoEstaDispuesto();         // ✅ CAMBIO: Notificación segura
    } catch (e) {
      _establecerError('Error al actualizar conversaciones');
    }
  }

  // ===================== BÚSQUEDA =====================

  void establecerConsultaBusqueda(String consulta) {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _consultaBusqueda = consulta;
    _notificarSiNoEstaDispuesto();           // ✅ CAMBIO: Notificación segura
  }

  void limpiarBusqueda() {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _consultaBusqueda = '';
    _notificarSiNoEstaDispuesto();           // ✅ CAMBIO: Notificación segura
  }

  Future<void> realizarBusqueda(String consulta) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    if (consulta.trim().isEmpty) {
      limpiarBusqueda();
      return;
    }

    _establecerCargando(true);
    try {
      final resultados = await ServicioChat.buscarConversaciones(consulta);
      if (!_disposed) {                      // ✅ PROTECCIÓN EXTRA
        _conversaciones = resultados;
        _consultaBusqueda = consulta;
        _notificarSiNoEstaDispuesto();       // ✅ CAMBIO: Notificación segura
      }
    } catch (e) {
      _establecerError('Error en la búsqueda: ${e.toString()}');
    } finally {
      _establecerCargando(false);
    }
  }

  // ===================== ACCIONES DE CONVERSACIÓN =====================

  Future<void> abrirConversacion(ModeloConversacion conversacion) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    // Marcar como leído si tiene mensajes no leídos
    if (conversacion.mensajesNoLeidos > 0) {
      await marcarComoLeido(conversacion.id);
    }
    
    // TODO: Navegar a la pantalla de chat individual
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => PantallaChat Individual(
    //     idConversacion: conversacion.id,
    //     nombreProveedor: conversacion.nombreProveedor,
    //   ),
    // ));
  }

  Future<void> marcarComoLeido(String idConversacion) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    try {
      final exito = await ServicioChat.marcarComoLeido(idConversacion);
      if (exito && !_disposed) {             // ✅ PROTECCIÓN EXTRA
        _actualizarConversacionEnLista(idConversacion, (conv) => conv.marcarComoLeido());
      }
    } catch (e) {
      _establecerError('Error al marcar como leído');
    }
  }

  Future<void> marcarComoNoLeido(String idConversacion) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    try {
      final exito = await ServicioChat.marcarComoNoLeido(idConversacion);
      if (exito && !_disposed) {             // ✅ PROTECCIÓN EXTRA
        _actualizarConversacionEnLista(idConversacion, (conv) => conv.marcarComoNoLeido());
      }
    } catch (e) {
      _establecerError('Error al marcar como no leído');
    }
  }

  Future<void> eliminarConversacion(String idConversacion) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    try {
      final exito = await ServicioChat.eliminarConversacion(idConversacion);
      if (exito && !_disposed) {             // ✅ PROTECCIÓN EXTRA
        _conversaciones.removeWhere((c) => c.id == idConversacion);
        _notificarSiNoEstaDispuesto();       // ✅ CAMBIO: Notificación segura
      }
    } catch (e) {
      _establecerError('Error al eliminar conversación');
    }
  }

  Future<void> bloquearContacto(String idConversacion) async {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    try {
      final exito = await ServicioChat.bloquearContacto(idConversacion);
      if (exito && !_disposed) {             // ✅ PROTECCIÓN EXTRA
        // Opcional: remover de la lista o marcar como bloqueado
        _conversaciones.removeWhere((c) => c.id == idConversacion);
        _notificarSiNoEstaDispuesto();       // ✅ CAMBIO: Notificación segura
      }
    } catch (e) {
      _establecerError('Error al bloquear contacto');
    }
  }

  // ===================== NAVEGACIÓN =====================

  void irAServicios() {
    // TODO: Implementar navegación a servicios
    // Navigator.pushNamed(context, '/servicios');
  }

  void abrirNotificaciones() {
    // TODO: Implementar navegación a notificaciones
    // Navigator.pushNamed(context, '/notificaciones');
  }

  void iniciarNuevoChat() {
    // TODO: Implementar selección de proveedor para nuevo chat
    // Navigator.pushNamed(context, '/seleccionar-proveedor');
  }

  void abrirFiltros() {
    // TODO: Implementar pantalla de filtros
    // showModalBottomSheet(context: context, builder: (context) => HojaFiltros());
  }

  // ===================== MÉTODOS PRIVADOS =====================

  void _establecerCargando(bool cargando) {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _estaCargando = cargando;
    _notificarSiNoEstaDispuesto();           // ✅ CAMBIO: Notificación segura
  }

  void _establecerError(String error) {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _error = error;
    _notificarSiNoEstaDispuesto();           // ✅ CAMBIO: Notificación segura
  }

  void _limpiarError() {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    _error = null;
  }

  void _actualizarConversacionEnLista(String idConversacion, ModeloConversacion Function(ModeloConversacion) actualizador) {
    if (_disposed) return;                   // ✅ PROTECCIÓN
    
    final indice = _conversaciones.indexWhere((c) => c.id == idConversacion);
    if (indice != -1) {
      _conversaciones[indice] = actualizador(_conversaciones[indice]);
      _notificarSiNoEstaDispuesto();         // ✅ CAMBIO: Notificación segura
    }
  }

  // ===================== DISPOSE =====================

  @override
  void dispose() {
    _disposed = true;                        // ✅ CAMBIO: Marcar como disposed
    super.dispose();
  }
}