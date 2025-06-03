// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_manachyna_kusa_2_0/app.dart';
import 'package:flutter_application_manachyna_kusa_2_0/providers/auth_provider.dart';
import 'package:flutter_application_manachyna_kusa_2_0/providers/service_provider.dart';
import 'package:flutter_application_manachyna_kusa_2_0/providers/booking_provider.dart';
import 'package:flutter_application_manachyna_kusa_2_0/providers/user_provider.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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
          ChangeNotifierProvider(create: (_) => ServiceProvider()),
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
