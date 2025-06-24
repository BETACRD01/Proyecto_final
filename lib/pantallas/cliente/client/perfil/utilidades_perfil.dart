// lib/pantallas/perfil/utilidades_perfil.dart

import 'package:flutter/material.dart';
import 'dart:async';

class ProfileUtils {
  
  // 📱 SnackBar personalizado
  static void showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isSuccess 
            ? const Color(0xFF10B981) 
            : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isSuccess ? 2 : 3),
        elevation: 8,
      ),
    );
  }

  // ✅ Validadores de formulario
  static bool validateName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  static bool validateEmail(String email) {
    if (email.trim().isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  static bool validatePhone(String phone) {
    if (phone.trim().isEmpty) return true; // Campo opcional
    return RegExp(r'^[\+]?[0-9]{10,15}$').hasMatch(phone.trim().replaceAll(' ', ''));
  }

  static bool validateRequired(String value) {
    return value.trim().isNotEmpty;
  }

  // 🎨 Colores del tema
  static const Color primaryColor = Color(0xFF1B365D);
  static const Color secondaryColor = Color(0xFF2563EB);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color background = Color(0xFFF5F7FA);

  // 📏 Dimensiones comunes
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonHeight = 48.0;
  static const double spacing = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingLarge = 24.0;

  // 🔧 Métodos de utilidad
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 📱 Estilos de texto comunes
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // 🎯 Formatters
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    
    // Eliminar caracteres no numéricos excepto +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Formatear según el patrón común
    if (cleaned.startsWith('+593')) {
      // Formato Ecuador: +593 99 999 9999
      if (cleaned.length >= 13) {
        return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9, 13)}';
      }
    } else if (cleaned.startsWith('0')) {
      // Formato local: 099 999 9999
      if (cleaned.length >= 10) {
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 10)}';
      }
    }
    
    return phone; // Retornar original si no coincide con patrones
  }

  static String formatName(String name) {
    if (name.isEmpty) return '';
    
    return name
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  static String formatEmail(String email) {
    return email.trim().toLowerCase();
  }

  // 🌈 Generadores de gradientes
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static LinearGradient get successGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, Color(0xFF059669)],
  );

  static LinearGradient get errorGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorColor, Color(0xFFDC2626)],
  );

  // 🎭 Generadores de sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // 🔄 Debouncer para búsquedas
  static Timer? _debounceTimer;
  
  static void debounce(Duration duration, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  // 📊 Métrica de rating
  static String getRatingText(double rating) {
    if (rating >= 4.5) return 'Excelente';
    if (rating >= 4.0) return 'Muy bueno';
    if (rating >= 3.5) return 'Bueno';
    if (rating >= 3.0) return 'Regular';
    return 'Necesita mejorar';
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.0) return successColor;
    if (rating >= 3.0) return warningColor;
    return errorColor;
  }

  // 🎨 Helpers para iconos
  static IconData getServiceIcon(String serviceName) {
    final service = serviceName.toLowerCase();
    
    if (service.contains('limpieza')) return Icons.cleaning_services;
    if (service.contains('plomería') || service.contains('plomero')) return Icons.plumbing;
    if (service.contains('eléctrico') || service.contains('electricidad')) return Icons.electrical_services;
    if (service.contains('carpintería') || service.contains('carpintero')) return Icons.handyman;
    if (service.contains('jardinería') || service.contains('jardín')) return Icons.local_florist;
    if (service.contains('pintura') || service.contains('pintor')) return Icons.format_paint;
    if (service.contains('construcción')) return Icons.construction;
    if (service.contains('tecnología') || service.contains('computación')) return Icons.computer;
    
    return Icons.work; // Icono por defecto
  }

  // 🕒 Helpers de tiempo
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return 'Hace ${(difference.inDays / 365).floor()} años';
    } else if (difference.inDays > 30) {
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Ahora mismo';
    }
  }

  static String formatDate(DateTime dateTime) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${dateTime.day} de ${months[dateTime.month - 1]} de ${dateTime.year}';
  }
}