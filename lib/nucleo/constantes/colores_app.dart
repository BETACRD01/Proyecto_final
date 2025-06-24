// nucleo/constantes/colores_app.dart
import 'package:flutter/material.dart';

class AppColors {
  // Colores principales inspirados en la región amazónica
  static const Color primary = Color(0xFF2E7D32); // Verde amazónico
  static const Color secondary = Color(0xFF1565C0); // Azul confianza
  static const Color accent = Color(0xFFFFA726); // Naranja cálido

  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Color(0xFFFAFAFA);

  // Colores de estado
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static const Color border = Color(0xFFCCCCCC);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Colores adicionales
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // *** MÉTODO FALTANTE AGREGADO ***
  static Color obtenerColorPorIndice(int indice) {
    final colores = [primary, success, warning, secondary, accent, info];
    return colores[indice % colores.length];
  }

  // Métodos utilitarios para compatibilidad con código refactorizado
  
  // Aliases para mantener compatibilidad
  static const Color primario = primary;
  static const Color secundario = secondary;
  static const Color verde = success;
  static const Color rojo = error;
  static const Color amarillo = warning;
  static const Color azul = info;
  static const Color violeta = secondary;
  
  // Colores de texto con aliases
  static const Color textoOscuro = textPrimary;
  static const Color textoSecundario = textSecondary;
  static const Color grisSecundario = textSecondary;
  static const Color grisClaro = textHint;
  
  // Colores de fondo con aliases
  static const Color fondoPrincipal = background;
  static const Color fondoTarjeta = cardBackground;
  static const Color bordeClaro = divider;
  static const Color grisClaro2 = divider;
  static const Color grisMuyClaro = textHint;
  
  // Métodos utilitarios
  static Color conOpacidad(Color color, double opacidad) {
    return color.withValues(alpha: opacidad);
  }
}

// Extensiones útiles para colores
extension ColoresExtension on Color {
  Color get conOpacidadBaja => withValues(alpha: 0.1);
  Color get conOpacidadMedia => withValues(alpha: 0.3);
  Color get conOpacidadAlta => withValues(alpha: 0.6);
}