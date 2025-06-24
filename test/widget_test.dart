
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_manachyna_kusa_2_0/app.dart';
import 'package:flutter_application_manachyna_kusa_2_0/proveedores/proveedor_autenticacion.dart';
import 'package:flutter_application_manachyna_kusa_2_0/pantallas/proveedor/servicios_proveedor/proveedores/proveedor_servicios.dart';
import 'package:flutter_application_manachyna_kusa_2_0/proveedores/proveedor_reservas.dart';
import 'package:flutter_application_manachyna_kusa_2_0/proveedores/proveedor_usuarios.dart';
void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProveedorServicio()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const ManachiyKanKusataApp(),
      ),
    );

    // Verify that the splash screen loads
    expect(find.text('Mañachiy kan Kusata'), findsOneWidget);
    expect(find.text('Servicios del hogar en Napo'), findsOneWidget);
    expect(find.text('Cargando...'), findsOneWidget);
  });

  testWidgets('App shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProveedorServicio()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const ManachiyKanKusataApp(),
      ),
    );

    // Verify that loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
