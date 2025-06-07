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

  // Registrar usuario
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

      // Guardar datos del usuario en Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } catch (e) {
      if (kDebugMode) print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Iniciar sesión
  static Future<UserModel?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener datos del usuario desde Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print('Error al cerrar sesión: $e');
    }
  }

  // Obtener datos del usuario actual
  static Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser!.uid).get();

        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // Actualizar perfil de usuario
  static Future<bool> updateUserProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toMap());
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al actualizar perfil: $e');
      return false;
    }
  }
// AGREGAR ESTE MÉTODO AL FINAL DE TU AuthService EXISTENTE

  /// Actualiza solo la imagen de perfil del usuario
  static Future<bool> updateProfileImage(String userId, String imageUrl) async {
    try {
      print('🔄 Actualizando imagen en Firestore para usuario: $userId');

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Imagen actualizada en Firestore');
      return true;
    } catch (e) {
      print('❌ Error updating profile image in Firestore: $e');
      return false;
    }
  }

  // Restablecer contraseña
  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al enviar email de restablecimiento: $e');
      return false;
    }
  }
}
