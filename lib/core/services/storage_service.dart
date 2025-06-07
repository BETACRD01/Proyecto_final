// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen de perfil y retorna la URL de descarga
  static Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      // Generar nombre único para el archivo
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final String filePath = 'profile_images/$userId/$fileName';

      // Referencia al archivo en Storage
      final Reference ref = _storage.ref().child(filePath);

      // Configurar metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir archivo con seguimiento de progreso
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Escuchar progreso si se proporciona callback
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Esperar a que termine la subida
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Imagen subida exitosamente: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Error Firebase Storage: ${e.code} - ${e.message}');
      }
      throw _handleStorageError(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error general Storage: $e');
      }
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Elimina una imagen de perfil anterior
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      // Obtener referencia desde URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      if (kDebugMode) {
        print('✅ Imagen eliminada: $imageUrl');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // La imagen ya no existe, no es un error crítico
        if (kDebugMode) {
          print('⚠️ Imagen no encontrada para eliminar: $imageUrl');
        }
        return;
      }
      if (kDebugMode) {
        print('❌ Error al eliminar imagen: ${e.code} - ${e.message}');
      }
      // No lanzamos excepción para no bloquear el proceso
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error general al eliminar: $e');
      }
    }
  }

  /// Obtiene todas las imágenes de perfil de un usuario
  static Future<List<String>> getUserProfileImages(String userId) async {
    try {
      final Reference ref = _storage.ref().child('profile_images/$userId');
      final ListResult result = await ref.listAll();

      List<String> imageUrls = [];
      for (Reference imageRef in result.items) {
        final String url = await imageRef.getDownloadURL();
        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener imágenes: $e');
      }
      return [];
    }
  }

  /// Limpia imágenes antiguas del usuario (mantiene solo las últimas 3)
  static Future<void> cleanupOldImages(String userId) async {
    try {
      final Reference ref = _storage.ref().child('profile_images/$userId');
      final ListResult result = await ref.listAll();

      if (result.items.length <= 3) return;

      // Ordenar por fecha de creación y eliminar las más antiguas
      final List<Reference> sortedItems = result.items.toList();
      sortedItems.sort((a, b) => a.name.compareTo(b.name));

      // Eliminar todas excepto las últimas 3
      for (int i = 0; i < sortedItems.length - 3; i++) {
        await sortedItems[i].delete();
      }

      if (kDebugMode) {
        print(
            '✅ Limpieza completada. Eliminadas ${sortedItems.length - 3} imágenes antiguas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en limpieza: $e');
      }
    }
  }

  /// Maneja errores específicos de Firebase Storage
  static Exception _handleStorageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return Exception('No tienes permisos para subir imágenes');
      case 'canceled':
        return Exception('Subida cancelada');
      case 'unknown':
        return Exception('Error desconocido al subir imagen');
      case 'object-not-found':
        return Exception('Archivo no encontrado');
      case 'bucket-not-found':
        return Exception('Bucket de almacenamiento no encontrado');
      case 'project-not-found':
        return Exception('Proyecto Firebase no encontrado');
      case 'quota-exceeded':
        return Exception('Cuota de almacenamiento excedida');
      case 'unauthenticated':
        return Exception('Usuario no autenticado');
      case 'retry-limit-exceeded':
        return Exception('Límite de reintentos excedido');
      case 'invalid-checksum':
        return Exception('Archivo corrupto');
      case 'canceled':
        return Exception('Operación cancelada');
      default:
        return Exception('Error de almacenamiento: ${e.message}');
    }
  }
}
