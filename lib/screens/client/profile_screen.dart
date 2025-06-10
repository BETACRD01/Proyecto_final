import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Estados locales
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  File? _selectedImage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _cityController.text = user.city;
        _descriptionController.text = user.description ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Selecciona y sube una imagen de perfil
  Future<void> _pickImage() async {
    try {
      // Mostrar diálogo de selección de imagen
      final File? imageFile =
          await ImagePickerService.showImageSourceSelection(context);

      if (imageFile != null) {
        // Validar tamaño de archivo (máximo 5MB)
        final double fileSizeInMB =
            await ImagePickerService.getFileSizeInMB(imageFile);
        if (fileSizeInMB > 5) {
          _showSnackBar('La imagen es muy grande. Máximo 5MB permitido.');
          return;
        }

        // Validar que sea una imagen válida
        if (!await ImagePickerService.isValidImage(imageFile)) {
          _showSnackBar('Archivo no válido. Selecciona una imagen.');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });

        // Subir imagen automáticamente
        await _uploadProfileImage();
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar imagen: $e');
    }
  }

  /// Sube la imagen de perfil a Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
      _uploadProgress = 0.0;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Subir imagen con seguimiento de progreso
      final String imageUrl = await StorageService.uploadProfileImage(
        userId: user.id,
        imageFile: _selectedImage!,
        onProgress: (double progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Eliminar imagen anterior si existe
      if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
        await StorageService.deleteProfileImage(user.profileImageUrl!);
      }

      // Actualizar usuario con nueva URL
      bool success = await authProvider.updateProfileImageUrl(imageUrl);

      if (success) {
        _showSnackBar('Imagen de perfil actualizada', isSuccess: true);

        // Limpiar imágenes antiguas en background
        StorageService.cleanupOldImages(user.id);
      } else {
        _showSnackBar('Error al actualizar la imagen en el perfil');
      }
    } catch (e) {
      _showSnackBar('Error al subir imagen: $e');
    } finally {
      setState(() {
        _isUploadingImage = false;
        _uploadProgress = 0.0;
        _selectedImage = null;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      final currentUser = authProvider.currentUser!;

      // Crear usuario actualizado
      final userToUpdate = UserModel(
        id: currentUser.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        userType: currentUser.userType,
        profileImageUrl: currentUser.profileImageUrl, // Mantener imagen actual
        isActive: currentUser.isActive,
        rating: currentUser.rating,
        totalRatings: currentUser.totalRatings,
        services: currentUser.services,
        latitude: currentUser.latitude,
        longitude: currentUser.longitude,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
      );

      // Actualizar perfil
      bool success = await authProvider.updateProfile(userToUpdate);

      if (success) {
        setState(() {
          _isEditing = false;
        });

        _showSnackBar('Perfil actualizado correctamente', isSuccess: true);
      } else {
        _showSnackBar('Error al actualizar perfil');
      }
    } catch (e) {
      _showSnackBar('Error al actualizar perfil: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('El nombre es requerido');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('El email es requerido');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _showSnackBar('Email inválido');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Función para cerrar sesión con confirmación
  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  _showSnackBar('Error al cerrar sesión: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 1. Si AuthProvider no está inicializado, mostrar loading
          if (!authProvider.isInitialized) {
            return const Center(
              child: LoadingWidget(message: 'Inicializando...'),
            );
          }

          // 2. Si está cargando datos, mostrar loading
          if (authProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: 'Cargando perfil...'),
            );
          }

          // 3. Si no hay usuario después de la inicialización, mostrar error
          final user = authProvider.currentUser;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el perfil',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.refreshUserData();
                    },
                    child: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      authProvider.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text('Volver al login'),
                  ),
                ],
              ),
            );
          }

          // 4. Mostrar la interfaz normal con overlay de loading si está actualizando
          return LoadingOverlay(
            isLoading: _isLoading,
            message: 'Actualizando perfil...',
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildAppBar(user),
                ];
              },
              body: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPersonalInfoTab(user),
                        _buildActivityTab(user),
                        _buildSettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(UserModel? user) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildProfileImage(user),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.userType == UserType.provider)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Proveedor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
            if (!_isEditing) {
              // Si cancelamos edición, recargar datos
              _loadUserData();
            }
          },
          icon: Icon(
            _isEditing ? Icons.close : Icons.edit,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Widget de imagen de perfil con indicador de progreso
  Widget _buildProfileImage(UserModel? user) {
    return GestureDetector(
      onTap: _isEditing && !_isUploadingImage ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImageContent(user),
            ),
          ),

          // Indicador de progreso de subida
          if (_isUploadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress,
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Icono de cámara para edición
          if (_isEditing && !_isUploadingImage)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Contenido de la imagen (local, red o por defecto)
  Widget _buildImageContent(UserModel? user) {
    // Imagen local seleccionada
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    // Imagen de perfil desde red
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
      return Image.network(
        user.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      );
    }

    // Avatar por defecto
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 50,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(
            icon: Icon(Icons.person),
            text: 'Perfil',
          ),
          Tab(
            icon: Icon(Icons.history),
            text: 'Actividad',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Información Personal',
            [
              CustomTextField(
                label: 'Nombre completo',
                controller: _nameController,
                enabled: _isEditing,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                enabled: _isEditing,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Teléfono',
                controller: _phoneController,
                enabled: _isEditing,
                prefixIcon: Icons.phone,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Ubicación',
            [
              CustomTextField(
                label: 'Dirección',
                controller: _addressController,
                enabled: _isEditing,
                prefixIcon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Ciudad',
                controller: _cityController,
                enabled: _isEditing,
                prefixIcon: Icons.location_city,
              ),
            ],
          ),
          if (user?.userType == UserType.provider) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              'Información del Proveedor',
              [
                CustomTextField(
                  label: 'Descripción de servicios',
                  controller: _descriptionController,
                  enabled: _isEditing,
                  prefixIcon: Icons.description,
                  maxLines: 4,
                ),
                if (!_isEditing &&
                    user != null &&
                    user.services.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Servicios ofrecidos:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.services
                        .map((service) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                service,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _selectedImage = null;
                      });
                      _loadUserData();
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Guardar',
                    onPressed: _isLoading ? null : _saveProfile,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTab(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (user?.userType == UserType.provider) ...[
            _buildStatCard('Calificación Promedio',
                user?.rating.toStringAsFixed(1) ?? '0.0', Icons.star),
            const SizedBox(height: 12),
            _buildStatCard('Total de Calificaciones',
                user?.totalRatings.toString() ?? '0', Icons.rate_review),
            const SizedBox(height: 12),
            _buildStatCard('Servicios Ofrecidos',
                user?.services.length.toString() ?? '0', Icons.work),
          ] else ...[
            _buildStatCard('Reservas Realizadas', '12', Icons.event_available),
            const SizedBox(height: 12),
            _buildStatCard('Servicios Favoritos', '5', Icons.favorite),
            const SizedBox(height: 12),
            _buildStatCard('Reseñas Escritas', '8', Icons.star),
          ],
          const SizedBox(height: 24),
          _buildSectionCard(
            'Actividad Reciente',
            [
              _buildActivityItem(
                user?.userType == UserType.provider
                    ? 'Nuevo servicio registrado'
                    : 'Reservaste un servicio de "Limpieza de hogar"',
                'Hace 2 días',
                user?.userType == UserType.provider
                    ? Icons.add_business
                    : Icons.cleaning_services,
              ),
              _buildActivityItem(
                user?.userType == UserType.provider
                    ? 'Recibiste una nueva calificación'
                    : 'Dejaste una reseña para "Jardinería Pro"',
                'Hace 1 semana',
                Icons.rate_review,
              ),
              _buildActivityItem(
                'Te registraste en la aplicación',
                'Hace ${DateTime.now().difference(user?.createdAt ?? DateTime.now()).inDays} días',
                Icons.person_add,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            'Notificaciones',
            [
              _buildSettingItem(
                'Notificaciones push',
                'Recibir notificaciones de la app',
                true,
                (value) {},
              ),
              _buildSettingItem(
                'Notificaciones por email',
                'Recibir emails sobre tu actividad',
                false,
                (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Privacidad',
            [
              _buildSettingItem(
                'Perfil público',
                'Otros usuarios pueden ver tu perfil',
                true,
                (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Cuenta',
            [
              ListTile(
                leading: const Icon(Icons.key, color: AppColors.primary),
                title: const Text('Cambiar contraseña'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help, color: AppColors.primary),
                title: const Text('Ayuda y soporte'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading:
                    const Icon(Icons.privacy_tip, color: AppColors.primary),
                title: const Text('Política de privacidad'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Botón de cerrar sesión
          CustomButton(
            text: 'Cerrar Sesión',
            onPressed: _logout,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// Widget LoadingOverlay personalizado
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      message ?? 'Cargando...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
