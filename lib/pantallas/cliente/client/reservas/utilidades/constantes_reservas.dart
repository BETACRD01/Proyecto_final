// lib/pantallas/reservas/utilidades/constantes_reservas.dart

import 'package:flutter/material.dart';

/// 🔧 Clase que centraliza todas las constantes, colores y configuraciones
/// del módulo de reservas para mantener consistencia visual
class ConstantesReservas {
  
  // 🎨 COLORES POR TIPO DE USUARIO
  
  /// Colores para proveedores de servicios
  static const Color colorProveedorPrimario = Color(0xFF6366F1);
  static const Color colorProveedorSecundario = Color(0xFF8B5CF6);
  static const Color colorProveedorTerciario = Color(0xFFEC4899);
  static const Color colorProveedorCuaternario = Color(0xFF06B6D4);
  
  /// Colores para clientes
  static const Color colorClientePrimario = Color(0xFF1B365D);
  static const Color colorClienteSecundario = Color(0xFF2563EB);
  static const Color colorClienteTerciario = Color(0xFF3B82F6);
  static const Color colorClienteCuaternario = Color(0xFF0EA5E9);
  
  // 🏷️ COLORES POR ESTADO DE RESERVA
  
  static const Color colorPendiente = Color(0xFFF59E0B);
  static const Color colorConfirmada = Color(0xFF2563EB);
  static const Color colorEnProgreso = Color(0xFF6366F1);
  static const Color colorCompletada = Color(0xFF10B981);
  static const Color colorCancelada = Color(0xFFEF4444);
  
  // 🎯 COLORES ADICIONALES PARA UI
  
  static const Color colorExito = Color(0xFF10B981);
  static const Color colorError = Color(0xFFEF4444);
  static const Color colorAdvertencia = Color(0xFFF59E0B);
  static const Color colorInfo = Color(0xFF3B82F6);
  static const Color colorNeutro = Color(0xFF6B7280);
  
  // 🌈 GRADIENTES PREDEFINIDOS
  
  /// Gradiente para proveedores
  static const List<Color> gradienteProveedor = [
    colorProveedorPrimario,
    colorProveedorSecundario,
    colorProveedorTerciario,
  ];
  
  /// Gradiente para clientes
  static const List<Color> gradienteCliente = [
    colorClientePrimario,
    colorClienteSecundario,
    colorClienteTerciario,
  ];
  
  /// Gradiente de éxito
  static const List<Color> gradienteExito = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  /// Gradiente de error
  static const List<Color> gradienteError = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
  
  /// Gradiente de advertencia
  static const List<Color> gradienteAdvertencia = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  
  // ⏱️ DURACIONES DE ANIMACIÓN
  
  static const Duration animacionRapida = Duration(milliseconds: 200);
  static const Duration animacionMedia = Duration(milliseconds: 400);
  static const Duration animacionLenta = Duration(milliseconds: 600);
  static const Duration animacionMuyLenta = Duration(milliseconds: 1200);
  
  static const Duration transicionPagina = Duration(milliseconds: 300);
  static const Duration feedbackVisual = Duration(milliseconds: 150);
  
  // 📐 DIMENSIONES Y ESPACIADO
  
  /// Radios de esquinas
  static const double radioEsquinasCard = 20.0;
  static const double radioEsquinasBoton = 16.0;
  static const double radioEsquinasChip = 12.0;
  static const double radioEsquinasModal = 24.0;
  static const double radioEsquinasPequeno = 8.0;
  
  /// Paddings
  static const double paddingHorizontalPantalla = 20.0;
  static const double paddingVerticalPantalla = 16.0;
  static const double paddingCard = 20.0;
  static const double paddingBoton = 16.0;
  static const double paddingModal = 24.0;
  static const double paddingPequeno = 8.0;
  static const double paddingGrande = 32.0;
  
  /// Márgenes
  static const double margenEntreCards = 16.0;
  static const double margenSeccion = 24.0;
  static const double margenPequeno = 8.0;
  static const double margenGrande = 32.0;
  
  /// Alturas específicas
  static const double alturaBoton = 48.0;
  static const double alturaBotonPequeno = 36.0;
  static const double alturaAppBarExpandido = 200.0;
  static const double alturaDashboard = 180.0;
  static const double alturaTabBar = 48.0;
  
  // 🎭 ELEVACIONES Y SOMBRAS
  
  static const double elevacionCard = 8.0;
  static const double elevacionModal = 16.0;
  static const double elevacionBoton = 4.0;
  static const double elevacionAppBar = 0.0;
  
