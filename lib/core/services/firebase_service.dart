import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseMessaging? _messaging;

  static FirebaseAuth get auth {
    if (!_isInitialized) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (!_isInitialized) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!;
  }

  static FirebaseStorage get storage {
    if (!_isInitialized) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _storage!;
  }

  static FirebaseMessaging get messaging {
    if (!_isInitialized) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _messaging!;
  }

  static Future<bool> initialize() async {
    try {
      // Verificar si Firebase ya está inicializado
      if (_isInitialized) {
        print('Firebase ya está inicializado');
        return true;
      }

      // Verificar si Firebase está inicializado a nivel de app
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Inicializar servicios
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;

      // Inicializar mensajería
      await _initializeMessaging();

      _isInitialized = true;
      print('Firebase Service inicializado correctamente');
      return true;
    } catch (e) {
      print('Error al inicializar Firebase Service: $e');
      _isInitialized = false;
      return false;
    }
  }

  static Future<void> _initializeMessaging() async {
    try {
      if (_messaging == null) {
        print('Messaging no está disponible');
        return;
      }

      // Solicitar permisos para notificaciones
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Usuario autorizó las notificaciones');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('Usuario autorizó las notificaciones provisionales');
      } else {
        print('Usuario denegó las notificaciones');
      }

      // Obtener token FCM
      String? token = await _messaging!.getToken();
      print('FCM Token: $token');

      // Configurar manejo de mensajes en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Mensaje recibido en primer plano: ${message.notification?.title}');
      });
    } catch (e) {
      print('Error al inicializar messaging: $e');
    }
  }

  // Colecciones de Firestore
  static CollectionReference get usersCollection {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!.collection('users');
  }

  static CollectionReference get servicesCollection {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!.collection('services');
  }

  static CollectionReference get bookingsCollection {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!.collection('bookings');
  }

  static CollectionReference get reviewsCollection {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!.collection('reviews');
  }

  static CollectionReference get chatsCollection {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase no está inicializado. Llama a initialize() primero.');
    }
    return _firestore!.collection('chats');
  }
}
