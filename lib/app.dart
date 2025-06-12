import 'package:flutter/material.dart'; // ⭐ AGREGAR ESTO
import 'core/constants/app_routes.dart';
import 'screens/common/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/provider_registration_form.dart';
import 'screens/client/profile_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/provider/provider_dashboard.dart';
import 'screens/provider/provider_services.dart';
import 'screens/provider/provider_bookings.dart';
import 'screens/common/map_screen.dart';
import 'screens/client/chat_screen.dart';
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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.bookingForm: (context) => const BookingFormScreen(),
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
