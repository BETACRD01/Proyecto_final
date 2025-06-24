// nucleo/widgets/client/seccion_servicios_populares.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../proveedores/proveedor_servicios.dart'; // Tu ServiceProvider 
import '../../../../nucleo/constantes/colores_app.dart';
import 'widget_cargando.dart';
import 'tarjeta_servicio.dart';
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
          Consumer<ServiceProvider>(
            builder: (context, serviceProvider, child) {
              if (serviceProvider.isLoading) {
                return const WidgetCargando(esGrilla: true);
              }

              if (serviceProvider.services.isEmpty) {
                return const TarjetaVacia(mensaje: 'No hay servicios disponibles');
              }

              final serviciosMostrar = serviceProvider.services.take(4).toList();

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
                    indice: indice,
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
}