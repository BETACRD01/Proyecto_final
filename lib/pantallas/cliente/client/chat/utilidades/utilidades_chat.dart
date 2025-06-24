// lib/pantallas/chat/utilidades/utilidades_chat.dart

class UtilidadesChat {
  
  /// Formatea el timestamp para mostrar en la lista de conversaciones
  static String formatearTiempo(DateTime fechaHora) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaHora);

    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inMinutes < 60) {
      return '${diferencia.inMinutes}m';
    } else if (diferencia.inHours < 24) {
      return '${diferencia.inHours}h';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays}d';
    } else {
      return '${fechaHora.day}/${fechaHora.month}';
    }
  }

  /// Formatea el timestamp completo para mostrar en chat individual
  static String formatearTiempoCompleto(DateTime fechaHora) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaMensaje = DateTime(fechaHora.year, fechaHora.month, fechaHora.day);
    
    if (fechaMensaje == hoy) {
      return 'Hoy ${_formatearHora(fechaHora)}';
    } else if (fechaMensaje == hoy.subtract(const Duration(days: 1))) {
      return 'Ayer ${_formatearHora(fechaHora)}';
    } else if (ahora.difference(fechaMensaje).inDays < 7) {
      return '${_obtenerDiaSemana(fechaHora.weekday)} ${_formatearHora(fechaHora)}';
    } else {
      return '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${_formatearHora(fechaHora)}';
    }
  }

  /// Formatea solo la hora
  static String _formatearHora(DateTime tiempo) {
    final hora = tiempo.hour.toString().padLeft(2, '0');
    final minuto = tiempo.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Obtiene el nombre del día de la semana
  static String _obtenerDiaSemana(int diaSemana) {
    const diasSemana = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 
      'Viernes', 'Sábado', 'Domingo'
    ];
    return diasSemana[diaSemana - 1];
  }

  /// Trunca texto largo para vista previa
  static String truncarMensaje(String mensaje, {int longitudMaxima = 100}) {
    if (mensaje.length <= longitudMaxima) return mensaje;
    return '${mensaje.substring(0, longitudMaxima)}...';
  }

  /// Valida si un string es un ID válido
  static bool esIdValido(String? id) {
    return id != null && id.isNotEmpty && id.trim().isNotEmpty;
  }

  /// Obtiene el texto de estado basado en si está online
  static String obtenerTextoEstado(bool estaEnLinea) {
    return estaEnLinea ? 'En línea' : 'Desconectado';
  }

  /// Calcula el total de mensajes no leídos
  static int obtenerTotalNoLeidos(List<dynamic> conversaciones) {
    return conversaciones
        .where((c) => c['mensajesNoLeidos'] != null)
        .fold<int>(0, (suma, c) => suma + (c['mensajesNoLeidos'] as int));
  }

  /// Genera un mensaje de estado para mostrar en subtítulo
  static String obtenerMensajeEstado(int conteoNoLeidos) {
    if (conteoNoLeidos == 0) {
      return 'Todas las conversaciones al día';
    } else if (conteoNoLeidos == 1) {
      return '1 conversación pendiente';
    } else {
      return '$conteoNoLeidos conversaciones pendientes';
    }
  }

  /// Valida formato de búsqueda
  static String limpiarConsultaBusqueda(String consulta) {
    return consulta.trim().toLowerCase();
  }

  /// Genera colores aleatorios para avatares cuando no hay imagen
  static int generarColorDesdeCadena(String texto) {
    int hash = 0;
    for (int i = 0; i < texto.length; i++) {
      hash = texto.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final colores = [
      0xFF10B981, // Verde
      0xFF3B82F6, // Azul
      0xFFF59E0B, // Amarillo
      0xFFEF4444, // Rojo
      0xFF8B5CF6, // Púrpura
      0xFFEC4899, // Rosa
      0xFF06B6D4, // Cian
      0xFFF97316, // Naranja
    ];
    
    return colores[hash.abs() % colores.length];
  }

  /// Formatea número de mensajes no leídos para mostrar
  static String formatearConteoNoLeidos(int conteo) {
    if (conteo > 99) return '99+';
    return conteo.toString();
  }

  /// Sanitiza texto para evitar caracteres problemáticos
  static String sanitizarTexto(String texto) {
    return texto
        .replaceAll(RegExp(r'[^\w\s\-.,!?¿¡áéíóúñüÁÉÍÓÚÑÜ]'), '')
        .trim();
  }

  /// Valida formato de email
  static bool esEmailValido(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Convierte primera letra a mayúscula
  static String capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }
}