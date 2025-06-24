// nucleo/utilidades/utilidades_servicios.dart
import 'package:flutter/material.dart';
import '../../../../../modelos/modelo_servicio.dart'; // Tu ServiceModel

class UtilidadesServicios {
  // Obtener icono según la categoría del servicio
  static IconData obtenerIconoPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cleaning':
      case 'limpieza':
        return Icons.cleaning_services;
      case 'plumbing':
      case 'plomería':
      case 'fontanería':
        return Icons.plumbing;
      case 'electrical':
      case 'electricidad':
      case 'eléctrico':
        return Icons.electrical_services;
      case 'carpentry':
      case 'carpintería':
      case 'madera':
        return Icons.handyman;
      case 'beauty':
      case 'belleza':
      case 'estética':
        return Icons.face;
      case 'maintenance':
      case 'mantenimiento':
        return Icons.build;
      case 'gardening':
      case 'jardinería':
        return Icons.grass;
      case 'painting':
      case 'pintura':
        return Icons.format_paint;
      case 'security':
      case 'seguridad':
        return Icons.security;
      case 'delivery':
      case 'entrega':
      case 'envío':
        return Icons.local_shipping;
      case 'tutoring':
      case 'tutoría':
      case 'enseñanza':
        return Icons.school;
      case 'health':
      case 'salud':
      case 'médico':
        return Icons.medical_services;
      case 'automotive':
      case 'automotriz':
      case 'mecánico':
        return Icons.car_repair;
      case 'technology':
      case 'tecnología':
      case 'informática':
        return Icons.computer;
      case 'food':
      case 'comida':
      case 'catering':
        return Icons.restaurant;
      case 'fitness':
      case 'ejercicio':
      case 'deporte':
        return Icons.fitness_center;
      default:
        return Icons.build; // Icono por defecto
    }
  }

  // Obtener precio del servicio adaptado a tu ServiceModel
  static String obtenerPrecioServicio(ServiceModel servicio) {
    try {
      // Convertir servicio a mapa para buscar campos de precio
      final mapaServicio = servicio.toMap();
      
      // Lista de posibles campos de precio (en orden de prioridad)
      final camposPrecio = [
        'price',
        'basePrice', 
        'cost',
        'amount',
        'fee',
        'precio',
        'costo',
        'tarifa',
        'valor'
      ];
      
      // Buscar precio en los campos posibles
      for (String campo in camposPrecio) {
        if (mapaServicio.containsKey(campo) && mapaServicio[campo] != null) {
          final precio = mapaServicio[campo];
          
          if (precio is num) {
            return precio.toStringAsFixed(0);
          } else if (precio is String) {
            // Intentar parsear string a número
            final valorParseado = double.tryParse(precio.replaceAll(',', '.'));
            if (valorParseado != null) {
              return valorParseado.toStringAsFixed(0);
            }
          }
        }
      }
      
      // Si no se encuentra precio, retornar texto por defecto
      return 'Consultar';
    } catch (e) {
      print('Error obteniendo precio del servicio: $e');
      return 'N/A';
    }
  }

  // Validar si un servicio está disponible
  static bool estaDisponible(ServiceModel servicio) {
    return servicio.isActive;
  }

  // Obtener color de estado según disponibilidad
  static Color obtenerColorEstado(bool estaActivo) {
    return estaActivo 
        ? const Color(0xFF388E3C) // Verde éxito (AppColors.success)
        : const Color(0xFFD32F2F); // Rojo error (AppColors.error)
  }

  // Formatear calificación para mostrar
  static String formatearCalificacion(double calificacion) {
    if (calificacion == 0) return '0.0';
    return calificacion.toStringAsFixed(1);
  }


  // Obtener nombre del proveedor (adaptado a tu modelo)
  static String obtenerNombreProveedor(ServiceModel servicio) {
    try {
      // Verificar campos posibles para el nombre del proveedor
      final mapa = servicio.toMap();
      
      // Lista de campos posibles para el nombre del proveedor
      final camposProveedor = [
        'providerName',
        'provider_name', 
        'nombreProveedor',
        'nombre_proveedor',
        'businessName',
        'companyName',
        'name' // Último recurso
      ];
      
      // Buscar nombre del proveedor
      for (String campo in camposProveedor) {
        if (mapa.containsKey(campo) && 
            mapa[campo] != null && 
            mapa[campo].toString().isNotEmpty) {
          return mapa[campo].toString();
        }
      }
      
      // Si no se encuentra, usar el name del servicio o valor por defecto
      if (servicio.name.isNotEmpty) {
        return servicio.name;
      }
      
      return 'Proveedor';
    } catch (e) {
      print('Error obteniendo nombre del proveedor: $e');
      return 'Proveedor';
    }
  }

  // Obtener descripción corta del servicio
  static String obtenerDescripcionCorta(ServiceModel servicio, {int maxLength = 50}) {
    if (servicio.description.length <= maxLength) {
      return servicio.description;
    }
    return '${servicio.description.substring(0, maxLength)}...';
  }

  // Obtener texto de disponibilidad
  static String obtenerTextoDisponibilidad(ServiceModel servicio) {
    return servicio.isActive ? 'Disponible' : 'No disponible';
  }

  // Validar si el servicio tiene imagen
  static bool tieneImagen(ServiceModel servicio) {
    try {
      final mapa = servicio.toMap();
      final camposImagen = ['image', 'imageUrl', 'photo', 'picture'];
      
      for (String campo in camposImagen) {
        if (mapa.containsKey(campo) && 
            mapa[campo] != null && 
            mapa[campo].toString().isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener URL de imagen del servicio
  static String? obtenerImagenServicio(ServiceModel servicio) {
    try {
      final mapa = servicio.toMap();
      final camposImagen = ['image', 'imageUrl', 'photo', 'picture'];
      
      for (String campo in camposImagen) {
        if (mapa.containsKey(campo) && 
            mapa[campo] != null && 
            mapa[campo].toString().isNotEmpty) {
          return mapa[campo].toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener etiquetas del servicio
  static List<String> obtenerEtiquetas(ServiceModel servicio) {
    try {
      final mapa = servicio.toMap();
      
      if (mapa.containsKey('tags') && mapa['tags'] is List) {
        return List<String>.from(mapa['tags']);
      }
      
      // Si no hay tags, crear etiquetas basadas en la categoría
      return [servicio.category.toString()];
    } catch (e) {
      return [servicio.category.toString()];
    }
  }

  // Formatear duración del servicio
  static String formatearDuracion(ServiceModel servicio) {
    try {
      final mapa = servicio.toMap();
      final camposDuracion = ['duration', 'time', 'duracion', 'tiempo'];
      
      for (String campo in camposDuracion) {
        if (mapa.containsKey(campo) && mapa[campo] != null) {
          final duracion = mapa[campo];
          if (duracion is num) {
            return '${duracion.toInt()} min';
          } else if (duracion is String) {
            return duracion;
          }
        }
      }
      
      return 'No especificado';
    } catch (e) {
      return 'No especificado';
    }
  }

  // Obtener nivel de experiencia del proveedor
  static String obtenerNivelExperiencia(ServiceModel servicio) {
    try {
      final mapa = servicio.toMap();
      
      if (mapa.containsKey('experience') && mapa['experience'] != null) {
        final exp = mapa['experience'];
        if (exp is num) {
          if (exp >= 5) return 'Experto';
          if (exp >= 2) return 'Intermedio';
          return 'Principiante';
        }
      }
      
      // Basado en calificación como alternativa
      if (servicio.rating >= 4.5) return 'Experto';
      if (servicio.rating >= 3.5) return 'Intermedio';
      return 'Principiante';
    } catch (e) {
      return 'No especificado';
    }
  }
}