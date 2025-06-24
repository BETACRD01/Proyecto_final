import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../proveedor/servicios_proveedor/proveedores/proveedor_servicios.dart';
import '../../../proveedor/servicios_proveedor/modelos/modelo_servicio.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import 'widget_cargando.dart';
import 'tarjeta_vacia.dart';

class SeccionServiciosRecientes extends StatelessWidget {
  const SeccionServiciosRecientes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Servicios Recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ProveedorServicio>(
            builder: (context, proveedorServicio, child) {
              if (proveedorServicio.estaCargando) {
                return const WidgetCargando();
              }

              if (proveedorServicio.servicios.isEmpty) {
                return const TarjetaVacia(mensaje: 'No hay servicios recientes');
              }

              final serviciosRecientes = proveedorServicio.servicios.take(3).toList();

              return Column(
                children: serviciosRecientes
                    .asMap()
                    .entries
                    .map((entrada) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: TarjetaServicioReciente(
                            servicio: entrada.value,
                            onTap: () => _onTapServicio(context, entrada.value),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onTapServicio(BuildContext context, ModeloServicio servicio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de: ${servicio.nombre}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// Widget simplificado para servicios recientes
class TarjetaServicioReciente extends StatelessWidget {
  final ModeloServicio servicio;
  final VoidCallback? onTap;

  const TarjetaServicioReciente({
    Key? key,
    required this.servicio,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono del servicio
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getServiceIcon(servicio.categoria),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del servicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servicio.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        servicio.calificacion.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Precio
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${servicio.precioPorHora.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'por hora',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'plomeria':
        return Icons.plumbing;
      case 'electricidad':
        return Icons.electrical_services;
      case 'jardineria':
        return Icons.grass;
      case 'limpieza':
        return Icons.cleaning_services;
      case 'pintura':
        return Icons.format_paint;
      case 'carpinteria':
        return Icons.handyman;
      default:
        return Icons.home_repair_service;
    }
  }
}