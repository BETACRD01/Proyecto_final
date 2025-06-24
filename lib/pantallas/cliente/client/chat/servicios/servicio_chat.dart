// lib/pantallas/chat/servicios/servicio_chat.dart

import '../modelos/modelo_conversacion.dart';
import 'package:flutter/material.dart';

class ServicioChat {
  
  // 🔗 DATOS SIMULADOS - Reemplazar con datos reales del backend
  static List<ModeloConversacion> _conversacionesSimuladas = [
    ModeloConversacion(
      id: '1',
      nombreProveedor: 'Carlos Rodríguez',
      nombreServicio: 'Limpieza Profunda',
      ultimoMensaje: 'Perfecto, nos vemos mañana a las 9 AM',
      fechaHora: DateTime.now().subtract(const Duration(minutes: 15)),
      mensajesNoLeidos: 2,
      estaEnLinea: true,
      avatar: Icons.cleaning_services_rounded,
      colorCategoria: const Color(0xFF10B981),
    ),
    ModeloConversacion(
      id: '2',
      nombreProveedor: 'Ana López',
      nombreServicio: 'Plomería Residencial',
      ultimoMensaje: 'Ya terminé la reparación del grifo',
      fechaHora: DateTime.now().subtract(const Duration(hours: 2)),
      mensajesNoLeidos: 0,
      estaEnLinea: true,
      avatar: Icons.plumbing_rounded,
      colorCategoria: const Color(0xFF3B82F6),
    ),
    ModeloConversacion(
      id: '3',
      nombreProveedor: 'Miguel Torres',
      nombreServicio: 'Electricidad',
      ultimoMensaje: 'Necesito confirmar la hora de la cita',
      fechaHora: DateTime.now().subtract(const Duration(hours: 5)),
      mensajesNoLeidos: 1,
      estaEnLinea: false,
      avatar: Icons.electrical_services_rounded,
      colorCategoria: const Color(0xFFF59E0B),
    ),
  ];

  // 🔗 LISTO PARA CONECTAR: Obtener todas las conversaciones
  static Future<List<ModeloConversacion>> obtenerConversaciones() async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.get(Uri.parse('$urlBase/conversaciones'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> datos = json.decode(response.body);
      //   return datos.map((json) => ModeloConversacion.fromJson(json)).toList();
      // }

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      return _conversacionesSimuladas;
    } catch (e) {
      throw Exception('Error al cargar conversaciones: $e');
    }
  }

  // 🔗 LISTO PARA CONECTAR: Marcar conversación como leída
  static Future<bool> marcarComoLeido(String idConversacion) async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.put(
      //   Uri.parse('$urlBase/conversaciones/$idConversacion/leido'),
      // );
      // return response.statusCode == 200;

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      final indice = _conversacionesSimuladas.indexWhere((c) => c.id == idConversacion);
      if (indice != -1) {
        _conversacionesSimuladas[indice] = _conversacionesSimuladas[indice].marcarComoLeido();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al marcar como leído: $e');
    }
  }

  // 🔗 LISTO PARA CONECTAR: Marcar conversación como no leída
  static Future<bool> marcarComoNoLeido(String idConversacion) async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.put(
      //   Uri.parse('$urlBase/conversaciones/$idConversacion/no-leido'),
      // );
      // return response.statusCode == 200;

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      final indice = _conversacionesSimuladas.indexWhere((c) => c.id == idConversacion);
      if (indice != -1) {
        _conversacionesSimuladas[indice] = _conversacionesSimuladas[indice].marcarComoNoLeido();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al marcar como no leído: $e');
    }
  }

  // 🔗 LISTO PARA CONECTAR: Eliminar conversación
  static Future<bool> eliminarConversacion(String idConversacion) async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.delete(
      //   Uri.parse('$urlBase/conversaciones/$idConversacion'),
      // );
      // return response.statusCode == 200;

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      
      _conversacionesSimuladas.removeWhere((c) => c.id == idConversacion);
      return true;
    } catch (e) {
      throw Exception('Error al eliminar conversación: $e');
    }
  }

  // 🔗 LISTO PARA CONECTAR: Bloquear contacto
  static Future<bool> bloquearContacto(String idConversacion) async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.post(
      //   Uri.parse('$urlBase/conversaciones/$idConversacion/bloquear'),
      // );
      // return response.statusCode == 200;

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Error al bloquear contacto: $e');
    }
  }

  // 🔗 LISTO PARA CONECTAR: Buscar conversaciones
  static Future<List<ModeloConversacion>> buscarConversaciones(String consulta) async {
    try {
      // TODO: Reemplazar con llamada real a la API
      // final response = await http.get(
      //   Uri.parse('$urlBase/conversaciones/buscar?q=$consulta'),
      // );

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 600));
      
      final conversacionesFiltradas = _conversacionesSimuladas.where((conversacion) =>
        conversacion.nombreProveedor.toLowerCase().contains(consulta.toLowerCase()) ||
        conversacion.nombreServicio.toLowerCase().contains(consulta.toLowerCase()) ||
        conversacion.ultimoMensaje.toLowerCase().contains(consulta.toLowerCase())
      ).toList();
      
      return conversacionesFiltradas;
    } catch (e) {
      throw Exception('Error en la búsqueda: $e');
    }
  }
}