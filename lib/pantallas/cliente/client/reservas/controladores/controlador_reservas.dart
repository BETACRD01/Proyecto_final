// lib/pantallas/reservas/controladores/controlador_reservas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../nucleo/constantes/rutas_app.dart';
import '../../../../../proveedores/proveedor_autenticacion.dart';
import '../../../../../proveedores/proveedor_reservas.dart';
import '../../../../../modelos/modelo_reserva.dart';
import '../../../../../modelos/modelo_usuario.dart';
import '../widgets/dialogos_reservas.dart';

/// 🧠 Controlador principal que maneja toda la lógica de negocio
/// para la pantalla de lista de reservas
class ControladorReservas {
  final BuildContext context;
  final TickerProviderStateMixin vsync;
  final VoidCallback alActualizar;
  final AnimationController controladorAnimacionFab;

  // 📊 Estado interno
  bool _estaRecargando = false;
  bool _esProveedor = false;
  UserModel? _usuarioActual;
  String _filtroSeleccionado = 'todos';

  ControladorReservas({
    required this.context,
    required this.vsync,
    required this.alActualizar,
    required this.controladorAnimacionFab,
  });

  // 🔍 Getters para acceder al estado
  bool get estaRecargando => _estaRecargando;
  bool get esProveedor => _esProveedor;
  UserModel? get usuarioActual => _usuarioActual;
  String get filtroSeleccionado => _filtroSeleccionado;

