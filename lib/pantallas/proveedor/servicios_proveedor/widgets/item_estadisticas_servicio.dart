// lib/caracteristicas/servicios_proveedor/widgets/item_estadisticas_servicio.dart

import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/colores_app.dart';

class ItemEstadisticasServicio extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color? colorIcono;
  final Color? colorTexto;

  const ItemEstadisticasServicio({
    Key? key,
    required this.icono,
    required this.texto,
    this.colorIcono,
    this.colorTexto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          size: 16,
          color: colorIcono ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: colorTexto ?? AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget especializado para calificación con estrellas
class ItemCalificacionServicio extends StatelessWidget {
  final double calificacion;
  final int totalCalificaciones;

  const ItemCalificacionServicio({
    Key? key,
    required this.calificacion,
    required this.totalCalificaciones,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: _obtenerColorCalificacion(calificacion),
        ),
        const SizedBox(width: 4),
        Text(
          calificacion.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: _obtenerColorCalificacion(calificacion),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($totalCalificaciones)',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Color _obtenerColorCalificacion(double calificacion) {
    if (calificacion >= 4.5) return AppColors.success;
    if (calificacion >= 4.0) return const Color(0xFF8BC34A);
    if (calificacion >= 3.5) return AppColors.warning;
    if (calificacion >= 3.0) return const Color(0xFFFF5722);
    return AppColors.error;
  }
}