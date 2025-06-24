// lib/pantallas/profile/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../nucleo/servicios/servicio_almacenamiento.dart';
import '../../../../nucleo/servicios/servicio_selector_imagenes.dart';
import '../../../../proveedores/proveedor_autenticacion.dart';
import '../../../../modelos/modelo_usuario.dart';
import 'utilidades_perfil.dart';

class ProfileController {
  final BuildContext context;
  final TickerProvider vsync;
  final VoidCallback onUpdate;

  // Controladores de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Estados
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  File? _selectedImage;

  // Getters
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;
  double get uploadProgress => _uploadProgress;
  File? get selectedImage => _selectedImage;

  ProfileController({
    required this.context,
    required this.vsync,
    required this.onUpdate,
  });

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    descriptionController.dispose();
  }

  // 🔗 LISTO PARA CONECTAR: Cargar datos del usuario
  void loadUserData() {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phone;
        addressController.text = user.address;
        cityController.text = user.city;
        descriptionController.text = user.description ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // 🎮 Control de edición
  void toggleEditing() {
    _isEditing = !_isEditing;
    onUpdate();
  }

  void cancelEditing() {
    _isEditing = false;
    _selectedImage = null;
    loadUserData(); // Restaurar datos originales
    onUpdate();
  }

  // 📷 Manejo de imagen de perfil
  Future<void> pickImage() async {
    try {
      final File? imageFile = await ImagePickerService.showImageSourceSelection(context);

      if (imageFile != null) {
        final double fileSizeInMB = await ImagePickerService.getFileSizeInMB(imageFile);
        if (fileSizeInMB > 5) {
          ProfileUtils.showSnackBar(context, 'La imagen es muy grande. Máximo 5MB permitido.');
          return;
        }

        if (!await ImagePickerService.isValidImage(imageFile)) {
          ProfileUtils.showSnackBar(context, 'Archivo no válido. Selecciona una imagen.');
          return;
        }

        _selectedImage = imageFile;
        onUpdate();

        await _uploadProfileImage();
      }
    } catch (e) {
      ProfileUtils.showSnackBar(context, 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    _isUploadingImage = true;
    _uploadProgress = 0.0;
    onUpdate();

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final String imageUrl = await StorageService.uploadProfileImage(
        userId: user.id,
        imageFile: _selectedImage!,
        onProgress: (double progress) {
          _uploadProgress = progress;
          onUpdate();
        },
      );

      if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
        await StorageService.deleteProfileImage(user.profileImageUrl!);
      }

      bool success = await authProvider.updateProfileImageUrl(imageUrl);

      if (success) {
        ProfileUtils.showSnackBar(context, 'Imagen de perfil actualizada', isSuccess: true);
        StorageService.cleanupOldImages(user.id);
      } else {
        ProfileUtils.showSnackBar(context, 'Error al actualizar la imagen en el perfil');
      }
    } catch (e) {
      ProfileUtils.showSnackBar(context, 'Error al subir imagen: $e');
    } finally {
      _isUploadingImage = false;
      _uploadProgress = 0.0;
      _selectedImage = null;
      onUpdate();
    }
  }

  // 💾 Guardar perfil
  Future<void> saveProfile() async {
    if (!_validateForm()) return;

    FocusScope.of(context).unfocus();

    _isLoading = true;
    onUpdate();

    try {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      final currentUser = authProvider.currentUser!;

      final userToUpdate = UserModel(
        id: currentUser.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        userType: currentUser.userType,
        profileImageUrl: currentUser.profileImageUrl,
        isActive: currentUser.isActive,
        rating: currentUser.rating,
        totalRatings: currentUser.totalRatings,
        services: currentUser.services,
        latitude: currentUser.latitude,
        longitude: currentUser.longitude,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = await authProvider.updateProfile(userToUpdate);

      if (success) {
        _isEditing = false;
        ProfileUtils.showSnackBar(context, 'Perfil actualizado correctamente', isSuccess: true);
      } else {
        ProfileUtils.showSnackBar(context, 'Error al actualizar perfil');
      }
    } catch (e) {
      ProfileUtils.showSnackBar(context, 'Error al actualizar perfil: ${e.toString()}');
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      onUpdate();
    }
  }

  // ✅ Validación de formulario
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      ProfileUtils.showSnackBar(context, 'El nombre es requerido');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      ProfileUtils.showSnackBar(context, 'El nombre debe tener al menos 2 caracteres');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      ProfileUtils.showSnackBar(context, 'El email es requerido');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      ProfileUtils.showSnackBar(context, 'Email inválido');
      return false;
    }

    if (phoneController.text.trim().isNotEmpty &&
        !RegExp(r'^[\+]?[0-9]{10,15}$')
            .hasMatch(phoneController.text.trim().replaceAll(' ', ''))) {
      ProfileUtils.showSnackBar(context, 'Número de teléfono inválido');
      return false;
    }

    return true;
  }

  // 🚀 Funciones de navegación y acciones
  void navigateToServices(UserModel user) {
    if (user.userType == UserType.provider) {
      ProfileUtils.showSnackBar(context, 'Navegando a gestión de servicios...', isSuccess: true);
      // 🔗 LISTO PARA CONECTAR: Navigator.pushNamed(context, '/provider/services');
    } else {
      ProfileUtils.showSnackBar(context, 'Mostrando historial de reservas...', isSuccess: true);
      // 🔗 LISTO PARA CONECTAR: Navigator.pushNamed(context, '/client/history');
    }
  }

  void navigateToSettings() {
    ProfileUtils.showSnackBar(context, 'Abriendo configuración...', isSuccess: true);
    // 🔗 LISTO PARA CONECTAR: Navigator.pushNamed(context, '/settings');
  }

  void showPrivacySettings() {
    ProfileUtils.showSnackBar(context, 'Abriendo configuración de privacidad...', isSuccess: true);
    // 🔗 LISTO PARA CONECTAR: Navigator.pushNamed(context, '/privacy');
  }
}