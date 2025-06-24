// lib/pantallas/reservas/widgets/dialogos_reservas.dart

import 'package:flutter/material.dart';

/// 💬 Clase que maneja todos los diálogos de la aplicación
/// Incluye: confirmaciones, calificaciones y alertas
class DialogosReservas {
  
  /// ❓ Muestra un diálogo de confirmación personalizable
  static void mostrarConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
    required Color colorConfirmar,
    required VoidCallback alConfirmar,
    String? textoSecundario,
    VoidCallback? accionSecundaria,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirIconoConfirmacion(colorConfirmar),
              const SizedBox(height: 24),
              _construirTituloConfirmacion(titulo),
              const SizedBox(height: 12),
              _construirMensajeConfirmacion(mensaje),
              const SizedBox(height: 32),
              _construirBotonesConfirmacion(
                context: context,
                textoConfirmar: textoConfirmar,
                colorConfirmar: colorConfirmar,
                alConfirmar: alConfirmar,
                textoSecundario: textoSecundario,
                accionSecundaria: accionSecundaria,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ⭐ Muestra un diálogo de calificación con estrellas y comentarios
  static void mostrarCalificacion({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required Function(double calificacion, String resena) alEnviar,
  }) {
    double calificacion = 5.0;
    final controladorResena = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _construirEncabezadoCalificacion(),
                  const SizedBox(height: 24),
                  _construirTituloCalificacion(titulo),
                  const SizedBox(height: 8),
                  _construirSubtituloCalificacion(subtitulo),
                  const SizedBox(height: 32),
                  _construirSelectorEstrellas(
                    calificacion: calificacion,
                    alCambiar: (nuevaCalificacion) {
                      setState(() => calificacion = nuevaCalificacion);
                    },
                  ),
                  const SizedBox(height: 24),
                  _construirCampoResena(controladorResena),
                  const SizedBox(height: 32),
                  _construirBotonesCalificacion(
                    context: context,
                    alEnviar: () => alEnviar(calificacion, controladorResena.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🚨 Muestra una alerta simple con un solo botón
  static void mostrarAlerta({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoBoton = 'Entendido',
    Color? color,
    VoidCallback? alPresionar,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: alPresionar ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: color ?? const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              textoBoton,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 WIDGETS AUXILIARES PARA CONFIRMACIÓN

  static Widget _construirIconoConfirmacion(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Icon(
        Icons.help_outline_rounded,
        color: color,
        size: 40,
      ),
    );
  }

  static Widget _construirTituloConfirmacion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget _construirMensajeConfirmacion(String mensaje) {
    return Text(
      mensaje,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF6B7280),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget _construirBotonesConfirmacion({
    required BuildContext context,
    required String textoConfirmar,
    required Color colorConfirmar,
    required VoidCallback alConfirmar,
    String? textoSecundario,
    VoidCallback? accionSecundaria,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (textoSecundario != null && accionSecundaria != null) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                accionSecundaria();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7280),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                textoSecundario,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              alConfirmar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorConfirmar,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              textoConfirmar,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ⭐ WIDGETS AUXILIARES PARA CALIFICACIÓN

  static Widget _construirEncabezadoCalificacion() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.2),
            const Color(0xFFF59E0B).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Icon(
        Icons.star_rounded,
        color: Color(0xFFF59E0B),
        size: 40,
      ),
    );
  }

  static Widget _construirTituloCalificacion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget _construirSubtituloCalificacion(String subtitulo) {
    return Text(
      subtitulo,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF6B7280),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget _construirSelectorEstrellas({
    required double calificacion,
    required Function(double) alCambiar,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.05),
            const Color(0xFFF59E0B).withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '¿Cómo calificarías la experiencia?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => alCambiar(index + 1.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: index < calificacion
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    index < calificacion
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < calificacion
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _obtenerTextoCalificacion(calificacion),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _construirCampoResena(TextEditingController controlador) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escribe tu reseña (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controlador,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Comparte tu experiencia para ayudar a otros usuarios...',
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  static Widget _construirBotonesCalificacion({
    required BuildContext context,
    required VoidCallback alEnviar,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              alEnviar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Enviar calificación',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // 🔧 MÉTODOS AUXILIARES

  /// 📝 Convierte la calificación numérica a texto descriptivo
  static String _obtenerTextoCalificacion(double calificacion) {
    switch (calificacion.toInt()) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return 'Sin calificar';
    }
  }
}