  /// 🚀 Inicializa el controlador y carga datos iniciales
  Future<void> inicializar() async {
    try {
      final proveedorAuth = Provider.of<AuthProvider>(context, listen: false);
      _usuarioActual = proveedorAuth.currentUser;

      if (_usuarioActual != null) {
        _esProveedor = _usuarioActual!.userType == UserType.provider;
        alActualizar();
        
        await cargarReservas();
        
        // Activar animación del FAB con delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (_montado) {
          controladorAnimacionFab.forward();
        }
      } else {
        _mostrarErrorSnackBar('No se pudo obtener la información del usuario');
      }
    } catch (e) {
      _mostrarErrorSnackBar('Error al inicializar: $e');
    }
  }

  /// 📥 Carga las reservas del usuario actual
  Future<void> cargarReservas() async {
    if (!_montado || _usuarioActual == null) return;
    
    _estaRecargando = true;
    alActualizar();

    try {
      final proveedorReservas = Provider.of<BookingProvider>(context, listen: false);
      await proveedorReservas.loadUserBookings(
        _usuarioActual!.id,
        isProvider: _esProveedor,
      );
      
      // Simular delay mínimo para mejor UX
      await Future.delayed(const Duration(milliseconds: 300));
      
    } catch (e) {
      if (_montado) {
        _mostrarErrorSnackBar('Error al cargar reservas: $e');
      }
    } finally {
      if (_montado) {
        _estaRecargando = false;
        alActualizar();
      }
    }
  }

  /// 🔄 Cambia el filtro seleccionado según el índice de pestaña
  void cambiarFiltro(int indice) {
    final nuevoFiltro = _obtenerFiltroPorIndice(indice);
    if (_filtroSeleccionado != nuevoFiltro) {
      _filtroSeleccionado = nuevoFiltro;
      alActualizar();
      
      // Feedback háptico ligero
      _ejecutarFeedbackHaptico();
    }
  }

  String _obtenerFiltroPorIndice(int indice) {
    switch (indice) {
      case 0: return 'todos';
      case 1: return 'pendientes';
      case 2: return 'confirmadas';
      case 3: return 'completadas';
      case 4: return 'canceladas';
      default: return 'todos';
    }
  }

  /// 🧭 Navega al detalle de una reserva
  void navegarADetalleReserva(BookingModel reserva) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingDetail,
      arguments: reserva,
    ).then((_) {
      // Recargar datos al regresar
      cargarReservas();
    });
  }

  /// 🎯 Ejecuta la acción del botón flotante según el tipo de usuario
  void accionBotonFlotante() {
    _ejecutarFeedbackHaptico();
    
    if (_esProveedor) {
      mostrarAccionesRapidasProveedor();
    } else {
      Navigator.pushNamed(context, '/home');
    }
  }

  // 🔧 ACCIONES DE RESERVAS

  /// ✅ Confirma una reserva pendiente (solo proveedores)
  void confirmarReserva(BookingModel reserva) {
    if (!_esProveedor) {
      _mostrarErrorSnackBar('Solo los proveedores pueden confirmar reservas');
      return;
    }

    DialogosReservas.mostrarConfirmacion(
      context: context,
      titulo: '✅ Confirmar Reserva',
      mensaje: '¿Confirmas la reserva de "${reserva.serviceName}" para ${reserva.clientName}?\n\nEsto notificará al cliente que su reserva ha sido aceptada.',
      textoConfirmar: 'Confirmar',
      colorConfirmar: const Color(0xFF10B981),
      alConfirmar: () => _ejecutarCambioEstado(
        reserva.id,
        BookingStatus.confirmed,
        '✅ Reserva confirmada exitosamente',
      ),
    );
  }

  /// ❌ Rechaza una reserva pendiente (solo proveedores)
  void rechazarReserva(BookingModel reserva) {
    if (!_esProveedor) {
      _mostrarErrorSnackBar('Solo los proveedores pueden rechazar reservas');
      return;
    }

    DialogosReservas.mostrarConfirmacion(
      context: context,
      titulo: '❌ Rechazar Reserva',
      mensaje: '¿Estás seguro de rechazar la reserva de "${reserva.serviceName}"?\n\nEsta acción no se puede deshacer y el cliente será notificado.',
      textoConfirmar: 'Rechazar',
      colorConfirmar: const Color(0xFFEF4444),
      textoSecundario: 'Ver detalles',
      accionSecundaria: () => navegarADetalleReserva(reserva),
      alConfirmar: () => _ejecutarCancelacion(
        reserva.id,
        'Rechazado por el proveedor',
        '❌ Reserva rechazada',
      ),
    );
  }

  /// ✔️ Marca una reserva como completada (solo proveedores)
  void completarReserva(BookingModel reserva) {
    if (!_esProveedor) {
      _mostrarErrorSnackBar('Solo los proveedores pueden completar reservas');
      return;
    }

    DialogosReservas.mostrarConfirmacion(
      context: context,
      titulo: '✔️ Completar Servicio',
      mensaje: '¿Has terminado el servicio de "${reserva.serviceName}"?\n\nMarcar como completado permitirá que el cliente califique el servicio.',
      textoConfirmar: 'Completar',
      colorConfirmar: const Color(0xFF6366F1),
      alConfirmar: () => _ejecutarCambioEstado(
        reserva.id,
        BookingStatus.completed,
        '✔️ Servicio marcado como completado',
      ),
    );
  }

  /// 🚫 Cancela una reserva (clientes)
  void cancelarReserva(BookingModel reserva) {
    if (_esProveedor) {
      _mostrarErrorSnackBar('Los proveedores deben usar "rechazar" en lugar de cancelar');
      return;
    }

    final DateTime ahora = DateTime.now();
    final DateTime fechaReserva = reserva.scheduledDate;
    final int diasRestantes = fechaReserva.difference(ahora).inDays;
    
    String mensajeAdicional = '';
    if (diasRestantes <= 1) {
      mensajeAdicional = '\n\n⚠️ Nota: La cancelación es con menos de 24 horas de anticipación.';
    }

    DialogosReservas.mostrarConfirmacion(
      context: context,
      titulo: '🚫 Cancelar Reserva',
      mensaje: '¿Estás seguro de cancelar la reserva de "${reserva.serviceName}"?$mensajeAdicional',
      textoConfirmar: 'Cancelar Reserva',
      colorConfirmar: const Color(0xFFEF4444),
      textoSecundario: 'Ver detalles',
      accionSecundaria: () => navegarADetalleReserva(reserva),
      alConfirmar: () => _ejecutarCancelacion(
        reserva.id,
        'Cancelado por el cliente',
        '🚫 Reserva cancelada exitosamente',
      ),
    );
  }

  /// ⭐ Permite calificar una reserva completada
  void calificarReserva(BookingModel reserva) {
    if (reserva.status != BookingStatus.completed) {
      _mostrarErrorSnackBar('Solo se pueden calificar servicios completados');
      return;
    }

    if (reserva.rating != null) {
      DialogosReservas.mostrarAlerta(
        context: context,
        titulo: '⭐ Ya calificado',
        mensaje: 'Este servicio ya ha sido calificado con ${reserva.rating!.toStringAsFixed(1)} estrellas.',
        textoBoton: 'Entendido',
      );
      return;
    }

    final esCliente = !_esProveedor;
    final titulo = esCliente ? '⭐ Calificar Servicio' : '⭐ Calificar Cliente';
    final subtitulo = esCliente 
        ? 'Tu opinión ayuda a otros usuarios a tomar mejores decisiones sobre "${reserva.serviceName}"'
        : 'Tu calificación sobre ${reserva.clientName} ayuda a mantener la calidad de la plataforma';

    DialogosReservas.mostrarCalificacion(
      context: context,
      titulo: titulo,
      subtitulo: subtitulo,
      alEnviar: (calificacion, resena) => _ejecutarCalificacion(
        reserva.id,
        calificacion,
        resena.trim(),
      ),
    );
  }

  // 🛠️ MÉTODOS AUXILIARES PARA EJECUTAR ACCIONES

  Future<void> _ejecutarCambioEstado(
    String reservaId,
    BookingStatus nuevoEstado,
    String mensajeExito,
  ) async {
    try {
      final proveedorReservas = Provider.of<BookingProvider>(context, listen: false);
      final exito = await proveedorReservas.updateBookingStatus(reservaId, nuevoEstado);
      
      if (exito && _montado) {
        _mostrarExitoSnackBar(mensajeExito);
        await cargarReservas();
        _ejecutarFeedbackHaptico();
      } else {
        _mostrarErrorSnackBar('No se pudo actualizar el estado de la reserva');
      }
    } catch (e) {
      _mostrarErrorSnackBar('Error al actualizar reserva: $e');
    }
  }

  Future<void> _ejecutarCancelacion(
    String reservaId,
    String razon,
    String mensajeExito,
  ) async {
    try {
      final proveedorReservas = Provider.of<BookingProvider>(context, listen: false);
      final exito = await proveedorReservas.cancelBooking(reservaId, razon);
      
      if (exito && _montado) {
        _mostrarExitoSnackBar(mensajeExito);
        await cargarReservas();
        _ejecutarFeedbackHaptico();
      } else {
        _mostrarErrorSnackBar('No se pudo cancelar la reserva');
      }
    } catch (e) {
      _mostrarErrorSnackBar('Error al cancelar reserva: $e');
    }
  }

  Future<void> _ejecutarCalificacion(
    String reservaId,
    double calificacion,
    String resena,
  ) async {
    try {
      final proveedorReservas = Provider.of<BookingProvider>(context, listen: false);
      final resenaFinal = resena.isEmpty ? null : resena;
      
      final exito = await proveedorReservas.rateBooking(
        reservaId,
        calificacion,
        resenaFinal,
      );
      
      if (exito && _montado) {
        _mostrarExitoSnackBar('⭐ Calificación enviada exitosamente');
        await cargarReservas();
        _ejecutarFeedbackHaptico();
      } else {
        _mostrarErrorSnackBar('No se pudo enviar la calificación');
      }
    } catch (e) {
      _mostrarErrorSnackBar('Error al enviar calificación: $e');
    }
  }

  // 📱 MÉTODOS DE INTERFAZ (MODALES Y BOTTOMSHEETS)

  /// 🔧 Muestra opciones de filtro en un modal
  void mostrarOpcionesFiltro() {
    _ejecutarFeedbackHaptico();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _construirModalFiltros(),
    );
  }

  /// ⚡ Muestra acciones rápidas para proveedores
  void mostrarAccionesRapidasProveedor() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _construirModalAccionesProveedor(),
    );
  }

  Widget _construirModalFiltros() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _construirIndicadorModal(),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Opciones de filtro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _construirOpcionModal(
            'Actualizar datos',
            'Sincronizar con el servidor',
            Icons.refresh,
            () {
              Navigator.pop(context);
              cargarReservas();
            },
          ),
          _construirOpcionModal(
            'Ordenar por fecha',
            'Cambiar orden de visualización',
            Icons.sort,
            () {
              Navigator.pop(context);
              _mostrarAlertaProximamente();
            },
          ),
          if (_esProveedor)
            _construirOpcionModal(
              'Ver estadísticas',
              'Analytics y reportes',
              Icons.analytics,
              () {
                Navigator.pop(context);
                _mostrarAlertaProximamente();
              },
            ),
          _construirOpcionModal(
            'Exportar datos',
            'Descargar información',
            Icons.download,
            () {
              Navigator.pop(context);
              _mostrarAlertaProximamente();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construirModalAccionesProveedor() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _construirIndicadorModal(),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Acciones rápidas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _construirItemAccion(
            'Gestionar servicios',
            'Edita tus servicios disponibles',
            Icons.business_center,
            const Color(0xFF6366F1),
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/provider/services');
            },
          ),
          _construirItemAccion(
            'Ver estadísticas',
            'Analiza tu rendimiento',
            Icons.analytics,
            const Color(0xFF10B981),
            () {
              Navigator.pop(context);
              _mostrarAlertaProximamente();
            },
          ),
          _construirItemAccion(
            'Horarios disponibles',
            'Configura tu disponibilidad',
            Icons.schedule,
            const Color(0xFF8B5CF6),
            () {
              Navigator.pop(context);
              _mostrarAlertaProximamente();
            },
          ),
          _construirItemAccion(
            'Configuración',
            'Ajusta tus preferencias',
            Icons.settings,
            const Color(0xFF6B7280),
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/provider/settings');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _construirIndicadorModal() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _construirOpcionModal(
    String titulo,
    String descripcion,
    IconData icono,
    VoidCallback alPresionar,
  ) {
    return ListTile(
      leading: Icon(icono, color: const Color(0xFF6366F1)),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        descripcion,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
        ),
      ),
      onTap: alPresionar,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _construirItemAccion(
    String titulo,
    String subtitulo,
    IconData icono,
    Color color,
    VoidCallback alPresionar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: alPresionar,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF9CA3AF),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 🎨 MÉTODOS DE FEEDBACK VISUAL (SNACKBARS)

  void _mostrarExitoSnackBar(String mensaje) {
    if (!_montado) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 10,
      ),
    );
  }

  void _mostrarErrorSnackBar(String mensaje) {
    if (!_montado) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 10,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          onPressed: cargarReservas,
        ),
      ),
    );
  }

  // 🔧 MÉTODOS DE UTILIDAD

  void _mostrarAlertaProximamente() {
    DialogosReservas.mostrarAlerta(
      context: context,
      titulo: '🚧 Próximamente',
      mensaje: 'Esta funcionalidad estará disponible en una próxima actualización.',
      textoBoton: 'Entendido',
      color: const Color(0xFF6366F1),
    );
  }

  void _ejecutarFeedbackHaptico() {
    // Implementar feedback háptico si es necesario
    // HapticFeedback.lightImpact();
  }

  /// Verifica si el widget está montado para evitar errores
  bool get _montado {
    return context.mounted;
  
  }
}
