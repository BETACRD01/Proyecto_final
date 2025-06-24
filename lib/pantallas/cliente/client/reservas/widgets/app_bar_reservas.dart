// lib/pantallas/reservas/widgets/app_bar_reservas.dart

import 'package:flutter/material.dart';
import '../../../../../modelos/modelo_usuario.dart';

/// 🎨 AppBar personalizado con gradientes y animaciones
/// Diseñado para mostrar información diferente según el tipo de usuario
class AppBarReservas extends StatelessWidget {
  final Animation<double> animacion;
  final bool esProveedor;
  final UserModel? usuarioActual;
  final VoidCallback alPresionarFiltros;

  const AppBarReservas({
    Key? key,
    required this.animacion,
    required this.esProveedor,
    required this.usuarioActual,
    required this.alPresionarFiltros,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: AnimatedBuilder(
          animation: animacion,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animacion.value)),
              child: Opacity(
                opacity: animacion.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _obtenerColoresGradiente(),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirFilaSuperiror(),
                          const SizedBox(height: 16),
                          _construirTitulo(),
                          const SizedBox(height: 4),
                          _construirSubtitulo(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leading: _construirBotonAtras(context),
    );
  }

  /// 🌈 Obtiene los colores del gradiente según el tipo de usuario
  List<Color> _obtenerColoresGradiente() {
    if (esProveedor) {
      return [
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
      ];
    } else {
      return [
        const Color(0xFF1B365D),
        const Color(0xFF2563EB),
        const Color(0xFF3B82F6),
      ];
    }
  }

  /// 📊 Construye la fila superior con chip de usuario y botón de filtros
  Widget _construirFilaSuperiror() {
    return Row(
      children: [
        _construirChipTipoUsuario(),
        const Spacer(),
        _construirBotonFiltros(),
      ],
    );
  }

  /// 👤 Chip que muestra el tipo de usuario (Proveedor/Cliente)
  Widget _construirChipTipoUsuario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esProveedor ? Icons.business_center : Icons.person,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            esProveedor ? 'Proveedor' : 'Cliente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 Botón de filtros en la esquina superior derecha
  Widget _construirBotonFiltros() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: alPresionarFiltros,
        icon: const Icon(
          Icons.tune,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 📝 Título principal del AppBar
  Widget _construirTitulo() {
    return Text(
      esProveedor ? 'Panel de Servicios' : 'Mis Reservas',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 📄 Subtítulo descriptivo
  Widget _construirSubtitulo() {
    return Text(
      esProveedor
          ? 'Gestiona las reservas de tus servicios'
          : 'Rastrea y administra tus reservas',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// ⬅️ Botón de retroceso personalizado
  Widget _construirBotonAtras(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}