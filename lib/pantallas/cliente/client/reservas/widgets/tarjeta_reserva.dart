// lib/pantallas/reservas/widgets/tarjeta_reserva.dart

import 'package:flutter/material.dart';
import '../../../../../modelos/modelo_reserva.dart';
import '../../../../../nucleo/utilidades/ayudantes.dart';
import '../controladores/controlador_reservas.dart';
import '../utilidades/constantes_reservas.dart';

/// 🎫 Widget que representa una tarjeta individual de reserva
/// Incluye información completa, acciones contextuales y estados visuales
class TarjetaReserva extends StatelessWidget {
  final BookingModel reserva;
  final int indice;
  final bool esProveedor;
  final ControladorReservas controlador;

  const TarjetaReserva({
    Key? key,
    required this.reserva,
    required this.indice,
    required this.esProveedor,
    required this.controlador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esUrgente = _esReservaUrgente();
    final infoTiempo = _obtenerInfoTiempo();
    final colorEstado = ConstantesReservas.obtenerColorEstado(reserva.status.toString());

    return AnimatedContainer(
      duration: ConstantesReservas.animacionMedia,
      curve: ConstantesReservas.curvaEaseOut,
      margin: const EdgeInsets.only(bottom: ConstantesReservas.margenEntreCards),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controlador.navegarADetalleReserva(reserva),
          borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasCard),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasCard),
              border: Border.all(
                color: esUrgente
                    ? ConstantesReservas.colorAdvertencia.withValues(alpha: 0.4)
                    : colorEstado.withValues(alpha: 0.2),
                width: esUrgente ? 2 : 1,
              ),
              boxShadow: esUrgente 
                  ? ConstantesReservas.obtenerSombraPersonalizada(
                      ConstantesReservas.colorAdvertencia, 15, const Offset(0, 8))
                  : ConstantesReservas.sombraCard,
            ),
            child: Column(
              children: [
                _construirSeccionHeader(esUrgente, infoTiempo, colorEstado),
                _construirSeccionFechaHora(colorEstado),
                _construirSeccionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 Construye la sección header con información principal
  Widget _construirSeccionHeader(bool esUrgente, String infoTiempo, Color colorEstado) {
    return Container(
      padding: const EdgeInsets.all(ConstantesReservas.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila principal: Servicio + Estado
          Row(
            children: [
              Expanded(
                child: _construirInfoServicio(),
              ),
              const SizedBox(width: 12),
              _construirChipEstado(colorEstado),
            ],
          ),
          
          // Indicador de urgencia si aplica
          if (esUrgente) ...[
            const SizedBox(height: 12),
            _construirIndicadorUrgente(infoTiempo),
          ],
          
          // Información adicional del cliente/proveedor
          const SizedBox(height: 12),
          _construirInfoPersona(),
        ],
      ),
    );
  }

  /// 🏷️ Información del servicio
  Widget _construirInfoServicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reserva.serviceName,
          style: ConstantesReservas.estiloTextoGrande.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Removido serviceDescription ya que no existe en el modelo
        const SizedBox(height: 4),
        Text(
          'ID: ${reserva.id.substring(0, 8)}...', // Mostrar ID abreviado
          style: ConstantesReservas.estiloTextoSecundario,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 👤 Información de la persona (cliente o proveedor)
  Widget _construirInfoPersona() {
    final nombre = esProveedor ? reserva.clientName : reserva.providerName;
    final icono = esProveedor ? Icons.person : Icons.business;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasChip),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icono,
              size: 16,
              color: ConstantesReservas.obtenerColorPrimario(esProveedor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esProveedor ? 'Cliente' : 'Proveedor',
                  style: ConstantesReservas.estiloTextoPequeno,
                ),
                Text(
                  nombre,
                  style: ConstantesReservas.estiloTextoMedio.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (reserva.rating != null) ...[
            const SizedBox(width: 8),
            _construirCalificacionExistente(),
          ],
        ],
      ),
    );
  }

  /// ⭐ Muestra la calificación si existe
  Widget _construirCalificacionExistente() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ConstantesReservas.gradienteAdvertencia,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            reserva.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏷️ Chip de estado de la reserva
  Widget _construirChipEstado(Color colorEstado) {
    final texto = ConstantesReservas.obtenerEtiquetaEstado(
      reserva.status.toString().split('.').last, 
      esProveedor,
    );
    final icono = ConstantesReservas.obtenerIconoEstado(
      reserva.status.toString().split('.').last,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorEstado.withValues(alpha: 0.15),
            colorEstado.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasChip),
        border: Border.all(color: colorEstado.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorEstado),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorEstado,
            ),
          ),
        ],
      ),
    );
  }

  /// ⚠️ Indicador de urgencia para reservas próximas
  Widget _construirIndicadorUrgente(String infoTiempo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ConstantesReservas.gradienteAdvertencia
              .map((c) => c.withValues(alpha: 0.1))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasChip),
        border: Border.all(
          color: ConstantesReservas.colorAdvertencia.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ConstantesReservas.colorAdvertencia.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              size: 14,
              color: ConstantesReservas.colorAdvertencia,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '🔥 $infoTiempo',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ConstantesReservas.colorAdvertencia,
            ),
          ),
        ],
      ),
    );
  }

  /// 📅 Sección de fecha y hora con diseño mejorado
  Widget _construirSeccionFechaHora(Color colorEstado) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ConstantesReservas.paddingCard),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorEstado.withValues(alpha: 0.03),
            colorEstado.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorEstado.withValues(alpha: 0.1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _construirSeccionFecha(colorEstado),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: colorEstado.withValues(alpha: 0.2),
            ),
            _construirSeccionHora(colorEstado),
          ],
        ),
      ),
    );
  }

  /// 📅 Sección de fecha
  Widget _construirSeccionFecha(Color colorEstado) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: colorEstado,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Helpers.formatDate(reserva.scheduledDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  _obtenerDiaSemana(reserva.scheduledDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🕐 Sección de hora
  Widget _construirSeccionHora(Color colorEstado) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: 20,
              color: colorEstado,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hora',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reserva.scheduledTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  _obtenerDuracionEstimada(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 Sección footer con precio y acciones
  Widget _construirSeccionFooter() {
    return Container(
      padding: const EdgeInsets.all(ConstantesReservas.paddingCard),
      child: Row(
        children: [
          _construirPrecio(),
          const Spacer(),
          _construirBotonesAccion(),
        ],
      ),
    );
  }

  /// 💵 Widget del precio con estilo mejorado
  Widget _construirPrecio() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ConstantesReservas.gradienteExito
              .map((c) => c.withValues(alpha: 0.1))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasChip),
        border: Border.all(
          color: ConstantesReservas.colorExito.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ConstantesReservas.colorExito.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.monetization_on,
              size: 14,
              color: ConstantesReservas.colorExito,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.formatCurrency(reserva.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ConstantesReservas.colorExito,
                ),
              ),
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎯 Botones de acción según el estado y tipo de usuario
  Widget _construirBotonesAccion() {
    List<Widget> acciones = [];

    if (esProveedor) {
      acciones = _construirAccionesProveedor();
    } else {
      acciones = _construirAccionesCliente();
    }

    if (acciones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: acciones,
    );
  }

  /// 🏢 Acciones para proveedores
  List<Widget> _construirAccionesProveedor() {
    List<Widget> acciones = [];

    switch (reserva.status) {
      case BookingStatus.pending:
        acciones.addAll([
          _construirBotonAccion(
            'Confirmar',
            Icons.check_circle,
            ConstantesReservas.colorExito,
            () => controlador.confirmarReserva(reserva),
          ),
          const SizedBox(width: 8),
          _construirBotonAccion(
            'Rechazar',
            Icons.cancel,
            ConstantesReservas.colorError,
            () => controlador.rechazarReserva(reserva),
          ),
        ]);
        break;
        
      case BookingStatus.confirmed:
      case BookingStatus.inProgress:
        acciones.add(
          _construirBotonAccion(
            'Completar',
            Icons.task_alt,
            ConstantesReservas.colorProveedorPrimario,
            () => controlador.completarReserva(reserva),
          ),
        );
        break;
        
      case BookingStatus.completed:
        if (reserva.rating == null) {
          acciones.add(
            _construirBotonAccion(
              'Calificar',
              Icons.star,
              ConstantesReservas.colorAdvertencia,
              () => controlador.calificarReserva(reserva),
            ),
          );
        }
        break;
        
      case BookingStatus.cancelled:
        break;
    }

    return acciones;
  }

  /// 👤 Acciones para clientes
  List<Widget> _construirAccionesCliente() {
    List<Widget> acciones = [];

    switch (reserva.status) {
      case BookingStatus.pending:
        acciones.add(
          _construirBotonAccion(
            'Cancelar',
            Icons.close,
            ConstantesReservas.colorError,
            () => controlador.cancelarReserva(reserva),
          ),
        );
        break;
        
      case BookingStatus.completed:
        if (reserva.rating == null) {
          acciones.add(
            _construirBotonAccion(
              'Calificar',
              Icons.star,
              ConstantesReservas.colorAdvertencia,
              () => controlador.calificarReserva(reserva),
            ),
          );
        }
        break;
        
      case BookingStatus.confirmed:
      case BookingStatus.inProgress:
      case BookingStatus.cancelled:
        break;
    }

    return acciones;
  }

  /// 🔘 Botón de acción individual
  Widget _construirBotonAccion(
    String texto,
    IconData icono,
    Color color,
    VoidCallback alPresionar,
  ) {
    return ElevatedButton.icon(
      onPressed: alPresionar,
      icon: Icon(icono, size: 16),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ConstantesReservas.radioEsquinasBoton),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔧 MÉTODOS AUXILIARES

  /// Verifica si la reserva es urgente (próxima en el tiempo)
  bool _esReservaUrgente() {
    if (reserva.status != BookingStatus.confirmed) return false;

    final ahora = DateTime.now();
    final fechaProgramada = DateTime(
      reserva.scheduledDate.year,
      reserva.scheduledDate.month,
      reserva.scheduledDate.day,
    );

    final diferencia = fechaProgramada.difference(ahora).inDays;
    return diferencia <= 1 && diferencia >= 0;
  }

  /// Obtiene información de tiempo para reservas urgentes
  String _obtenerInfoTiempo() {
    if (reserva.status != BookingStatus.confirmed) return '';

    final ahora = DateTime.now();
    final fechaProgramada = DateTime(
      reserva.scheduledDate.year,
      reserva.scheduledDate.month,
      reserva.scheduledDate.day,
    );

    final diferencia = fechaProgramada.difference(ahora).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Mañana';
    return '';
  }

  /// Obtiene el día de la semana en español
  String _obtenerDiaSemana(DateTime fecha) {
    const diasSemana = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 
      'Viernes', 'Sábado', 'Domingo'
    ];
    return diasSemana[fecha.weekday - 1];
  }

  /// Obtiene la duración estimada del servicio
  String _obtenerDuracionEstimada() {
    // Esto debería venir del modelo de servicio
    // Por ahora retornamos un valor por defecto
    return '~1 hora';
  }
}