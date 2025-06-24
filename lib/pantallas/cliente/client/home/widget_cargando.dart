// nucleo/widgets/client/widget_cargando.dart
import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/colores_app.dart';

class WidgetCargando extends StatelessWidget {
  final String? mensaje;
  final double? altura;
  final bool esGrilla;

  const WidgetCargando({
    Key? key,
    this.mensaje,
    this.altura,
    this.esGrilla = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (esGrilla) {
      return _construirEsqueletoGrilla();
    }

    return Container(
      height: altura ?? 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            if (mensaje != null) ...[
              const SizedBox(height: 16),
              Text(
                mensaje!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirEsqueletoGrilla() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const EsqueletoTarjeta(),
    );
  }
}

class EsqueletoTarjeta extends StatelessWidget {
  const EsqueletoTarjeta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class EsqueletoLista extends StatelessWidget {
  final int cantidad;

  const EsqueletoLista({
    Key? key,
    this.cantidad = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        cantidad,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}