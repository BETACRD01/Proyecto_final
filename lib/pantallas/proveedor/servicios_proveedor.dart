// lib/caracteristicas/servicios_proveedor/pantallas/pantalla_servicios_proveedor.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/constantes/colores_app.dart';
import '../../cliente/client/home/widget_cargando.dart';
import '../../../nucleo/widgets/widget_error.dart';
import '../../../proveedores/proveedor_autenticacion.dart';
import '../proveedores/proveedor_servicio.dart';
import '../modelos/modelo_servicio.dart';
import '../widgets/vista_servicios_vacios.dart';
import '../widgets/tarjeta_servicio.dart';
import '../widgets/dialogo_formulario_servicio.dart';

class PantallaServiciosProveedor extends StatefulWidget {
  const PantallaServiciosProveedor({Key? key}) : super(key: key);

  @override
  State<PantallaServiciosProveedor> createState() => _PantallaServiciosProveedorState();
}

class _PantallaServiciosProveedorState extends State<PantallaServiciosProveedor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarServicios();
    });
  }

  void _cargarServicios() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.currentUser;

    if (usuario != null) {
      Provider.of<ProveedorServicio>(context, listen: false)
          .cargarServiciosDelProveedor(usuario.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildCuerpo(),
      floatingActionButton: _buildBotonFlotante(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Mis Servicios',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Consumer<ProveedorServicio>(
          builder: (context, proveedorServicio, child) {
            if (proveedorServicio.servicios.isNotEmpty) {
              return PopupMenuButton<String>(
                onSelected: _manejarAccionAppBar,
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'estadisticas',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 16),
                        SizedBox(width: 8),
                        Text('Estadísticas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refrescar',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 8),
                        Text('Refrescar'),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.primary),
          onPressed: _mostrarDialogoAgregarServicio,
          tooltip: 'Agregar servicio',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCuerpo() {
    return Consumer<ProveedorServicio>(
      builder: (context, proveedorServicio, child) {
        if (proveedorServicio.estaCargando) {
          return const WidgetCargando(mensaje: 'Cargando servicios...');
        }

        if (proveedorServicio.mensajeError != null) {
          return CustomErrorWidget(
            message: proveedorServicio.mensajeError!,
            onRetry: _cargarServicios,
          );
        }

        final servicios = proveedorServicio.servicios;

        if (servicios.isEmpty) {
          return VistaServiciosVacios(
            onAgregarServicio: _mostrarDialogoAgregarServicio,
          );
        }

        return Column(
          children: [
            _buildResumenEstadisticas(proveedorServicio),
            Expanded(
              child: _buildListaServicios(servicios),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumenEstadisticas(ProveedorServicio proveedorServicio) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEstadistica(
              'Total',
              proveedorServicio.totalServicios.toString(),
              Icons.home_repair_service,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildEstadistica(
              'Activos',
              proveedorServicio.totalServiciosActivos.toString(),
              Icons.visibility,
              AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildEstadistica(
              'Calificación',
              proveedorServicio.calificacionPromedio.toStringAsFixed(1),
              Icons.star,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadistica(String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildListaServicios(List<ModeloServicio> servicios) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        return TarjetaServicio(
          servicio: servicios[index],
          onEditar: _mostrarDialogoEditarServicio,
          onCambiarEstado: _cambiarEstadoServicio,
          onEliminar: _mostrarConfirmacionEliminar,
        );
      },
    );
  }

  Widget? _buildBotonFlotante() {
    return Consumer<ProveedorServicio>(
      builder: (context, proveedorServicio, child) {
        if (proveedorServicio.servicios.isNotEmpty) {
          return FloatingActionButton(
            onPressed: _mostrarDialogoAgregarServicio,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
        return null;
      },
    );
  }

  void _manejarAccionAppBar(String accion) {
    switch (accion) {
      case 'estadisticas':
        _mostrarEstadisticas();
        break;
      case 'refrescar':
        _cargarServicios();
        break;
    }
  }

  void _mostrarEstadisticas() {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Estadísticas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilaEstadistica('Servicios totales:', proveedorServicio.totalServicios.toString()),
            _buildFilaEstadistica('Servicios activos:', proveedorServicio.totalServiciosActivos.toString()),
            _buildFilaEstadistica('Servicios inactivos:', 
                (proveedorServicio.totalServicios - proveedorServicio.totalServiciosActivos).toString()),
            _buildFilaEstadistica('Calificación promedio:', 
                proveedorServicio.calificacionPromedio.toStringAsFixed(1)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaEstadistica(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarServicio() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.currentUser;

    if (usuario == null) return;

    final resultado = await showDialog<ModeloServicio>(
      context: context,
      builder: (context) => DialogoFormularioServicio(
        proveedorId: usuario.id,
      ),
    );

    if (resultado != null && mounted) {
      _procesarResultadoServicio(resultado, esNuevo: true);
    }
  }

  void _mostrarDialogoEditarServicio(String servicioId) async {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    final servicio = proveedorServicio.obtenerServicioPorId(servicioId);

    if (servicio == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.currentUser;

    if (usuario == null) return;

    final resultado = await showDialog<ModeloServicio>(
      context: context,
      builder: (context) => DialogoFormularioServicio(
        servicio: servicio,
        proveedorId: usuario.id,
      ),
    );

    if (resultado != null && mounted) {
      _procesarResultadoServicio(resultado, esNuevo: false);
    }
  }

  void _procesarResultadoServicio(ModeloServicio servicio, {required bool esNuevo}) async {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    
    bool exito;
    if (esNuevo) {
      exito = await proveedorServicio.agregarServicio(servicio);
    } else {
      exito = await proveedorServicio.actualizarServicio(servicio);
    }

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esNuevo ? 'Servicio agregado exitosamente' : 'Servicio actualizado exitosamente',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _cambiarEstadoServicio(String servicioId, bool nuevoEstado) async {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    
    final exito = await proveedorServicio.cambiarEstadoServicio(servicioId, nuevoEstado);

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado ? 'Servicio activado' : 'Servicio desactivado',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _mostrarConfirmacionEliminar(String servicioId) {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    final servicio = proveedorServicio.obtenerServicioPorId(servicioId);

    if (servicio == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Eliminar Servicio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar "${servicio.nombre}"?'),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _eliminarServicio(servicioId);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarServicio(String servicioId) async {
    final proveedorServicio = Provider.of<ProveedorServicio>(context, listen: false);
    
    final exito = await proveedorServicio.eliminarServicio(servicioId);

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio eliminado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}