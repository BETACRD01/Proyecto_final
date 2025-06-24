// core/utils/helpers.dart - Versión escalada
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../modelos/modelo_reserva.dart';
import '../../modelos/modelo_servicio.dart';
import '../../modelos/modelo_usuario.dart';

class Helpers {
  // ===================== FORMATEO DE MONEDA =====================

  static String formatCurrency(double amount,
      {String? locale, String? symbol}) {
    final formatter = NumberFormat.currency(
      locale: locale ?? 'es_EC',
      symbol: symbol ?? '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Formateo compacto para números grandes
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${formatCurrency(amount / 1000000)}M';
    } else if (amount >= 1000) {
      return '${formatCurrency(amount / 1000)}K';
    }
    return formatCurrency(amount);
  }

  // ===================== FORMATEO DE FECHAS =====================

  static String formatDate(DateTime date, {String? locale}) {
    final formatter = DateFormat('dd/MM/yyyy', locale ?? 'es_ES');
    return formatter.format(date);
  }

  static String formatTime(DateTime time, {String? locale}) {
    final formatter = DateFormat('HH:mm', locale ?? 'es_ES');
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime, {String? locale}) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', locale ?? 'es_ES');
    return formatter.format(dateTime);
  }

  // Formato de fecha más legible
  static String formatDateReadable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoy, ${formatTime(date)}';
    } else if (targetDate == yesterday) {
      return 'Ayer, ${formatTime(date)}';
    } else if (targetDate == tomorrow) {
      return 'Mañana, ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  // Formato de fecha para mostrar edad
  static String formatDateRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return '${formatDate(start)}, ${formatTime(start)} - ${formatTime(end)}';
    }
    return '${formatDateTime(start)} - ${formatDateTime(end)}';
  }

  // ===================== TIEMPO RELATIVO =====================

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months mes${months > 1 ? 'es' : ''}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  // Tiempo hasta una fecha futura
  static String getTimeUntil(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.isNegative) {
      return getTimeAgo(futureDate);
    }

    if (difference.inDays > 0) {
      return 'en ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'en ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'en ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'muy pronto';
    }
  }

  // ===================== TEXTO Y CADENAS =====================

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  // Truncar texto con ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  // Obtener iniciales de nombre
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Limpiar y validar texto
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ===================== CATEGORÍAS Y ESTADOS =====================

  static String getServiceCategoryName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return 'Limpieza';
      case ServiceCategory.plumbing:
        return 'Plomería';
      case ServiceCategory.carpentry:
        return 'Carpintería';
      case ServiceCategory.electricity:
        return 'Electricidad';
      case ServiceCategory.gardening:
        return 'Jardinería';
      case ServiceCategory.housework:
        return 'Menaje';
      case ServiceCategory.wasteDisposal:
        return 'Desechos';
      case ServiceCategory.other:
        return 'Otros';
    }
  }

  static IconData getServiceCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return Icons.cleaning_services;
      case ServiceCategory.plumbing:
        return Icons.plumbing;
      case ServiceCategory.carpentry:
        return Icons.carpenter;
      case ServiceCategory.electricity:
        return Icons.electrical_services;
      case ServiceCategory.gardening:
        return Icons.grass;
      case ServiceCategory.housework:
        return Icons.home_work;
      case ServiceCategory.wasteDisposal:
        return Icons.delete;
      case ServiceCategory.other:
        return Icons.miscellaneous_services;
    }
  }

  static Color getServiceCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return Colors.blue;
      case ServiceCategory.plumbing:
        return Colors.indigo;
      case ServiceCategory.carpentry:
        return Colors.brown;
      case ServiceCategory.electricity:
        return Colors.amber;
      case ServiceCategory.gardening:
        return Colors.green;
      case ServiceCategory.housework:
        return Colors.purple;
      case ServiceCategory.wasteDisposal:
        return Colors.orange;
      case ServiceCategory.other:
        return Colors.grey;
    }
  }

  static String getBookingStatusName(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pendiente';
      case BookingStatus.confirmed:
        return 'Confirmado';
      case BookingStatus.inProgress:
        return 'En Progreso';
      case BookingStatus.completed:
        return 'Completado';
      case BookingStatus.cancelled:
        return 'Cancelado';
    }
  }

  static Color getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  static IconData getBookingStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.work_outline;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  // ===================== USUARIO =====================

  static String getUserTypeName(UserType userType) {
    switch (userType) {
      case UserType.client:
        return 'Cliente';
      case UserType.provider:
        return 'Proveedor';
      case UserType.admin:
        return 'Administrador';
    }
  }

  static Color getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.client:
        return Colors.blue;
      case UserType.provider:
        return Colors.green;
      case UserType.admin:
        return Colors.red;
    }
  }

  // ===================== VALIDACIONES =====================

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ===================== UTILIDADES DE FECHA =====================

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static List<DateTime> getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  // ===================== CÁLCULOS =====================

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Implementar fórmula de Haversine si es necesario
    // Por ahora, una aproximación simple
    final latDiff = (lat1 - lat2).abs();
    final lonDiff = (lon1 - lon2).abs();
    return (latDiff + lonDiff) * 111; // Aproximación en km
  }

  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

  static double calculateTip(double amount, double percentage) {
    return amount * (percentage / 100);
  }

  // ===================== COLORES Y TEMAS =====================

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
      case 'urgent':
        return Colors.red;
      case 'media':
      case 'medium':
        return Colors.orange;
      case 'baja':
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Color getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[DateTime.now().microsecond % colors.length];
  }

  // ===================== ARCHIVOS Y URLs =====================

  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isImageFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return imageExtensions.contains(getFileExtension(fileName));
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ===================== CONVERSIONES =====================

  static String listToString(List<String> list, {String separator = ', '}) {
    return list.join(separator);
  }

  static List<String> stringToList(String text, {String separator = ','}) {
    return text
        .split(separator)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ===================== DEBUGGING Y LOGS =====================

  static void logInfo(String message, [String? tag]) {
    debugPrint('ℹ️ ${tag ?? 'INFO'}: $message');
  }

  static void logError(String message, [String? tag, Object? error]) {
    debugPrint('❌ ${tag ?? 'ERROR'}: $message');
    if (error != null) debugPrint('   Details: $error');
  }

  static void logSuccess(String message, [String? tag]) {
    debugPrint('✅ ${tag ?? 'SUCCESS'}: $message');
  }

  // ===================== CONFIGURACIÓN REGIONAL =====================

  static String getLocalizedText(String key, Map<String, String> translations) {
    return translations[key] ?? key;
  }

  static bool isRTL(String text) {
    // Detectar si el texto es de derecha a izquierda (árabe, hebreo, etc.)
    return RegExp(
            r'[\u0590-\u083F]|[\u08A0-\u08FF]|[\uFB1D-\uFDFF]|[\uFE70-\uFEFF]')
        .hasMatch(text);
  }
}
