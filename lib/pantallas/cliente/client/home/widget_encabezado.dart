// nucleo/widgets/widget_encabezado.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../proveedores/proveedor_autenticacion.dart'; // Usando tu proveedor existente
import '../../../../nucleo/constantes/colores_app.dart';

class WidgetEncabezado extends StatelessWidget {
  const WidgetEncabezado({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Consumer<AuthProvider>(  // Usando tu AuthProvider existente
        builder: (context, authProvider, child) {
          String nombreUsuario = 'Usuario';
          if (authProvider.currentUser != null) {
            final usuario = authProvider.currentUser!;
            if (usuario.name.isNotEmpty) {
              nombreUsuario = usuario.name.split(' ')[0];
            } else if (usuario.email.isNotEmpty) {
              nombreUsuario = usuario.email.split('@')[0];
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $nombreUsuario!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '¿Qué servicio necesitas hoy?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _mostrarAyuda(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ayuda',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.help, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Centro de Ayuda'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Necesitas ayuda?'),
            SizedBox(height: 12),
            Text('• Explora nuestros servicios'),
            Text('• Contacta con soporte'),
            Text('• Revisa tu historial'),
            Text('• Gestiona tus reservas'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}