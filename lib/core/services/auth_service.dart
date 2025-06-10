import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import 'firebase_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseService.auth;
  static FirebaseFirestore get _firestore => FirebaseService.firestore;

  // Obtener usuario actual
  static User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 MÉTODO HELPER PARA ELEGIR COLECCIÓN SEGÚN TIPO DE USUARIO
  static String _getCollectionName(UserType userType) {
    switch (userType) {
      case UserType.client:
        return 'users'; // ← Solo clientes regulares
      case UserType.provider:
        return 'providers'; // ← Proveedores separados
      case UserType.admin:
        return 'admins'; // ← Admins separados
    }
  }

  // 🔹 REGISTRAR USUARIO (CON COLECCIONES SEPARADAS) - MÉTODO ORIGINAL
  static Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required UserType userType,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear modelo de usuario
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        userType: userType,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // 🔥 GUARDAR EN LA COLECCIÓN CORRESPONDIENTE
      String collection = _getCollectionName(userType);

      await _firestore
          .collection(collection)
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      if (kDebugMode) {
        print(
            '✅ Usuario ${userType.name} registrado en colección: $collection');
      }

      return userModel;
    } catch (e) {
      if (kDebugMode) print('❌ Error al registrar usuario: $e');
      return null;
    }
  }

  // 🔹 NUEVO MÉTODO PARA REGISTRO CON DATOS EXTRA
  static Future<UserModel?> registerUserWithExtraData(
      Map<String, dynamic> userData) async {
    try {
      print('🚀 Registrando con datos extras: ${userData['email']}');
      print('📋 Tipo de usuario: ${userData['userType']}');

      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      print('✅ Usuario creado en Firebase Auth: ${userCredential.user!.uid}');

      // Crear UserModel con datos básicos
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        address: userData['address'] ?? '',
        city: userData['city'] ?? '',
        userType: userData['userType'] ?? UserType.client,
        createdAt: DateTime.now(),
        isActive: true,
        // 🔧 CORREGIR: Forzar tipo String explícitamente
        services: userData['services'] != null &&
                userData['services'].toString().isNotEmpty
            ? userData['services']
                .toString()
                .split(',')
                .map<String>((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : <String>[],
        description: userData['services']?.toString(),
      );

      print('📄 Modelo de usuario creado');

      // Determinar colección de destino
      String collection = _getCollectionName(userData['userType']);
      print('📁 Colección destino: $collection');

      // Crear mapa completo con datos del UserModel
      Map<String, dynamic> fullData = userModel.toMap();

      // 🔹 AGREGAR CAMPOS ADICIONALES ESPECÍFICOS
      fullData.addAll({
        'cedula': userData['cedula'] ?? '',
        'dateOfBirth': userData['dateOfBirth'] ?? '',
      });

      // 🔹 SI ES PROVEEDOR, AGREGAR CAMPOS PROFESIONALES
      if (userData['userType'] == UserType.provider) {
        fullData.addAll({
          'experience': userData['experience'] ?? '',
          'availability': userData['availability'] ?? '',
          'certifications': userData['certifications'] ?? '',
          'emergencyContact': userData['emergencyContact'] ?? '',
          'references': userData['references'] ?? '',
          'isVerified': false, // Los proveedores requieren verificación
          'verificationStatus': 'pending', // Estado de verificación
          'applicationDate': FieldValue.serverTimestamp(),
        });
      }

      print('💾 Guardando en Firestore...');
      await _firestore
          .collection(collection)
          .doc(userCredential.user!.uid)
          .set(fullData);

      // ✅ O SIMPLEMENTE ESTO:
      print('✅ Usuario registrado en colección: $collection');
      print('🎉 Registro completado exitosamente');

      return userModel;
    } catch (e) {
      print('❌ Error al registrar usuario: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // 🔹 INICIAR SESIÓN (BUSCA EN TODAS LAS COLECCIONES)
  static Future<UserModel?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 BUSCAR EN TODAS LAS COLECCIONES
      UserModel? userData =
          await _findUserInAllCollections(userCredential.user!.uid);

      if (userData != null) {
        if (kDebugMode) {
          print(
              '✅ Login exitoso para ${userData.userType.name}: ${userData.name}');
        }
      }

      return userData;
    } catch (e) {
      if (kDebugMode) print('❌ Error al iniciar sesión: $e');
      return null;
    }
  }

  // 🔹 BUSCAR USUARIO EN TODAS LAS COLECCIONES
  static Future<UserModel?> _findUserInAllCollections(String uid) async {
    try {
      // Lista de colecciones a buscar en orden de prioridad
      List<String> collections = ['users', 'providers', 'admins'];

      for (String collection in collections) {
        DocumentSnapshot doc =
            await _firestore.collection(collection).doc(uid).get();

        if (doc.exists) {
          if (kDebugMode) {
            print('👤 Usuario encontrado en colección: $collection');
          }
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }

      if (kDebugMode) {
        print('❌ Usuario no encontrado en ninguna colección');
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error buscando usuario: $e');
      return null;
    }
  }

  // 🔹 OBTENER DATOS DEL USUARIO ACTUAL
  static Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser != null) {
        return await _findUserInAllCollections(currentUser!.uid);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // 🔹 ACTUALIZAR PERFIL DE USUARIO
  static Future<bool> updateUserProfile(UserModel userModel) async {
    try {
      // Usar la colección correcta según el tipo de usuario
      String collection = _getCollectionName(userModel.userType);

      await _firestore
          .collection(collection)
          .doc(userModel.id)
          .update(userModel.toMap());

      if (kDebugMode) {
        print('✅ Perfil actualizado en colección: $collection');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error al actualizar perfil: $e');
      return false;
    }
  }

  // 🔹 ACTUALIZAR IMAGEN DE PERFIL
  static Future<bool> updateProfileImage(String userId, String imageUrl) async {
    try {
      if (kDebugMode) {
        print('🔄 Actualizando imagen en Firestore para usuario: $userId');
      }

      // Buscar en qué colección está el usuario
      UserModel? userData = await _findUserInAllCollections(userId);

      if (userData == null) {
        if (kDebugMode) print('❌ Usuario no encontrado para actualizar imagen');
        return false;
      }

      // Actualizar en la colección correcta
      String collection = _getCollectionName(userData.userType);

      await _firestore.collection(collection).doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Imagen actualizada en colección: $collection');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating profile image: $e');
      return false;
    }
  }

  // 🔹 CERRAR SESIÓN
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) print('✅ Sesión cerrada correctamente');
    } catch (e) {
      if (kDebugMode) print('❌ Error al cerrar sesión: $e');
    }
  }

  // 🔹 RESTABLECER CONTRASEÑA
  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) print('✅ Email de restablecimiento enviado');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error al enviar email de restablecimiento: $e');
      return false;
    }
  }

  // 🔹 MÉTODOS ESPECÍFICOS PARA OBTENER USUARIOS POR TIPO

  /// Obtiene todos los usuarios regulares (clientes)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo usuarios: $e');
      return [];
    }
  }

  /// Obtiene todos los proveedores
  static Future<List<UserModel>> getAllProviders() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('providers').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo proveedores: $e');
      return [];
    }
  }

  /// Obtiene todos los administradores
  static Future<List<UserModel>> getAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('admins').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo admins: $e');
      return [];
    }
  }

  // 🔹 VERIFICAR SI USUARIO EXISTE EN COLECCIÓN ESPECÍFICA
  static Future<bool> userExistsInCollection(
      String uid, UserType userType) async {
    try {
      String collection = _getCollectionName(userType);
      DocumentSnapshot doc =
          await _firestore.collection(collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) print('❌ Error verificando usuario: $e');
      return false;
    }
  }

  // 🔹 MIGRAR USUARIO A OTRA COLECCIÓN (Útil para cambios de rol)
  static Future<bool> migrateUserCollection(
      String uid, UserType fromType, UserType toType) async {
    try {
      // Obtener datos del usuario actual
      String fromCollection = _getCollectionName(fromType);
      DocumentSnapshot userDoc =
          await _firestore.collection(fromCollection).doc(uid).get();

      if (!userDoc.exists) {
        if (kDebugMode) print('❌ Usuario no encontrado en colección origen');
        return false;
      }

      // Obtener datos y actualizar tipo
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userData['userType'] = toType.name;

      // Guardar en nueva colección
      String toCollection = _getCollectionName(toType);
      await _firestore.collection(toCollection).doc(uid).set(userData);

      // Eliminar de colección anterior
      await _firestore.collection(fromCollection).doc(uid).delete();

      if (kDebugMode) {
        print('✅ Usuario migrado de $fromCollection a $toCollection');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error migrando usuario: $e');
      return false;
    }
  }

  // 🔹 MÉTODOS ESPECÍFICOS PARA PROVEEDORES

  /// Actualiza el estado de verificación de un proveedor
  static Future<bool> updateProviderVerificationStatus(
      String providerId, String status) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'verificationStatus': status,
        'verifiedAt':
            status == 'approved' ? FieldValue.serverTimestamp() : null,
        'isVerified': status == 'approved',
      });

      if (kDebugMode) {
        print('✅ Estado de verificación actualizado: $status');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error actualizando verificación: $e');
      return false;
    }
  }

  /// Obtiene proveedores por estado de verificación
  static Future<List<UserModel>> getProvidersByVerificationStatus(
      String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('providers')
          .where('verificationStatus', isEqualTo: status)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo proveedores por estado: $e');
      return [];
    }
  }
}
