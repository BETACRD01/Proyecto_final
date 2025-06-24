// lib/pantallas/chat/modelos/modelo_conversacion.dart

import 'package:flutter/material.dart';

class ModeloConversacion {
  final String id;
  final String nombreProveedor;
  final String nombreServicio;
  final String ultimoMensaje;
  final DateTime fechaHora;
  final int mensajesNoLeidos;
  final bool estaEnLinea;
  final IconData avatar;
  final Color colorCategoria;

  ModeloConversacion({
    required this.id,
    required this.nombreProveedor,
    required this.nombreServicio,
    required this.ultimoMensaje,
    required this.fechaHora,
    required this.mensajesNoLeidos,
    required this.estaEnLinea,
    required this.avatar,
    required this.colorCategoria,
  });

  // Método para convertir desde Map (cuando viene del backend)
  factory ModeloConversacion.fromJson(Map<String, dynamic> json) {
    return ModeloConversacion(
      id: json['id'] ?? '',
      nombreProveedor: json['nombreProveedor'] ?? '',
      nombreServicio: json['nombreServicio'] ?? '',
      ultimoMensaje: json['ultimoMensaje'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora'] ?? DateTime.now().toIso8601String()),
      mensajesNoLeidos: json['mensajesNoLeidos'] ?? 0,
      estaEnLinea: json['estaEnLinea'] ?? false,
      avatar: _obtenerIconoDesdeCadena(json['avatar']),
      colorCategoria: Color(json['colorCategoria'] ?? 0xFF6366F1),
    );
  }

  // Método para convertir a Map (cuando se envía al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreProveedor': nombreProveedor,
      'nombreServicio': nombreServicio,
      'ultimoMensaje': ultimoMensaje,
      'fechaHora': fechaHora.toIso8601String(),
      'mensajesNoLeidos': mensajesNoLeidos,
      'estaEnLinea': estaEnLinea,
      'avatar': _obtenerCadenaDesdeIcono(avatar),
      'colorCategoria': colorCategoria.value,
    };
  }

  // Crear copia con cambios
  ModeloConversacion copiarCon({
    String? id,
    String? nombreProveedor,
    String? nombreServicio,
    String? ultimoMensaje,
    DateTime? fechaHora,
    int? mensajesNoLeidos,
    bool? estaEnLinea,
    IconData? avatar,
    Color? colorCategoria,
  }) {
    return ModeloConversacion(
      id: id ?? this.id,
      nombreProveedor: nombreProveedor ?? this.nombreProveedor,
      nombreServicio: nombreServicio ?? this.nombreServicio,
      ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
      fechaHora: fechaHora ?? this.fechaHora,
      mensajesNoLeidos: mensajesNoLeidos ?? this.mensajesNoLeidos,
      estaEnLinea: estaEnLinea ?? this.estaEnLinea,
      avatar: avatar ?? this.avatar,
      colorCategoria: colorCategoria ?? this.colorCategoria,
    );
  }

  // Método para marcar como leído
  ModeloConversacion marcarComoLeido() {
    return copiarCon(mensajesNoLeidos: 0);
  }

  // Método para marcar como no leído
  ModeloConversacion marcarComoNoLeido() {
    return copiarCon(mensajesNoLeidos: 1);
  }

  // Helper methods para iconos
  static IconData _obtenerIconoDesdeCadena(String? nombreIcono) {
    switch (nombreIcono) {
      case 'servicios_limpieza':
        return Icons.cleaning_services_rounded;
      case 'plomeria':
        return Icons.plumbing_rounded;
      case 'servicios_electricos':
        return Icons.electrical_services_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  static String _obtenerCadenaDesdeIcono(IconData icono) {
    if (icono == Icons.cleaning_services_rounded) return 'servicios_limpieza';
    if (icono == Icons.plumbing_rounded) return 'plomeria';
    if (icono == Icons.electrical_services_rounded) return 'servicios_electricos';
    return 'persona';
  }
}