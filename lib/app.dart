import 'package:flutter/material.dart'; // ⭐ AGREGAR ESTO
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'screens/common/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/provider_registration_form.dart';
import 'screens/client/profile_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/client/service_list_screen.dart';
import 'screens/client/service_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_list_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/provider/provider_dashboard.dart';
import 'screens/provider/provider_services.dart';
import 'screens/provider/provider_bookings.dart';
import 'screens/common/map_screen.dart';
import 'screens/common/chat_screen.dart';
import 'screens/provider/provider_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ManachiyKanKusataApp extends StatelessWidget {
  const ManachiyKanKusataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mañachiy kan Kusata',
      debugShowCheckedModeBanner: false,

      // ⭐ LOCALIZACIONES AGREGADAS:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español (Ecuador)
        Locale('en', 'US'), // Inglés (backup)
      ],
      locale: const Locale('es', 'ES'), // Idioma por defecto español

      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),

        // ⭐ TEMA ADICIONAL PARA DATE PICKER:
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: AppColors.primary,
          headerForegroundColor: Colors.white,
          dayStyle: const TextStyle(color: AppColors.textPrimary),
          yearStyle: const TextStyle(color: AppColors.textPrimary),
          dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return null;
          }),
          todayBackgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return AppColors.primary.withValues(alpha: 0.1);
          }),
          todayForegroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return AppColors.primary;
          }),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.services: (context) => const ServiceListScreen(),
        AppRoutes.serviceDetail: (context) => const ServiceDetailScreen(),
        AppRoutes.bookingForm: (context) => const BookingFormScreen(),
        AppRoutes.bookings: (context) => const BookingListScreen(),
        AppRoutes.bookingDetail: (context) => const BookingDetailScreen(),
        AppRoutes.providerDashboard: (context) => const ProviderDashboard(),
        AppRoutes.providerServices: (context) => const ProviderServices(),
        AppRoutes.providerBookings: (context) => const ProviderBookings(),
        AppRoutes.map: (context) => const MapScreen(),
        AppRoutes.chat: (context) => const ChatScreen(),
        AppRoutes.providerHome: (context) => const ProviderHomeScreen(),
        AppRoutes.providerRegistrationForm: (context) =>
            const ProviderRegistrationForm(),
        AppRoutes.adminHome: (context) => const AdminHomeScreen(),
      },
    );
  }
}
