import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'opciones_firebase.dart';
import 'proveedores/proveedor_autenticacion.dart';
import 'proveedores/proveedor_servicios.dart';
import 'proveedores/proveedor_reservas.dart';
import 'proveedores/proveedor_usuarios.dart';
import 'nucleo/servicios/servicio_firebase.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Inicializar Firebase Core
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Inicializar FirebaseService (esto es lo que faltaba!)
    await FirebaseService.initialize();

    // Solo mostrar logs en modo debug
    if (kDebugMode) {
      debugPrint("🔥 Firebase y FirebaseService inicializados correctamente");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ServiceProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const ManachiyKanKusataApp(),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint("❌ Error al inicializar Firebase: $e");
    }
    // Mostrar una pantalla de error o app básica
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error al inicializar la aplicación\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

