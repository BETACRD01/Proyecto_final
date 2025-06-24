// lib/pantallas/reservas/widgets/estados_carga.dart

import 'package:flutter/material.dart';

/// ⏳ Clase que maneja todos los estados de la aplicación
/// Incluye: carga, error, vacío con diferentes variaciones
class EstadosCarga {
  
  /// 🔄 Estado de carga con spinner animado
  static Widget construirCargando(bool esProveedor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                esProveedor ? const Color(0xFF6366F1) : const Color(0xFF1B365D),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando reservas...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Estado de error con opción de reintento
  static Widget construirError({
    required String mensaje,
    required VoidCallback alReintentar,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444).withValues(alpha: 0.1),
                    const Color(0xFFDC2626).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B365D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 Estado vacío con mensajes personalizados según filtro y tipo de usuario
  static Widget construirVacio({
    required String filtroSeleccionado,
    required bool esProveedor,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: esProveedor
                        ? [
                            const Color(0xFF6366F1).withValues(alpha: 0.1),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                          ]
                        : [
                            const Color(0xFF1B365D).withValues(alpha: 0.1),
                            const Color(0xFF2563EB).withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: Icon(
                  _obtenerIconoEstadoVacio(filtroSeleccionado, esProveedor),
                  size: 64,
                  color: esProveedor
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF1B365D),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _obtenerTituloEstadoVacio(filtroSeleccionado, esProveedor),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _obtenerSubtituloEstadoVacio(filtroSeleccionado, esProveedor),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí puedes agregar navegación personalizada
                },
                icon: Icon(_obtenerIconoAccionEstadoVacio(esProveedor), size: 20),
                label: Text(_obtenerTextoAccionEstadoVacio(esProveedor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: esProveedor
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 MÉTODOS AUXILIARES PARA PERSONALIZAR ESTADOS VACÍOS

  /// 🎯 Obtiene el ícono apropiado según filtro y tipo de usuario
  static IconData _obtenerIconoEstadoVacio(String filtro, bool esProveedor) {
    if (esProveedor) {
      switch (filtro) {
        case 'pendientes':
          return Icons.schedule_rounded;
        case 'confirmadas':
          return Icons.check_circle_rounded;
        case 'completadas':
          return Icons.task_alt_rounded;
        case 'canceladas':
          return Icons.cancel_rounded;
        default:
          return Icons.business_center_rounded;
      }
    } else {
      switch (filtro) {
        case 'pendientes':
          return Icons.schedule_rounded;
        case 'confirmadas':
          return Icons.event_available_rounded;
        case 'completadas':
          return Icons.check_circle_rounded;
        case 'canceladas':
          return Icons.event_busy_rounded;
        default:
          return Icons.calendar_today_rounded;
      }
    }
  }

  /// 📝 Obtiene el título del mensaje según filtro y tipo de usuario
  static String _obtenerTituloEstadoVacio(String filtro, bool esProveedor) {
    if (esProveedor) {
      switch (filtro) {
        case 'pendientes':
          return 'Sin reservas pendientes';
        case 'confirmadas':
          return 'Sin reservas confirmadas';
        case 'completadas':
          return 'Sin servicios completados';
        case 'canceladas':
          return 'Sin reservas canceladas';
        default:
          return 'Sin reservas registradas';
      }
    } else {
      switch (filtro) {
        case 'pendientes':
          return 'No hay reservas pendientes';
        case 'confirmadas':
          return 'No hay reservas confirmadas';
        case 'completadas':
          return 'No hay servicios completados';
        case 'canceladas':
          return 'No hay reservas canceladas';
        default:
          return 'No tienes reservas';
      }
    }
  }

  /// 💬 Obtiene el subtítulo explicativo según filtro y tipo de usuario
  static String _obtenerSubtituloEstadoVacio(String filtro, bool esProveedor) {
    if (esProveedor) {
      switch (filtro) {
        case 'pendientes':
          return 'Las nuevas reservas aparecerán aquí\npara que las confirmes';
        case 'confirmadas':
          return 'Las reservas confirmadas se\nmostrarán aquí';
        case 'completadas':
          return 'Aquí verás el historial de\nservicios completados';
        case 'canceladas':
          return 'Las reservas canceladas\naparecerán en esta sección';
        default:
          return 'Cuando los clientes reserven tus servicios\naparecerán aquí';
      }
    } else {
      switch (filtro) {
        case 'pendientes':
          return 'Las reservas en espera de confirmación\naparecerán aquí';
        case 'confirmadas':
          return 'Tus próximas citas confirmadas\nse mostrarán aquí';
        case 'completadas':
          return 'El historial de servicios utilizados\naparecerá en esta sección';
        case 'canceladas':
          return 'Las reservas canceladas\nse mostrarán aquí';
        default:
          return 'Tus reservas aparecerán aquí cuando\nrealices tu primera reserva';
      }
    }
  }

  /// ⚡ Obtiene el ícono del botón de acción
  static IconData _obtenerIconoAccionEstadoVacio(bool esProveedor) {
    return esProveedor ? Icons.add_business : Icons.search;
  }

  /// 🔤 Obtiene el texto del botón de acción
  static String _obtenerTextoAccionEstadoVacio(bool esProveedor) {
    return esProveedor ? 'Gestionar servicios' : 'Explorar servicios';
  }
}