  /// Sombras predefinidas
  static List<BoxShadow> get sombraCard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get sombraModal => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];
  
  static List<BoxShadow> get sombraBoton => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get sombraAppBar => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  // 📱 TAMAÑOS DE FUENTE Y ESTILOS DE TEXTO
  
  static const double fuenteTituloGrande = 32.0;
  static const double fuenteTitulo = 24.0;
  static const double fuenteSubtitulo = 20.0;
  static const double fuenteTextoGrande = 18.0;
  static const double fuenteTextoNormal = 16.0;
  static const double fuenteTextoMedio = 14.0;
  static const double fuenteTextoPequeno = 12.0;
  static const double fuenteTextoMinimo = 10.0;
  
  /// Estilos de texto predefinidos
  static const TextStyle estiloTituloGrande = TextStyle(
    fontSize: fuenteTituloGrande,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1F2937),
    letterSpacing: -0.5,
  );
  
  static const TextStyle estiloTitulo = TextStyle(
    fontSize: fuenteTitulo,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1F2937),
  );
  
  static const TextStyle estiloSubtitulo = TextStyle(
    fontSize: fuenteSubtitulo,
    fontWeight: FontWeight.w600,
    color: Color(0xFF374151),
  );
  
  static const TextStyle estiloTextoGrande = TextStyle(
    fontSize: fuenteTextoGrande,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );
  
  static const TextStyle estiloTextoNormal = TextStyle(
    fontSize: fuenteTextoNormal,
    color: Color(0xFF1F2937),
  );
  
  static const TextStyle estiloTextoMedio = TextStyle(
    fontSize: fuenteTextoMedio,
    color: Color(0xFF374151),
  );
  
  static const TextStyle estiloTextoSecundario = TextStyle(
    fontSize: fuenteTextoMedio,
    color: Color(0xFF6B7280),
  );
  
  static const TextStyle estiloTextoPequeno = TextStyle(
    fontSize: fuenteTextoPequeno,
    color: Color(0xFF9CA3AF),
  );
  
  // 🏷️ ETIQUETAS Y TEXTOS POR ESTADO
  
  static const Map<String, String> etiquetasEstado = {
    'pending': 'Pendiente',
    'confirmed': 'Confirmada',
    'inProgress': 'En Progreso',
    'completed': 'Completada',
    'cancelled': 'Cancelada',
  };
  
  static const Map<String, String> etiquetasEstadoProveedor = {
    'pending': 'Por confirmar',
    'confirmed': 'Próxima cita',
    'inProgress': 'En servicio',
    'completed': 'Servicio realizado',
    'cancelled': 'Rechazada',
  };
  
  static const Map<String, String> etiquetasEstadoCliente = {
    'pending': 'En espera',
    'confirmed': 'Confirmada',
    'inProgress': 'En proceso',
    'completed': 'Completada',
    'cancelled': 'Cancelada',
  };
  
  // 🎯 ICONOS POR ESTADO Y TIPO
  
  static const Map<String, IconData> iconosEstado = {
    'pending': Icons.schedule_rounded,
    'confirmed': Icons.check_circle_rounded,
    'inProgress': Icons.play_circle_rounded,
    'completed': Icons.task_alt_rounded,
    'cancelled': Icons.cancel_rounded,
  };
  
  static const Map<String, IconData> iconosAcciones = {
    'confirmar': Icons.check_circle,
    'rechazar': Icons.cancel,
    'completar': Icons.task_alt,
    'cancelar': Icons.close,
    'calificar': Icons.star,
    'ver_detalle': Icons.visibility,
    'editar': Icons.edit,
  };
  
  static const Map<String, IconData> iconosUsuario = {
    'provider': Icons.business_center,
    'client': Icons.person,
    'admin': Icons.admin_panel_settings,
  };
  
  static const Map<String, IconData> iconosNavegacion = {
    'home': Icons.home,
    'search': Icons.search,
    'bookings': Icons.calendar_today,
    'profile': Icons.person,
    'settings': Icons.settings,
    'notifications': Icons.notifications,
  };
  
  // 💬 MENSAJES PREDEFINIDOS
  
  static const Map<String, String> mensajesVacio = {
    'provider_all': 'Sin reservas registradas',
    'provider_pending': 'Sin reservas pendientes',
    'provider_confirmed': 'Sin reservas confirmadas',
    'provider_completed': 'Sin servicios completados',
    'provider_cancelled': 'Sin reservas canceladas',
    'client_all': 'No tienes reservas',
    'client_pending': 'No hay reservas pendientes',
    'client_confirmed': 'No hay reservas confirmadas',
    'client_completed': 'No hay servicios completados',
    'client_cancelled': 'No hay reservas canceladas',
  };
  
  static const Map<String, String> mensajesExito = {
    'reserva_confirmada': '✅ Reserva confirmada exitosamente',
    'reserva_cancelada': '🚫 Reserva cancelada',
    'servicio_completado': '✔️ Servicio marcado como completado',
    'calificacion_enviada': '⭐ Calificación enviada',
    'datos_actualizados': '🔄 Datos actualizados',
  };
  
  static const Map<String, String> mensajesError = {
    'error_conexion': 'Error de conexión. Verifica tu internet.',
    'error_servidor': 'Error en el servidor. Intenta más tarde.',
    'error_permisos': 'No tienes permisos para esta acción.',
    'error_datos': 'Error al procesar los datos.',
    'error_generico': 'Algo salió mal. Intenta nuevamente.',
  };
  
  // 🎮 CONFIGURACIONES DE ANIMACIONES
  
  static const Curve curvaEaseOut = Curves.easeOut;
  static const Curve curvaEaseIn = Curves.easeIn;
  static const Curve curvaEaseInOut = Curves.easeInOut;
  static const Curve curvaBounce = Curves.bounceOut;
  static const Curve curvaElastic = Curves.elasticOut;
  
  // 📊 CONFIGURACIONES DE DASHBOARD
  
  static const int maxItemsGrid = 4;
  static const double aspectRatioTarjetaEstadistica = 2.0;
  static const int maxReservasRecientes = 5;
  
  // 🔧 MÉTODOS AUXILIARES ESTÁTICOS
  
  /// Obtiene el gradiente según el tipo de usuario
  static List<Color> obtenerGradienteUsuario(bool esProveedor) {
    return esProveedor ? gradienteProveedor : gradienteCliente;
  }
  
  /// Obtiene el color primario según el tipo de usuario
  static Color obtenerColorPrimario(bool esProveedor) {
    return esProveedor ? colorProveedorPrimario : colorClientePrimario;
  }
  
  /// Obtiene el color según el estado de la reserva
  static Color obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pending':
        return colorPendiente;
      case 'confirmed':
        return colorConfirmada;
      case 'inprogress':
        return colorEnProgreso;
      case 'completed':
        return colorCompletada;
      case 'cancelled':
        return colorCancelada;
      default:
        return colorInfo;
    }
  }
  
  /// Obtiene el ícono según el estado
  static IconData obtenerIconoEstado(String estado) {
    return iconosEstado[estado.toLowerCase()] ?? Icons.help_outline;
  }
  
  /// Obtiene la etiqueta del estado según el tipo de usuario
  static String obtenerEtiquetaEstado(String estado, bool esProveedor) {
    final estadoLower = estado.toLowerCase();
    if (esProveedor) {
      return etiquetasEstadoProveedor[estadoLower] ?? estado;
    } else {
      return etiquetasEstadoCliente[estadoLower] ?? estado;
    }
  }
  
  /// Obtiene el mensaje de estado vacío
  static String obtenerMensajeVacio(String filtro, bool esProveedor) {
    final tipo = esProveedor ? 'provider' : 'client';
    final clave = '${tipo}_$filtro';
    return mensajesVacio[clave] ?? 'Sin elementos para mostrar';
  }
  
  /// Obtiene el estilo de texto según el tipo
  static TextStyle obtenerEstiloTexto(String tipo) {
    switch (tipo) {
      case 'titulo_grande':
        return estiloTituloGrande;
      case 'titulo':
        return estiloTitulo;
      case 'subtitulo':
        return estiloSubtitulo;
      case 'normal':
        return estiloTextoNormal;
      case 'secundario':
        return estiloTextoSecundario;
      case 'pequeno':
        return estiloTextoPequeno;
      default:
        return estiloTextoNormal;
    }
  }
  
  /// Crea un gradiente con transparencia
  static LinearGradient crearGradienteConTransparencia(
    List<Color> colores, 
    double opacidad,
  ) {
    return LinearGradient(
      colors: colores.map((color) => color.withValues(alpha: opacidad)).toList(),
    );
  }
  
  /// Obtiene sombra con color personalizado
  static List<BoxShadow> obtenerSombraPersonalizada(
    Color color, 
    double blur, 
    Offset offset,
  ) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.2),
        blurRadius: blur,
        offset: offset,
      ),
    ];
  }
  
  /// Valida si un color es oscuro
  static bool esColorOscuro(Color color) {
    return color.computeLuminance() < 0.5;
  }
  
  /// Obtiene color de texto contrastante
  static Color obtenerColorTextoContrastante(Color colorFondo) {
    return esColorOscuro(colorFondo) ? Colors.white : Colors.black;
  }
}