// nucleo/utilidades/dialogos_servicio.dart
import 'package:flutter/material.dart';
import '../../../../../modelos/modelo_servicio.dart';
import '../../../../../nucleo/constantes/colores_app.dart';
import 'utilidades_servicios.dart';

class DialogosServicio {
  // Mostrar diálogo de detalles del servicio
  static void mostrarDetallesServicio(
    BuildContext context, 
    ServiceModel servicio, 
    Color colorAcento
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: _DetalleServicioDialog(
          servicio: servicio,
          colorAcento: colorAcento,
        ),
      ),
    );
  }

  // Mostrar diálogo de confirmación de contratación
  static void mostrarConfirmacionContratacion(
    BuildContext context,
    ServiceModel servicio,
    Color colorAcento,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: _ConfirmacionContratacionDialog(
          servicio: servicio,
          colorAcento: colorAcento,
        ),
      ),
    );
  }

  // Mostrar diálogo de información de contacto
  static void mostrarInfoContacto(
    BuildContext context,
    ServiceModel servicio,
    Color colorAcento,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _ContactoDialog(
          servicio: servicio,
          colorAcento: colorAcento,
        ),
      ),
    );
  }

  // Mostrar diálogo de calificación
  static void mostrarDialogoCalificacion(
    BuildContext context,
    ServiceModel servicio,
    Function(int) onCalificar,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _CalificacionDialog(
          servicio: servicio,
          onCalificar: onCalificar,
        ),
      ),
    );
  }
}

// ===============================================
// DIÁLOGO DE DETALLES DEL SERVICIO
// ===============================================
class _DetalleServicioDialog extends StatelessWidget {
  final ServiceModel servicio;
  final Color colorAcento;

