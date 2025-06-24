import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _isInitialized = false;

  // ✅ Usar directamente las instancias (sin null safety complicado)
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // ✅ Getter simple para verificar estado
  static bool get isInitialized => _isInitialized;

  // ✅ Inicialización simplificada que se ejecuta después de Firebase.initializeApp()
  static Future<bool> initialize() async {
    try {
      // Verificar si Firebase ya está inicializado
      if (_isInitialized) {
        if (kDebugMode) {
          debugPrint('✅ FirebaseService ya está inicializado');
        }
        return true;
      }

      // Firebase.initializeApp() ya debe haberse ejecutado en main.dart
      // Solo verificamos que esté disponible
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ Firebase.initializeApp() no se ha ejecutado');
        }
        return false;
      }

      // Inicializar mensajería si está disponible
      await _initializeMessaging();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ FirebaseService inicializado correctamente');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al inicializar FirebaseService: $e');
      }
      _isInitialized = false;
      return false;
    }
  }

  static Future<void> _initializeMessaging() async {
    try {
      // Solicitar permisos para notificaciones
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          debugPrint('✅ Usuario autorizó las notificaciones');
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        if (kDebugMode) {
          debugPrint('✅ Usuario autorizó las notificaciones provisionales');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Usuario denegó las notificaciones');
        }
      }

      // Obtener token FCM
      String? token = await messaging.getToken();
      if (kDebugMode) {
        debugPrint('📱 FCM Token: $token');
      }

      // Configurar manejo de mensajes en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('📩 Mensaje recibido: ${message.notification?.title}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al inicializar messaging: $e');
      }
    }
  }

  // ✅ Colecciones simplificadas (sin verificaciones complicadas)
  static CollectionReference get usersCollection {
    return firestore.collection('users');
  }

  static CollectionReference get servicesCollection {
    return firestore.collection('services');
  }

  static CollectionReference get bookingsCollection {
    return firestore.collection('bookings');
  }

  static CollectionReference get reviewsCollection {
    return firestore.collection('reviews');
  }

  static CollectionReference get chatsCollection {
    return firestore.collection('chats');
  }

  // ✅ Método de utilidad para verificar si todo está listo
  static Future<bool> ensureInitialized() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return true;
  }
}
