import 'package:flutter/material.dart'; // ⭐ AGREGAR ESTO
import 'nucleo/constantes/rutas_app.dart';
import 'pantallas/comunes/pantalla_carga.dart';
import 'pantallas/autenticacion/pantalla_inicio_sesion.dart';
import 'pantallas/autenticacion/pantalla_registro.dart';
import 'pantallas/autenticacion/formulario_registro_proveedor.dart';
import 'pantallas/cliente/pantalla_perfil.dart';
import 'pantallas/cliente/pantalla_inicio.dart';
import 'pantallas/reservas/pantalla_formulario_reserva.dart';
import 'pantallas/reservas/pantalla_detalle_reserva.dart';
import 'pantallas/proveedor/tablero_proveedor.dart';
import 'pantallas/proveedor/servicios_proveedor.dart';
import 'pantallas/proveedor/reservas_proveedor.dart';
import 'pantallas/comunes/pantalla_mapa.dart';
import 'pantallas/cliente/pantalla_chat.dart';
import 'pantallas/proveedor/pantalla_inicio_proveedor.dart';
import 'pantallas/administrador/pantalla_inicio_administrador.dart';
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
