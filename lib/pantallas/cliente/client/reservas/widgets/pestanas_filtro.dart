// lib/pantallas/reservas/widgets/pestanas_filtro.dart

import 'package:flutter/material.dart';

/// 📑 Widget de pestañas para filtrar reservas por estado
/// Diseño moderno con gradientes adaptativos según tipo de usuario
class PestanasFiltro extends StatelessWidget {
  final TabController controlador;
  final bool esProveedor;

  const PestanasFiltro({
    Key? key,
    required this.controlador,
    required this.esProveedor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controlador,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: _obtenerColoresGradiente(),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: _construirPestanas(),
      ),
    );
  }

  /// 🌈 Obtiene los colores del gradiente según el tipo de usuario
  List<Color> _obtenerColoresGradiente() {
    if (esProveedor) {
      return [
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
      ];
    } else {
      return [
        const Color(0xFF1B365D),
        const Color(0xFF2563EB),
      ];
    }
  }

  /// 📋 Construye las pestañas con iconos y texto
  List<Widget> _construirPestanas() {
    return [
      _construirPestana(
        texto: 'Todas',
        icono: Icons.grid_view_rounded,
        contador: null,
      ),
      _construirPestana(
        texto: 'Pendientes',
        icono: Icons.schedule_rounded,
        contador: null,
      ),
      _construirPestana(
        texto: 'Confirmadas',
        icono: Icons.check_circle_rounded,
        contador: null,
      ),
      _construirPestana(
        texto: 'Completadas',
        icono: Icons.task_alt_rounded,
        contador: null,
      ),
      _construirPestana(
        texto: 'Canceladas',
        icono: Icons.cancel_rounded,
        contador: null,
      ),
    ];
  }

  /// 🏷️ Construye una pestaña individual con icono opcional
  Widget _construirPestana({
    required String texto,
    IconData? icono,
    int? contador,
  }) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 16),
              const SizedBox(width: 6),
            ],
            Text(texto),
            if (contador != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  contador.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}