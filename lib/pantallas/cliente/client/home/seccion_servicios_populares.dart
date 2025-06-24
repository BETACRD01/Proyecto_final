import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../proveedor/servicios_proveedor/proveedores/proveedor_servicios.dart';
import '../../../proveedor/servicios_proveedor/widgets/tarjeta_servicio.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import 'widget_cargando.dart';
import 'tarjeta_vacia.dart';

class SeccionServiciosPopulares extends StatelessWidget {
  const SeccionServiciosPopulares({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Servicios Populares',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _mostrarTodosLosServicios(context),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Consumer<ProveedorServicio>(
            builder: (context, proveedorServicio, child) {
              if (proveedorServicio.estaCargando) {
                return const WidgetCargando(esGrilla: true);
              }

              if (proveedorServicio.servicios.isEmpty) {
                return const TarjetaVacia(mensaje: 'No hay servicios disponibles');
              }

              final serviciosMostrar = proveedorServicio.servicios.take(4).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: serviciosMostrar.length,
                itemBuilder: (context, indice) {
                  return TarjetaServicio(
                    servicio: serviciosMostrar[indice],
                    onEditar: (servicioId) => _editarServicio(context, servicioId),
                    onCambiarEstado: (servicioId, nuevoEstado) => 
                        _cambiarEstadoServicio(context, servicioId, nuevoEstado),
                    onEliminar: (servicioId) => _eliminarServicio(context, servicioId),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _mostrarTodosLosServicios(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Navegando a todos los servicios...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _editarServicio(BuildContext context, String servicioId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✏️ Editando servicio: $servicioId'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _cambiarEstadoServicio(BuildContext context, String servicioId, bool nuevoEstado) {
    final proveedorServicio = context.read<ProveedorServicio>();
    proveedorServicio.cambiarEstadoServicio(servicioId, nuevoEstado);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nuevoEstado 
            ? '✅ Servicio activado' 
            : '❌ Servicio desactivado'
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: nuevoEstado ? AppColors.success : AppColors.warning,
      ),
    );
  }

  void _eliminarServicio(BuildContext context, String servicioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar servicio?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              final proveedorServicio = context.read<ProveedorServicio>();
              proveedorServicio.eliminarServicio(servicioId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Servicio eliminado'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}