  const _DetalleServicioDialog({
    required this.servicio,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _construirEncabezado(),
          Flexible(
            child: SingleChildScrollView(
              child: _construirContenido(),
            ),
          ),
          _construirBotones(context),
        ],
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorAcento.withOpacity(0.1),
            colorAcento.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorAcento,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colorAcento.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              UtilidadesServicios.obtenerIconoPorCategoria(servicio.category.toString()),
              color: AppColors.surface,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servicio.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  UtilidadesServicios.obtenerNombreProveedor(servicio),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información básica
          _construirSeccionInfo(),
          const SizedBox(height: 20),
          
          // Estado del servicio
          _construirEstadoServicio(),
          const SizedBox(height: 20),
          
          // Etiquetas del servicio
          _construirEtiquetas(),
          const SizedBox(height: 20),
          
          // Información adicional
          _construirInfoAdicional(),
        ],
      ),
    );
  }

  Widget _construirSeccionInfo() {
    return Column(
      children: [
        _construirInfoDialog('Categoría', servicio.category.toString()),
        _construirInfoDialog('Calificación', 
            '${UtilidadesServicios.formatearCalificacion(servicio.rating)} ⭐'),
        _construirInfoDialog('Precio', 
            '\$${UtilidadesServicios.obtenerPrecioServicio(servicio)}'),
        _construirInfoDialog('Duración', 
            UtilidadesServicios.formatearDuracion(servicio)),
        _construirInfoDialog('Experiencia', 
            UtilidadesServicios.obtenerNivelExperiencia(servicio)),
      ],
    );
  }

  Widget _construirInfoDialog(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoServicio() {
    final bool estaDisponible = UtilidadesServicios.estaDisponible(servicio);
    final Color colorEstado = UtilidadesServicios.obtenerColorEstado(estaDisponible);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorEstado.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorEstado,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              estaDisponible ? Icons.check : Icons.close,
              color: AppColors.surface,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              UtilidadesServicios.obtenerTextoDisponibilidad(servicio),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorEstado,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEtiquetas() {
    final etiquetas = UtilidadesServicios.obtenerEtiquetas(servicio);
    
    if (etiquetas.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiquetas:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: etiquetas.take(5).map((etiqueta) => Chip(
            label: Text(
              etiqueta,
              style: const TextStyle(fontSize: 11),
            ),
            backgroundColor: colorAcento.withOpacity(0.1),
            side: BorderSide(color: colorAcento.withOpacity(0.3)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          )).toList(),
        ),
      ],
    );
  }

  Widget _construirInfoAdicional() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Información adicional',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Servicio profesional garantizado\n'
            '• Atención personalizada\n'
            '• Presupuesto sin compromiso',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotones(BuildContext context) {
    final bool estaDisponible = UtilidadesServicios.estaDisponible(servicio);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Botones principales
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: estaDisponible
                      ? () {
                          Navigator.pop(context);
                          DialogosServicio.mostrarConfirmacionContratacion(
                              context, servicio, colorAcento);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAcento,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: AppColors.divider,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Contratar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Botón de contacto
          if (estaDisponible) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  DialogosServicio.mostrarInfoContacto(context, servicio, colorAcento);
                },
                icon: const Icon(Icons.contact_support, size: 18),
                label: const Text('Contactar proveedor'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: colorAcento,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===============================================
// DIÁLOGO DE CONFIRMACIÓN DE CONTRATACIÓN
// ===============================================
class _ConfirmacionContratacionDialog extends StatelessWidget {
  final ServiceModel servicio;
  final Color colorAcento;

  const _ConfirmacionContratacionDialog({
    required this.servicio,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de confirmación
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorAcento.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: colorAcento,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          
          // Título
          const Text(
            'Confirmar contratación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Descripción
          Text(
            '¿Confirmas la contratación de "${servicio.description}"?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          
          // Información del precio
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorAcento.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorAcento.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: colorAcento, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Precio: \$${UtilidadesServicios.obtenerPrecioServicio(servicio)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorAcento,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _confirmarContratacion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAcento,
                    foregroundColor: AppColors.surface,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarContratacion(BuildContext context) {
    Navigator.pop(context);
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.surface, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Servicio "${servicio.description}" contratado exitosamente!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Ver detalles',
          textColor: AppColors.surface,
          onPressed: () {
            // Aquí puedes navegar a los detalles de la contratación
          },
        ),
      ),
    );
  }
}

// ===============================================
// DIÁLOGO DE CONTACTO
// ===============================================
class _ContactoDialog extends StatelessWidget {
  final ServiceModel servicio;
  final Color colorAcento;

  const _ContactoDialog({
    required this.servicio,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de contacto
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorAcento.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.contact_support,
              color: colorAcento,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          
          // Título
          const Text(
            'Contactar Proveedor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Nombre del proveedor
          Text(
            UtilidadesServicios.obtenerNombreProveedor(servicio),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // Opciones de contacto
          _construirOpcionContacto(
            icono: Icons.phone,
            titulo: 'Llamar',
            subtitulo: 'Contacto directo por teléfono',
            onTap: () => _contactarPorTelefono(context),
          ),
          const SizedBox(height: 12),
          _construirOpcionContacto(
            icono: Icons.message,
            titulo: 'Enviar mensaje',
            subtitulo: 'Chat dentro de la aplicación',
            onTap: () => _enviarMensaje(context),
          ),
          const SizedBox(height: 12),
          _construirOpcionContacto(
            icono: Icons.email,
            titulo: 'Correo electrónico',
            subtitulo: 'Enviar consulta por email',
            onTap: () => _enviarEmail(context),
          ),
          const SizedBox(height: 20),
          
          // Botón cerrar
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.divider),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirOpcionContacto({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorAcento.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icono, color: colorAcento, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _contactarPorTelefono(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Función de llamada próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _enviarMensaje(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💬 Navegando al chat...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _enviarEmail(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📧 Función de email próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ===============================================
// DIÁLOGO DE CALIFICACIÓN
// ===============================================
class _CalificacionDialog extends StatefulWidget {
  final ServiceModel servicio;
  final Function(int) onCalificar;

  const _CalificacionDialog({
    required this.servicio,
    required this.onCalificar,
  });

  @override
  State<_CalificacionDialog> createState() => _CalificacionDialogState();
}

class _CalificacionDialogState extends State<_CalificacionDialog> {
  int _calificacionSeleccionada = 0;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado
          const Text(
            'Calificar Servicio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.servicio.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Estrellas de calificación
          const Text(
            '¿Cómo calificarías este servicio?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _calificacionSeleccionada = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: index < _calificacionSeleccionada
                        ? AppColors.warning
                        : AppColors.textHint,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          if (_calificacionSeleccionada > 0)
            Text(
              _obtenerTextoCalificacion(_calificacionSeleccionada),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 24),
          
          // Campo de comentario
          TextField(
            controller: _comentarioController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Comparte tu experiencia (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _calificacionSeleccionada > 0
                      ? () => _enviarCalificacion()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: AppColors.divider,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _obtenerTextoCalificacion(int calificacion) {
    switch (calificacion) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  void _enviarCalificacion() {
    widget.onCalificar(_calificacionSeleccionada);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 20),
            const SizedBox(width: 12),
            Text(
              '¡Gracias por tu calificación de $_calificacionSeleccionada estrella${_calificacionSeleccionada > 1 ? 's' : ''}!',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}