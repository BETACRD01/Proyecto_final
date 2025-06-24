// lib/caracteristicas/servicios_proveedor/widgets/tarjeta_servicio.dart

import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import '../modelos/modelo_servicio.dart';
import '../utilidades/ayudantes_servicio.dart';
import 'item_estadisticas_servicio.dart';

class TarjetaServicio extends StatelessWidget {
  final ModeloServicio servicio;
  final Function(String) onEditar;
  final Function(String, bool) onCambiarEstado;
  final Function(String) onEliminar;

  const TarjetaServicio({
    Key? key,
    required this.servicio,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: servicio.estaActivo
            ? Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1)
            : Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildDescripcion(),
            const SizedBox(height: 12),
            _buildCategoriaYPrecio(),
            const SizedBox(height: 12),
            _buildEstadisticas(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            servicio.nombre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildBadgeEstado(),
        _buildMenuOpciones(),
      ],
    );
  }

  Widget _buildBadgeEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: servicio.estaActivo
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: servicio.estaActivo ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            servicio.estaActivo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: servicio.estaActivo ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOpciones() {
    return PopupMenuButton<String>(
      onSelected: (valor) => _manejarAccionMenu(valor),
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: servicio.estaActivo ? 'desactivar' : 'activar',
          child: Row(
            children: [
              Icon(
                servicio.estaActivo ? Icons.visibility_off : Icons.visibility,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(servicio.estaActivo ? 'Desactivar' : 'Activar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: AppColors.error),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescripcion() {
    return Text(
      servicio.descripcion,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoriaYPrecio() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AyudantesServicio.obtenerNombreCategoria(servicio.categoria),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AyudantesServicio.formatearPrecio(servicio.precioPorHora),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'por hora',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadisticas() {
    return Row(
      children: [
        ItemCalificacionServicio(
          calificacion: servicio.calificacion,
          totalCalificaciones: servicio.totalCalificaciones,
        ),
        const SizedBox(width: 16),
        ItemEstadisticasServicio(
          icono: Icons.access_time,
          texto: 'Creado ${AyudantesServicio.obtenerDuracionDesde(servicio.fechaCreacion)}',
        ),
        const Spacer(),
        if (!servicio.estaActivo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No visible',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _manejarAccionMenu(String accion) {
    switch (accion) {
      case 'editar':
        onEditar(servicio.id);
        break;
      case 'activar':
      case 'desactivar':
        onCambiarEstado(servicio.id, !servicio.estaActivo);
        break;
      case 'eliminar':
        onEliminar(servicio.id);
        break;
    }
  }
}