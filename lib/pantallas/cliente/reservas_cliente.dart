// lib/pantallas/reservas/pantalla_lista_reservas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../proveedores/proveedor_reservas.dart';
import '../../modelos/modelo_reserva.dart';
import 'client/reservas/widgets/app_bar_reservas.dart';
import 'client/reservas/widgets/dashboard_estadisticas.dart';
import 'client/reservas/widgets/pestanas_filtro.dart';
import 'client/reservas/widgets/tarjeta_reserva.dart';
import 'client/reservas/widgets/estados_carga.dart';
import 'client/reservas/controladores/controlador_reservas.dart';

/// 📱 Pantalla principal que muestra la lista de reservas
/// Diseñada para proveedores y clientes con diferentes funcionalidades
class PantallaListaReservas extends StatefulWidget {
  const PantallaListaReservas({Key? key}) : super(key: key);

  @override
  State<PantallaListaReservas> createState() => _PantallaListaReservasState();
}

class _PantallaListaReservasState extends State<PantallaListaReservas>
    with TickerProviderStateMixin {
  
  // 🎮 Controladores de animación y pestañas
  late TabController _controladorPestanas;
  late AnimationController _controladorAnimacionHeader;
  late AnimationController _controladorAnimacionFab;
  late Animation<double> _animacionHeader;
  late Animation<double> _animacionFab;

  // 🧠 Controlador de lógica de negocio
  late ControladorReservas _controlador;

  @override
  void initState() {
    super.initState();
    _configurarAnimaciones();
    _configurarControladorPestanas();
    _controlador = ControladorReservas(
      context: context,
      vsync: this,
      alActualizar: () => setState(() {}),
      controladorAnimacionFab: _controladorAnimacionFab,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controlador.inicializar();
    });
  }

  /// 🎨 Configura las animaciones del header y FAB
  void _configurarAnimaciones() {
    _controladorAnimacionHeader = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controladorAnimacionFab = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animacionHeader = CurvedAnimation(
      parent: _controladorAnimacionHeader,
      curve: Curves.easeOutCubic,
    );

    _animacionFab = CurvedAnimation(
      parent: _controladorAnimacionFab,
      curve: Curves.elasticOut,
    );

    _controladorAnimacionHeader.forward();
  }

  /// 📑 Configura el controlador de pestañas con listener
  void _configurarControladorPestanas() {
    _controladorPestanas = TabController(length: 5, vsync: this);
    _controladorPestanas.addListener(() {
      if (!_controladorPestanas.indexIsChanging) {
        _controlador.cambiarFiltro(_controladorPestanas.index);
      }
    });
  }

  @override
  void dispose() {
    _controladorPestanas.dispose();
    _controladorAnimacionHeader.dispose();
    _controladorAnimacionFab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            AppBarReservas(
              animacion: _animacionHeader,
              esProveedor: _controlador.esProveedor,
              usuarioActual: _controlador.usuarioActual,
              alPresionarFiltros: _controlador.mostrarOpcionesFiltro,
            ),
          ];
        },
        body: Consumer<BookingProvider>(
          builder: (context, proveedorReservas, child) {
            // 🔄 Estado de carga
            if (proveedorReservas.isLoading && !_controlador.estaRecargando) {
              return EstadosCarga.construirCargando(_controlador.esProveedor);
            }

            // ❌ Estado de error
            if (proveedorReservas.errorMessage != null) {
              return EstadosCarga.construirError(
                mensaje: proveedorReservas.errorMessage!,
                alReintentar: _controlador.cargarReservas,
              );
            }

            // ✅ Contenido principal
            return Column(
              children: [
                DashboardEstadisticas(
                  proveedorReservas: proveedorReservas,
                  esProveedor: _controlador.esProveedor,
                  estaRecargando: _controlador.estaRecargando,
                ),
                PestanasFiltro(
                  controlador: _controladorPestanas,
                  esProveedor: _controlador.esProveedor,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: TabBarView(
                      controller: _controladorPestanas,
                      children: [
                        _construirListaReservas(proveedorReservas.bookings),
                        _construirListaReservas(proveedorReservas
                            .getBookingsByStatus(BookingStatus.pending)),
                        _construirListaReservas(proveedorReservas
                            .getBookingsByStatus(BookingStatus.confirmed)),
                        _construirListaReservas(
                            proveedorReservas.getCompletedBookings()),
                        _construirListaReservas(proveedorReservas
                            .getBookingsByStatus(BookingStatus.cancelled)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _construirBotonFlotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 📋 Construye la lista de reservas con estado vacío si es necesario
  Widget _construirListaReservas(List<BookingModel> reservas) {
    if (reservas.isEmpty) {
      return EstadosCarga.construirVacio(
        filtroSeleccionado: _controlador.filtroSeleccionado,
        esProveedor: _controlador.esProveedor,
      );
    }

    return RefreshIndicator(
      onRefresh: _controlador.cargarReservas,
      color: _controlador.esProveedor 
          ? const Color(0xFF6366F1) 
          : const Color(0xFF1B365D),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 8),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          return TarjetaReserva(
            reserva: reservas[index],
            indice: index,
            esProveedor: _controlador.esProveedor,
            controlador: _controlador,
          );
        },
      ),
    );
  }

  /// 🎯 Construye el botón flotante con animación
  Widget _construirBotonFlotante() {
    return ScaleTransition(
      scale: _animacionFab,
      child: FloatingActionButton.extended(
        onPressed: _controlador.accionBotonFlotante,
        backgroundColor: _controlador.esProveedor 
            ? const Color(0xFF6366F1) 
            : const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(_controlador.esProveedor ? Icons.dashboard : Icons.add),
        label: Text(_controlador.esProveedor ? 'Acciones' : 'Reservar'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}