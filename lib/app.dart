import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'screens/common/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/provider_registration_form.dart'; // ✅ NUEVO IMPORT
import 'screens/auth/profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/service_list_screen.dart';
import 'screens/home/service_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_list_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/provider/provider_dashboard.dart';
import 'screens/provider/provider_services.dart';
import 'screens/provider/provider_bookings.dart';
import 'screens/common/map_screen.dart';
import 'screens/common/chat_screen.dart';

class ManachiyKanKusataApp extends StatelessWidget {
  const ManachiyKanKusataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mañachiy kan Kusata',
      debugShowCheckedModeBanner: false,
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

        // ✅ NUEVA RUTA AGREGADA
        AppRoutes.providerRegistrationForm: (context) =>
            const ProviderRegistrationForm(),
      },
    );
  }
}
