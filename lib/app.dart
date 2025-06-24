import 'package:flutter/material.dart';
import 'nucleo/constantes/rutas_app.dart';
import 'pantallas/comunes/pantalla_carga.dart';
import 'pantallas/autenticacion/pantalla_inicio_sesion.dart';
import 'pantallas/autenticacion/pantalla_registro.dart';
import 'pantallas/autenticacion/formulario_registro_proveedor.dart';
import 'pantallas/cliente/pantalla_perfil.dart';
import 'pantallas/cliente/pantalla_inicio.dart';
import 'pantallas/cliente/client/reservas/pantalla_formulario_reserva.dart';
import 'pantallas/cliente/client/reservas/pantalla_detalle_reserva.dart';
import 'pantallas/proveedor/tablero_proveedor.dart';
import 'pantallas/proveedor/servicios_proveedor.dart';
import 'pantallas/comunes/pantalla_mapa.dart';
import 'pantallas/cliente/pantalla_chat.dart';
import 'pantallas/proveedor/pantalla_inicio_proveedor.dart';
import 'pantallas/administrador/pantalla_inicio_administrador.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pantallas/cliente/reservas_cliente.dart';

class ManachiyKanKusataApp extends StatelessWidget {
  const ManachiyKanKusataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mañachiy kan Kusata',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      
      initialRoute: AppRoutes.splash,
      
      routes: {
        // 🔹 AUTENTICACIÓN
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        
        // 🔹 CLIENTE
        AppRoutes.home: (context) => const PantallaInicioCliente(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        
        // 🔹 RESERVAS
        AppRoutes.bookings: (context) => const PantallaListaReservas(),
        AppRoutes.bookingForm: (context) => const PantallaFormularioReserva(),
        AppRoutes.bookingDetail: (context) => const PantallaDetalleReserva(),
        
        // 🔹 PROVEEDOR
        AppRoutes.providerHome: (context) => const ProviderHomeScreen(),
        AppRoutes.providerDashboard: (context) => const ProviderDashboard(),
        AppRoutes.providerServices: (context) => const ProviderServices(),
        AppRoutes.providerBookings: (context) => const PantallaListaReservas(),
        AppRoutes.providerRegistrationForm: (context) => const ProviderRegistrationForm(),
        
        // 🔹 ADMINISTRADOR
        AppRoutes.adminHome: (context) => const AdminHomeScreen(),
        
        // 🔹 COMUNES
        AppRoutes.map: (context) => const MapScreen(),
        AppRoutes.chat: (context) => const ChatScreen(),
      },
    );
  }
}