// lib/caracteristicas/servicios_proveedor/utilidades/ayudantes_servicio.dart

import 'package:intl/intl.dart';

class AyudantesServicio {
  // Formatear fecha
  static String formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }

  // Formatear fecha completa
  static String formatearFechaCompleta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  // Formatear precio
  static String formatearPrecio(double precio) {
    final formato = NumberFormat.currency(
      locale: 'es_EC',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formato.format(precio);
  }

  // Formatear precio con decimales
  static String formatearPrecioConDecimales(double precio) {
    final formato = NumberFormat.currency(
      locale: 'es_EC',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formato.format(precio);
  }

  // Obtener nombre de categoría
  static String obtenerNombreCategoria(String categoria) {
    final categorias = {
      'plomeria': 'Plomería',
      'electricidad': 'Electricidad',
      'carpinteria': 'Carpintería',
      'pintura': 'Pintura',
      'jardineria': 'Jardinería',
      'limpieza': 'Limpieza',
      'cocina': 'Cocina',
      'mecanica': 'Mecánica',
      'tecnologia': 'Tecnología',
      'otros': 'Otros',
    };
    return categorias[categoria] ?? 'Sin categoría';
  }

  // Obtener todas las categorías disponibles
  static List<Map<String, String>> obtenerCategorias() {
    return [
      {'valor': 'plomeria', 'nombre': 'Plomería'},
      {'valor': 'electricidad', 'nombre': 'Electricidad'},
      {'valor': 'carpinteria', 'nombre': 'Carpintería'},
      {'valor': 'pintura', 'nombre': 'Pintura'},
      {'valor': 'jardineria', 'nombre': 'Jardinería'},
      {'valor': 'limpieza', 'nombre': 'Limpieza'},
      {'valor': 'cocina', 'nombre': 'Cocina'},
      {'valor': 'mecanica', 'nombre': 'Mecánica'},
      {'valor': 'tecnologia', 'nombre': 'Tecnología'},
      {'valor': 'otros', 'nombre': 'Otros'},
    ];
  }

  // Formatear calificación
  static String formatearCalificacion(double calificacion) {
    return calificacion.toStringAsFixed(1);
  }

  // Obtener texto de calificación
  static String obtenerTextoCalificacion(double calificacion) {
    if (calificacion >= 4.5) return 'Excelente';
    if (calificacion >= 4.0) return 'Muy bueno';
    if (calificacion >= 3.5) return 'Bueno';
    if (calificacion >= 3.0) return 'Regular';
    return 'Necesita mejorar';
  }

  // Validar texto
  static String? validarTextoRequerido(String? texto, String nombreCampo) {
    if (texto == null || texto.trim().isEmpty) {
      return '$nombreCampo es requerido';
    }
    return null;
  }

  // Validar longitud de texto
  static String? validarLongitudTexto(
    String? texto, 
    String nombreCampo, 
    int minimo, 
    int maximo,
  ) {
    if (texto == null || texto.trim().isEmpty) {
      return '$nombreCampo es requerido';
    }
    
    final longitud = texto.trim().length;
    if (longitud < minimo) {
      return '$nombreCampo debe tener al menos $minimo caracteres';
    }
    if (longitud > maximo) {
      return '$nombreCampo no puede exceder $maximo caracteres';
    }
    return null;
  }

  // Validar precio
  static String? validarPrecio(String? precio) {
    if (precio == null || precio.trim().isEmpty) {
      return 'El precio es requerido';
    }

    final precioDouble = double.tryParse(precio.trim());
    if (precioDouble == null) {
      return 'Ingrese un precio válido';
    }

    if (precioDouble <= 0) {
      return 'El precio debe ser mayor a 0';
    }

    if (precioDouble > 10000) {
      return 'El precio no puede exceder \$10,000';
    }

    return null;
  }

  // Obtener color por calificación
  static int obtenerColorPorCalificacion(double calificacion) {
    if (calificacion >= 4.5) return 0xFF4CAF50; // Verde
    if (calificacion >= 4.0) return 0xFF8BC34A; // Verde claro
    if (calificacion >= 3.5) return 0xFFFF9800; // Naranja
    if (calificacion >= 3.0) return 0xFFFF5722; // Naranja oscuro
    return 0xFFF44336; // Rojo
  }

  // Truncar texto
  static String truncarTexto(String texto, int maxCaracteres) {
    if (texto.length <= maxCaracteres) return texto;
    return '${texto.substring(0, maxCaracteres)}...';
  }

  // Capitalizar primera letra
  static String capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  // Generar mensaje de estado del servicio
  static String obtenerMensajeEstado(bool estaActivo) {
    return estaActivo ? 'Servicio visible para clientes' : 'Servicio no visible para clientes';
  }

  // Obtener duración desde fecha
static String obtenerDuracionDesde(DateTime fecha) {
  final diferencia = DateTime.now().difference(fecha);

  if (diferencia.inDays >= 365) {
    final anios = (diferencia.inDays / 365).floor();
    return '$anios año${anios > 1 ? 's' : ''}';
  } else if (diferencia.inDays >= 30) {
    final meses = (diferencia.inDays / 30).floor();
    return '$meses mes${meses > 1 ? 'es' : ''}';
  } else if (diferencia.inDays > 0) {
    return '${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
  } else if (diferencia.inHours > 0) {
    return '${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
  } else {
    return 'Hace poco';
  }
}

  // Validar que la categoría sea válida
  static bool esCategoriaValida(String categoria) {
    final categoriasValidas = obtenerCategorias().map((c) => c['valor']).toList();
    return categoriasValidas.contains(categoria);
  }

  // Obtener sugerencias de precio por categoría
  static Map<String, double> obtenerSugerenciasPrecio() {
    return {
      'plomeria': 25.0,
      'electricidad': 30.0,
      'carpinteria': 20.0,
      'pintura': 15.0,
      'jardineria': 12.0,
      'limpieza': 10.0,
      'cocina': 35.0,
      'mecanica': 40.0,
      'tecnologia': 50.0,
      'otros': 20.0,
    };
  }

  // Obtener precio sugerido por categoría
  static double obtenerPrecioSugerido(String categoria) {
    final sugerencias = obtenerSugerenciasPrecio();
    return sugerencias[categoria] ?? 20.0;
  }
}