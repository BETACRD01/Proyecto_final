// lib/pantallas/reservas/widgets/dashboard_estadisticas.dart

import 'package:flutter/material.dart';
import '../../../../../proveedores/proveedor_reservas.dart';
import '../../../../../modelos/modelo_reserva.dart';

/// 📊 Dashboard que muestra estadísticas de reservas
/// Incluye tarjetas de resumen y panel detallado de actividad
class DashboardEstadisticas extends StatelessWidget {
  final BookingProvider proveedorReservas;
  final bool esProveedor;
  final bool estaRecargando;

  const DashboardEstadisticas({
    Key? key,
    required this.proveedorReservas,
    required this.esProveedor,
    required this.estaRecargando,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final estadisticas = _calcularEstadisticas();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _construirTarjetasResumen(estadisticas),
          const SizedBox(height: 12),
          _construirPanelActividad(estadisticas),
        ],
      ),
    );
  }

  /// 💰 Construye las tarjetas de resumen (Total e Ingresos/Gastado)
  Widget _construirTarjetasResumen(Map<String, dynamic> estadisticas) {
    return Row(
      children: [
        Expanded(
          child: _construirTarjetaMini(
            'Total',
            estadisticas['total'].toString(),
            Icons.grid_view_rounded,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _construirTarjetaMini(
            esProveedor ? 'Ingresos' : 'Gastado',
            '\$${estadisticas['ingresos']}',
            Icons.monetization_on_rounded,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  /// 🏷️ Tarjeta mini para mostrar estadísticas básicas
  Widget _construirTarjetaMini(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📈 Panel principal de actividad con grid de estadísticas
  Widget _construirPanelActividad(Map<String, dynamic> estadisticas) {
    return SizedBox(
      height: 180,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirEncabezadoPanel(),
            const SizedBox(height: 8),
            Expanded(
              child: _construirGridEstadisticas(estadisticas),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏁 Encabezado del panel con título e indicador de carga
  Widget _construirEncabezadoPanel() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: esProveedor
                  ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                  : [const Color(0xFF1B365D), const Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Resumen de actividad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (estaRecargando)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  /// 🔢 Grid con las estadísticas detalladas por estado
  Widget _construirGridEstadisticas(Map<String, dynamic> estadisticas) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _construirTarjetaEstadistica(
          'Pendientes',
          estadisticas['pendientes'].toString(),
          Icons.schedule_rounded,
          const Color(0xFFF59E0B),
          'En espera',
        ),
        _construirTarjetaEstadistica(
          'Confirmadas',
          estadisticas['confirmadas'].toString(),
          Icons.check_circle_rounded,
          const Color(0xFF2563EB),
          'Próximas',
        ),
        _construirTarjetaEstadistica(
          'Completadas',
          estadisticas['completadas'].toString(),
          Icons.task_alt_rounded,
          const Color(0xFF10B981),
          'Finalizadas',
        ),
        _construirTarjetaEstadistica(
          'Canceladas',
          estadisticas['canceladas'].toString(),
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
          'Rechazadas',
        ),
      ],
    );
  }

  /// 📋 Tarjeta individual para cada estadística de estado
  Widget _construirTarjetaEstadistica(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    String subtitulo,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icono, color: color, size: 12),
              ),
              const Spacer(),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🧮 Calcula todas las estadísticas a partir de las reservas
  Map<String, dynamic> _calcularEstadisticas() {
    final reservas = proveedorReservas.bookings;
    final total = reservas.length;
    final pendientes = proveedorReservas.getBookingsByStatus(BookingStatus.pending).length;
    final confirmadas = proveedorReservas.getBookingsByStatus(BookingStatus.confirmed).length;
    final completadas = proveedorReservas.getCompletedBookings().length;
    final canceladas = proveedorReservas.getBookingsByStatus(BookingStatus.cancelled).length;
    final ingresos = reservas
        .where((reserva) => reserva.status == BookingStatus.completed)
        .fold(0.0, (suma, reserva) => suma + reserva.totalPrice);

    return {
      'total': total,
      'pendientes': pendientes,
      'confirmadas': confirmadas,
      'completadas': completadas,
      'canceladas': canceladas,
      'ingresos': ingresos.toInt(),
    };
  }
}