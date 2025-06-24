// pantallas/cliente/pantalla_inicio.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../proveedores/proveedor_servicios.dart';
import 'client/home/widget_encabezado.dart';
import 'client/home/seccion_acciones_rapidas.dart';
import 'client/home/seccion_servicios_populares.dart';
import 'client/home/seccion_servicios_recientes.dart';
import '../../nucleo/constantes/colores_app.dart';
import '../cliente/reservas_cliente.dart'; // Import de la pantalla real
import '../cliente/pantalla_chat.dart'; // ✅ Import de tu ChatScreen
import '../cliente/pantalla_perfil.dart'; // ✅ Import de tu ProfileScreen

class PantallaInicioCliente extends StatefulWidget {
  const PantallaInicioCliente({Key? key}) : super(key: key);

  @override
  State<PantallaInicioCliente> createState() => _PantallaInicioClienteState();
}

class _PantallaInicioClienteState extends State<PantallaInicioCliente> {
  int _indiceActual = 0;
  final PageController _controladorPaginas = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  @override
  void dispose() {
    _controladorPaginas.dispose();
    super.dispose();
  }

  void _navegarAReservas() {
    _navegarAPagina(1);
  }

  void _navegarAChat() {
    _navegarAPagina(2);
  }

  void _navegarAPagina(int indice) {
    setState(() {
      _indiceActual = indice;
    });
    _controladorPaginas.animateToPage(
      indice,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _controladorPaginas,
        onPageChanged: (indice) {
          setState(() {
            _indiceActual = indice;
          });
        },
        children: [
          _TabInicio(
            alNavegarAReservas: _navegarAReservas,
            alNavegarAChat: _navegarAChat,
          ),
          // ✅ CORREGIDO: Usar las pantallas reales con sus nombres correctos
          const PantallaListaReservas(),
          const ChatScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _construirBarraNavegacion(),
    );
  }

  Widget _construirBarraNavegacion() {
    final elementosNav = [
      {'icono': Icons.home, 'etiqueta': 'Inicio'},
      {'icono': Icons.description, 'etiqueta': 'Mis reservas'},
      {'icono': Icons.chat, 'etiqueta': 'Chat'},
      {'icono': Icons.person, 'etiqueta': 'Perfil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: elementosNav
                .asMap()
                .entries
                .map((entrada) => _construirElementoNav(
                      entrada.key,
                      entrada.value['icono'] as IconData,
                      entrada.value['etiqueta'] as String,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _construirElementoNav(int indice, IconData icono, String etiqueta) {
    final bool estaActivo = _indiceActual == indice;
    
    return GestureDetector(
      onTap: () => _navegarAPagina(indice),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            color: estaActivo ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 10,
              fontWeight: estaActivo ? FontWeight.w600 : FontWeight.w400,
              color: estaActivo ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabInicio extends StatelessWidget {
  final VoidCallback alNavegarAReservas;
  final VoidCallback alNavegarAChat;

  const _TabInicio({
    required this.alNavegarAReservas,
    required this.alNavegarAChat,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ServiceProvider>(context, listen: false)
            .loadServices();
      },
      color: AppColors.primary,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const WidgetEncabezado(),
              const SizedBox(height: 32),
              SeccionAccionesRapidas(
                alNavegarAReservas: alNavegarAReservas,
                alNavegarAChat: alNavegarAChat,
              ),
              const SizedBox(height: 32),
              const SeccionServiciosPopulares(),
              const SizedBox(height: 32),
              const SeccionServiciosRecientes(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ ELIMINADO: Ya no necesitamos estas clases locales porque usamos las importadas
// Las pantallas ChatScreen y ProfileScreen ya están desarrolladas en sus archivos separados