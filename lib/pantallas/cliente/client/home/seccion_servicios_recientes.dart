// nucleo/widgets/seccion_servicios_recientes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../proveedores/proveedor_servicios.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import 'widget_cargando.dart';
import 'tarjeta_servicio.dart';
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
          Consumer<ServiceProvider>(
            builder: (context, serviceProvider, child) {
              if (serviceProvider.isLoading) {
                return const EsqueletoLista();
              }

              if (serviceProvider.services.isEmpty) {
                return const TarjetaVacia(mensaje: 'No hay servicios recientes');
              }

              final serviciosRecientes = serviceProvider.services.take(3).toList();

              return Column(
                children: serviciosRecientes
                    .asMap()
                    .entries
                    .map((entrada) => TarjetaServicio(
                          servicio: entrada.value,
                          indice: entrada.key,
                          esLista: true,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
