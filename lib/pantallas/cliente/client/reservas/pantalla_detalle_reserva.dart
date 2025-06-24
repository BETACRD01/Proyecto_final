// lib/pantallas/reservas/pantalla_detalle_reserva.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../modelos/modelo_reserva.dart';
import '../../../../modelos/modelo_usuario.dart';
import '../../../../proveedores/proveedor_autenticacion.dart';
import '../../../../proveedores/proveedor_reservas.dart';
import '../../../../nucleo/utilidades/ayudantes.dart';

/// 📋 Pantalla de detalle de una reserva específica
class PantallaDetalleReserva extends StatefulWidget {
  const PantallaDetalleReserva({Key? key}) : super(key: key);

  @override
  State<PantallaDetalleReserva> createState() => _PantallaDetalleReservaState();
}

class _PantallaDetalleReservaState extends State<PantallaDetalleReserva> {
  late BookingModel reserva;
  bool esProveedor = false;
  bool cargando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener la reserva de los argumentos
    reserva = ModalRoute.of(context)!.settings.arguments as BookingModel;
    
    // Determinar tipo de usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    esProveedor = authProvider.currentUser?.userType == UserType.provider;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _construirAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _construirTarjetaInformacion(),
            const SizedBox(height: 20),
            _construirTarjetaPersona(),
            const SizedBox(height: 20),
            _construirTarjetaFechaHora(),
            const SizedBox(height: 20),
            _construirTarjetaPrecio(),
            if (reserva.rating != null) ...[
              const SizedBox(height: 20),
              _construirTarjetaCalificacion(),
            ],
            const SizedBox(height: 30),
            _construirBotonesAccion(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// 🎨 AppBar simple
  AppBar _construirAppBar() {
    return AppBar(
      title: const Text('Detalle de Reserva'),
      backgroundColor: esProveedor ? const Color(0xFF6366F1) : const Color(0xFF1B365D),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  /// 📄 Información básica del servicio
  Widget _construirTarjetaInformacion() {
    final colorEstado = _obtenerColorEstado(reserva.status);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reserva.serviceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                _construirChipEstado(colorEstado),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${reserva.id.substring(0, 8)}...',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 Información de la persona
  Widget _construirTarjetaPersona() {
    final nombre = esProveedor ? reserva.clientName : reserva.providerName;
    final tipo = esProveedor ? 'Cliente' : 'Proveedor';
    final icono = esProveedor ? Icons.person : Icons.business;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (esProveedor ? const Color(0xFF6366F1) : const Color(0xFF1B365D))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icono,
                color: esProveedor ? const Color(0xFF6366F1) : const Color(0xFF1B365D),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 Fecha y hora
  Widget _construirTarjetaFechaHora() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _construirInfoFechaHora(
                'Fecha',
                Helpers.formatDate(reserva.scheduledDate),
                Icons.calendar_today,
                const Color(0xFF3B82F6),
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: const Color(0xFFE5E7EB),
            ),
            Expanded(
              child: _construirInfoFechaHora(
                'Hora',
                reserva.scheduledTime,
                Icons.access_time,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirInfoFechaHora(String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  /// 💰 Precio
  Widget _construirTarjetaPrecio() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.1),
              const Color(0xFF059669).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Precio Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatCurrency(reserva.totalPrice),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⭐ Calificación si existe
  Widget _construirTarjetaCalificacion() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(
              Icons.star,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Calificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${reserva.rating!.toStringAsFixed(1)} ⭐',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Botones de acción
  Widget _construirBotonesAccion() {
    List<Widget> botones = [];

    if (esProveedor) {
      switch (reserva.status) {
        case BookingStatus.pending:
          botones.addAll([
            _construirBoton('Confirmar Reserva', Icons.check_circle, 
                const Color(0xFF10B981), () => _confirmarReserva()),
            const SizedBox(height: 12),
            _construirBoton('Rechazar Reserva', Icons.cancel, 
                const Color(0xFFEF4444), () => _rechazarReserva()),
          ]);
          break;
        case BookingStatus.confirmed:
          botones.add(_construirBoton('Marcar como Completado', Icons.task_alt, 
              const Color(0xFF6366F1), () => _completarReserva()));
          break;
        case BookingStatus.completed:
          if (reserva.rating == null) {
            botones.add(_construirBoton('Calificar Cliente', Icons.star, 
                const Color(0xFFF59E0B), () => _calificarReserva()));
          }
          break;
        default:
          break;
      }
    } else {
      switch (reserva.status) {
        case BookingStatus.pending:
          botones.add(_construirBoton('Cancelar Reserva', Icons.close, 
              const Color(0xFFEF4444), () => _cancelarReserva()));
          break;
        case BookingStatus.completed:
          if (reserva.rating == null) {
            botones.add(_construirBoton('Calificar Servicio', Icons.star, 
                const Color(0xFFF59E0B), () => _calificarReserva()));
          }
          break;
        default:
          break;
      }
    }

    return Column(children: botones);
  }

  Widget _construirBoton(String texto, IconData icono, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: cargando ? null : onPressed,
        icon: cargando ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ) : Icon(icono),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _construirChipEstado(Color colorEstado) {
    final texto = _obtenerTextoEstado(reserva.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorEstado.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorEstado.withValues(alpha: 0.3)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorEstado,
        ),
      ),
    );
  }

  // 🎯 MÉTODOS DE ACCIÓN

  void _confirmarReserva() => _ejecutarAccion(() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    return await provider.updateBookingStatus(reserva.id, BookingStatus.confirmed);
  }, '✅ Reserva confirmada');

  void _rechazarReserva() => _ejecutarAccion(() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    return await provider.cancelBooking(reserva.id, 'Rechazado por el proveedor');
  }, '❌ Reserva rechazada');

  void _completarReserva() => _ejecutarAccion(() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    return await provider.updateBookingStatus(reserva.id, BookingStatus.completed);
  }, '✅ Servicio completado');

  void _cancelarReserva() => _ejecutarAccion(() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    return await provider.cancelBooking(reserva.id, 'Cancelado por el cliente');
  }, '🚫 Reserva cancelada');

  void _calificarReserva() {
    // Aquí podrías abrir un diálogo de calificación
    // Por simplicidad, asignamos una calificación fija
    _ejecutarAccion(() async {
      final provider = Provider.of<BookingProvider>(context, listen: false);
      return await provider.rateBooking(reserva.id, 5.0, 'Excelente servicio');
    }, '⭐ Calificación enviada');
  }

  Future<void> _ejecutarAccion(Future<bool> Function() accion, String mensajeExito) async {
    setState(() => cargando = true);
    
    try {
      final exito = await accion();
      if (exito && mounted) {
        _mostrarMensaje(mensajeExito, const Color(0xFF10B981));
        Navigator.pop(context, true);
      } else {
        _mostrarMensaje('No se pudo completar la acción', const Color(0xFFEF4444));
      }
    } catch (e) {
      _mostrarMensaje('Error: $e', const Color(0xFFEF4444));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔧 MÉTODOS AUXILIARES

  Color _obtenerColorEstado(BookingStatus estado) {
    switch (estado) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return const Color(0xFF2563EB);
      case BookingStatus.inProgress:
        return const Color(0xFF6366F1);
      case BookingStatus.completed:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _obtenerTextoEstado(BookingStatus estado) {
    switch (estado) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.inProgress:
        return 'En Progreso';
      case BookingStatus.completed:
        return 'Completada';
      case BookingStatus.cancelled:
        return 'Cancelada';
    }
  }
}