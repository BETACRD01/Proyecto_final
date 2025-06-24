// nucleo/widgets/client/tarjeta_servicio.dart
import 'package:flutter/material.dart';
import '../../../../modelos/modelo_servicio.dart'; // Tu ServiceModel
import '../../../../nucleo/constantes/colores_app.dart';
import 'utilidades/utilidades_servicios.dart';
import 'utilidades/dialogos_servicio.dart';

class TarjetaServicio extends StatelessWidget {
  final ServiceModel servicio;
  final int indice;
  final bool esLista;

  const TarjetaServicio({
    Key? key,
    required this.servicio,
    required this.indice,
    this.esLista = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color colorTarjeta = AppColors.obtenerColorPorIndice(indice);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => DialogosServicio.mostrarDetallesServicio(
          context, 
          servicio, 
          colorTarjeta
        ),
        borderRadius: BorderRadius.circular(16),
        child: esLista 
            ? _construirTarjetaLista(colorTarjeta)
            : _construirTarjetaGrilla(colorTarjeta),
      ),
    );
  }

  Widget _construirTarjetaGrilla(Color colorTarjeta) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirEncabezadoTarjeta(colorTarjeta),
            const SizedBox(height: 12),
            _construirInformacionServicio(),
            const Spacer(),
            _construirPieTarjeta(colorTarjeta),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaLista(Color colorTarjeta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _construirIconoServicio(colorTarjeta, 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirTituloServicio(),
                const SizedBox(height: 4),
                _construirNombreProveedor(),
                const SizedBox(height: 8),
                _construirInformacionInferior(colorTarjeta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEncabezadoTarjeta(Color colorTarjeta) {
    return Row(
      children: [
        _construirIconoServicio(colorTarjeta, 40),
        const Spacer(),
        _construirChipCalificacion(),
      ],
    );
  }

  Widget _construirIconoServicio(Color colorTarjeta, double tamano) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: colorTarjeta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tamano / 2),
      ),
      child: Icon(
        UtilidadesServicios.obtenerIconoPorCategoria(servicio.category.toString()),
        color: colorTarjeta,
        size: tamano * 0.55,
      ),
    );
  }

  Widget _construirChipCalificacion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppColors.warning,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            UtilidadesServicios.formatearCalificacion(servicio.rating),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirInformacionServicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirTituloServicio(),
        const SizedBox(height: 4),
        _construirNombreProveedor(),
      ],
    );
  }

  Widget _construirTituloServicio() {
    return Text(
      servicio.description,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _construirNombreProveedor() {
    return Text(
      UtilidadesServicios.obtenerNombreProveedor(servicio),
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _construirPieTarjeta(Color colorTarjeta) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _construirPrecio(colorTarjeta),
        _construirIndicadorEstado(),
      ],
    );
  }

  Widget _construirInformacionInferior(Color colorTarjeta) {
    return Row(
      children: [
        _construirChipCalificacion(),
        const Spacer(),
        _construirPrecio(colorTarjeta),
      ],
    );
  }

  Widget _construirPrecio(Color colorTarjeta) {
    return Text(
      '\$${UtilidadesServicios.obtenerPrecioServicio(servicio)}',
      style: TextStyle(
        fontSize: esLista ? 17 : 16,
        fontWeight: FontWeight.bold,
        color: colorTarjeta,
      ),
    );
  }

  Widget _construirIndicadorEstado() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: UtilidadesServicios.obtenerColorEstado(servicio.isActive),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}