// lib/pantallas/proveedor/servicios_proveedor/pantalla_servicios_proveedor.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/constantes/colores_app.dart';
import '../../../proveedores/proveedor_autenticacion.dart';
import 'servicios_proveedor/proveedores/proveedor_servicios.dart';
import 'servicios_proveedor/modelos/modelo_servicio.dart';

class PantallaServiciosProveedor extends StatefulWidget {
  const PantallaServiciosProveedor({Key? key}) : super(key: key);

  @override
  State<PantallaServiciosProveedor> createState() => _PantallaServiciosProveedorState();
}

class _PantallaServiciosProveedorState extends State<PantallaServiciosProveedor> {
  @override
  void initState() {
    super.initState();
    // Cargar servicios cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        Provider.of<ProveedorServicio>(context, listen: false)
            .loadServicesByProvider(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProveedorServicio>(
        builder: (context, proveedorServicio, child) {
          if (proveedorServicio.estaCargando) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Cargando servicios...'),
                ],
              ),
            );
          }

          if (proveedorServicio.mensajeError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${proveedorServicio.mensajeError}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final user = authProvider.currentUser;
                      if (user != null) {
                        proveedorServicio.loadServicesByProvider(user.id);
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (proveedorServicio.servicios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_repair_service_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes servicios registrados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega tu primer servicio para comenzar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: proveedorServicio.servicios.length,
            itemBuilder: (context, index) {
              final servicio = proveedorServicio.servicios[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      _getServiceIcon(servicio.categoria),
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    servicio.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(servicio.descripcion),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${servicio.calificacion}'),
                          const SizedBox(width: 16),
                          Icon(
                            servicio.estaActivo ? Icons.check_circle : Icons.pause_circle,
                            size: 16,
                            color: servicio.estaActivo ? Colors.green : Colors.orange,
                          ),
                          Text(servicio.estaActivo ? ' Activo' : ' Pausado'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    '\$${servicio.precioPorHora.toStringAsFixed(0)}/h',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () {
                    // Navegar a detalles del servicio
                    _showServiceDetails(servicio);
                  },
                ),
              );
            },
          );
        },
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
      default:
        return Icons.home_repair_service;
    }
  }

  void _showServiceDetails(ModeloServicio servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(servicio.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${servicio.descripcion}'),
            const SizedBox(height: 8),
            Text('Categoría: ${servicio.categoria}'),
            const SizedBox(height: 8),
            Text('Precio: \$${servicio.precioPorHora}/hora'),
            const SizedBox(height: 8),
            Text('Calificación: ${servicio.calificacion}/5.0'),
            const SizedBox(height: 8),
            Text('Estado: ${servicio.estaActivo ? "Activo" : "Pausado"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías navegar a editar servicio
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}