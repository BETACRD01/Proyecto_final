// lib/caracteristicas/servicios_proveedor/widgets/vista_servicios_vacios.dart

import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import '../../../../nucleo/widgets/boton_personalizado.dart';

class VistaServiciosVacios extends StatelessWidget {
  final VoidCallback onAgregarServicio;

  const VistaServiciosVacios({
    Key? key,
    required this.onAgregarServicio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_repair_service_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Título principal
            const Text(
              'No tienes servicios registrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción
            const Text(
              'Comienza agregando tu primer servicio para que los clientes puedan encontrarte y contratarte',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Consejos
            const Text(
              'Tip: Los servicios activos aparecen en las búsquedas de los clientes',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Botón principal
            CustomButton(
              text: 'Agregar mi primer servicio',
              onPressed: onAgregarServicio,
              icon: Icons.add_circle_outline,
              width: 250,
            ),
            const SizedBox(height: 16),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Consejos para comenzar:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildConsejo('Describe claramente tu servicio'),
                  _buildConsejo('Establece un precio competitivo'),
                  _buildConsejo('Mantén tus servicios actualizados'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsejo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}