// lib/core/services/image_picker_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Muestra diálogo para seleccionar fuente de imagen
  static Future<File?> showImageSourceSelection(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Seleccionar imagen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSourceOption(
                          context,
                          icon: Icons.camera_alt,
                          label: 'Cámara',
                          onTap: () async {
                            Navigator.pop(context);
                            final file = await pickImageFromCamera();
                            if (context.mounted) {
                              Navigator.pop(context, file);
                            }
                          },
                        ),
                        _buildSourceOption(
                          context,
                          icon: Icons.photo_library,
                          label: 'Galería',
                          onTap: () async {
                            Navigator.pop(context);
                            final file = await pickImageFromGallery();
                            if (context.mounted) {
                              Navigator.pop(context, file);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Selecciona imagen desde la cámara (image_picker maneja permisos automáticamente)
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile == null) return null;

      // Procesar y optimizar imagen
      return await _processImage(File(pickedFile.path));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al tomar foto: $e');
      }
      rethrow;
    }
  }

  /// Selecciona imagen desde la galería (image_picker maneja permisos automáticamente)
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile == null) return null;

      // Procesar y optimizar imagen
      return await _processImage(File(pickedFile.path));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al seleccionar de galería: $e');
      }
      rethrow;
    }
  }

  /// Procesa y optimiza la imagen seleccionada
  static Future<File> _processImage(File imageFile) async {
    try {
      // Leer imagen
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es muy grande (máximo 800x800 para perfil)
      if (originalImage.width > 800 || originalImage.height > 800) {
        originalImage = img.copyResize(
          originalImage,
          width: 800,
          height: 800,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convertir a JPEG con compresión
      final Uint8List processedBytes = Uint8List.fromList(img.encodeJpg(
        originalImage,
        quality: 85,
      ));

      // Guardar imagen procesada
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File processedFile = File(path.join(tempDir.path, fileName));

      await processedFile.writeAsBytes(processedBytes);

      if (kDebugMode) {
        final int originalSize = imageBytes.length;
        final int newSize = processedBytes.length;
        final double compressionRatio =
            ((originalSize - newSize) / originalSize * 100);
        debugPrint(
            '✅ Imagen procesada: ${compressionRatio.toStringAsFixed(1)}% reducción');
        debugPrint(
            '   Tamaño original: ${(originalSize / 1024).toStringAsFixed(1)} KB');
        debugPrint(
            '   Tamaño final: ${(newSize / 1024).toStringAsFixed(1)} KB');
      }

      return processedFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al procesar imagen: $e');
      }
      throw Exception('Error al procesar imagen: $e');
    }
  }

  /// Verifica si una imagen es válida
  static Future<bool> isValidImage(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tamaño de archivo en MB
  static Future<double> getFileSizeInMB(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }
}
