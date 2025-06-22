// PARTE 1: IMPORTS Y ESTADO DE LA CLASE

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../nucleo/widgets/widget_cargando.dart';
import '../../../nucleo/servicios/servicio_almacenamiento.dart';
import '../../../nucleo/servicios/servicio_selector_imagenes.dart';
import '../../../proveedores/proveedor_autenticacion.dart';
import '../../../modelos/modelo_usuario.dart';

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
  // PARTE 2: BUILD PRINCIPAL SIMPLIFICADO

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Estados de carga y error
          if (!authProvider.isInitialized) {
            return const Center(
              child: LoadingWidget(message: 'Inicializando...'),
            );
          }

          if (authProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: 'Cargando perfil...'),
            );
          }

          final user = authProvider.currentUser;
          if (user == null) {
            return _buildErrorState(authProvider);
          }

          return LoadingOverlay(
            isLoading: _isLoading,
            message: 'Actualizando perfil...',
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(user),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileStats(user),
                      const SizedBox(height: 16),
                      // Solo mostrar acciones cuando NO está editando
                      if (!_isEditing) ...[
                        _buildQuickActions(user),
                        const SizedBox(height: 24),
                      ],
                      // Mostrar formulario de edición cuando SÍ está editando
                      if (_isEditing) ...[
                        _buildEditingForm(user),
                        const SizedBox(height: 24),
                      ],
                      // Siempre mostrar sección de proveedor si aplica
                      if (user.userType == UserType.provider)
                        Column(
                          children: [
                            _buildProviderSection(user),
                            const SizedBox(height: 24),
                          ],
                        ),
                      // Solo mostrar configuración cuando NO está editando
                      if (!_isEditing) _buildSettingsSection(),
                      const SizedBox(height: 32),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  // PARTE 3: APPBAR CORREGIDO SIN SUPERPOSICIÓN

  Widget _buildModernAppBar(UserModel user) {
    return SliverAppBar(
      expandedHeight: 240, // Reducido de 280 a 240
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1B365D),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B365D),
                Color(0xFF2563EB),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25), // Reducido de 40 a 25
                  _buildEnhancedProfileImage(user),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildUserBadges(user),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      actions: [
        // Solo mostrar icono de editar si no estamos editando
        if (!_isEditing)
          IconButton(
            onPressed: () {
              setState(() => _isEditing = true);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildUserBadges(UserModel user) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        _buildUserBadge(
          user.userType == UserType.provider ? 'Proveedor' : 'Cliente',
          user.userType == UserType.provider
              ? Icons.business_center
              : Icons.person,
        ),
        if (user.userType == UserType.provider && user.rating > 0)
          _buildUserBadge(
            '${user.rating.toStringAsFixed(1)} ⭐',
            Icons.star,
          ),
      ],
    );
  }

  Widget _buildUserBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AuthProvider authProvider) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar el perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por favor, intenta nuevamente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await authProvider.refreshUserData();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          authProvider.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B365D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Volver al login'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // PARTE 4: MANEJO DE IMAGEN DE PERFIL

  Widget _buildEnhancedProfileImage(UserModel user) {
    return GestureDetector(
      onTap: _isEditing && !_isUploadingImage ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                  color: Colors.black.withOpacity(0.7),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: _uploadProgress,
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
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
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent(UserModel user) {
    // Imagen local seleccionada
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    // Imagen de perfil desde red
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
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
              strokeWidth: 3,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B365D).withOpacity(0.8),
            const Color(0xFF2563EB).withOpacity(0.8),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  /// Selecciona y sube una imagen de perfil
  Future<void> _pickImage() async {
    try {
      final File? imageFile =
          await ImagePickerService.showImageSourceSelection(context);

      if (imageFile != null) {
        final double fileSizeInMB =
            await ImagePickerService.getFileSizeInMB(imageFile);
        if (fileSizeInMB > 5) {
          _showSnackBar('La imagen es muy grande. Máximo 5MB permitido.');
          return;
        }

        if (!await ImagePickerService.isValidImage(imageFile)) {
          _showSnackBar('Archivo no válido. Selecciona una imagen.');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });

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

      final String imageUrl = await StorageService.uploadProfileImage(
        userId: user.id,
        imageFile: _selectedImage!,
        onProgress: (double progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
        await StorageService.deleteProfileImage(user.profileImageUrl!);
      }

      bool success = await authProvider.updateProfileImageUrl(imageUrl);

      if (success) {
        _showSnackBar('Imagen de perfil actualizada', isSuccess: true);
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
  // PARTE 5: ESTADÍSTICAS AJUSTADAS SIN SUPERPOSICIÓN

  Widget _buildProfileStats(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      transform: Matrix4.translationValues(0, -15, 0), // Reducido de -30 a -15
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: user.userType == UserType.provider
            ? _buildProviderStats(user)
            : _buildClientStats(user),
      ),
    );
  }

  Widget _buildProviderStats(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '${user.rating.toStringAsFixed(1)}',
            'Calificación',
            Icons.star_rounded,
            const Color(0xFFF59E0B),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE5E7EB),
        ),
        Expanded(
          child: _buildStatItem(
            '${user.totalRatings}',
            'Reseñas',
            Icons.rate_review_rounded,
            const Color(0xFF10B981),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE5E7EB),
        ),
        Expanded(
          child: _buildStatItem(
            '${user.services.length}',
            'Servicios',
            Icons.work_rounded,
            const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildClientStats(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '12',
            'Reservas',
            Icons.event_available_rounded,
            const Color(0xFF2563EB),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE5E7EB),
        ),
        Expanded(
          child: _buildStatItem(
            '5',
            'Favoritos',
            Icons.favorite_rounded,
            const Color(0xFFEF4444),
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE5E7EB),
        ),
        Expanded(
          child: _buildStatItem(
            '8',
            'Reseñas',
            Icons.star_rounded,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  // PARTE 6: ACCIONES RÁPIDAS (SOLO CUANDO NO ESTÁ EDITANDO)

  Widget _buildQuickActions(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Editar perfil',
                  'Actualiza tu información',
                  Icons.edit_rounded,
                  const Color(0xFF2563EB),
                  () {
                    setState(() => _isEditing = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  user.userType == UserType.provider
                      ? 'Mis servicios'
                      : 'Historial',
                  user.userType == UserType.provider
                      ? 'Gestiona servicios'
                      : 'Ver actividad',
                  user.userType == UserType.provider
                      ? Icons.business_center_rounded
                      : Icons.history_rounded,
                  const Color(0xFF10B981),
                  () {
                    _navigateToServices(user);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Configuración',
                  'Ajustes y privacidad',
                  Icons.settings_rounded,
                  const Color(0xFF6B7280),
                  () {
                    _navigateToSettings();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Ayuda',
                  'Soporte y preguntas',
                  Icons.help_rounded,
                  const Color(0xFF8B5CF6),
                  () {
                    _showHelpDialog();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Funciones de navegación y acciones
  void _navigateToServices(UserModel user) {
    if (user.userType == UserType.provider) {
      _showSnackBar('Navegando a gestión de servicios...', isSuccess: true);
      // Navigator.pushNamed(context, '/provider/services');
    } else {
      _showSnackBar('Mostrando historial de reservas...', isSuccess: true);
      // Navigator.pushNamed(context, '/client/history');
    }
  }

  void _navigateToSettings() {
    _showSnackBar('Abriendo configuración...', isSuccess: true);
    // Navigator.pushNamed(context, '/settings');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF8B5CF6),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Centro de Ayuda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aquí encontrarás respuestas a las preguntas más frecuentes y podrás contactar con soporte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Contactando con soporte...',
                            isSuccess: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Contactar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // PARTE 7: FORMULARIO DE EDICIÓN INTEGRADO (REEMPLAZA INFORMACIÓN PERSONAL)

  Widget _buildEditingForm(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildModernCard(
        'Editando Información Personal',
        Icons.edit_rounded,
        [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Modo de edición activado. Puedes cambiar tu foto tocándola.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildModernTextField(
            'Nombre completo',
            _nameController,
            Icons.person_outline,
            'Ingresa tu nombre completo',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Correo electrónico',
            _emailController,
            Icons.email_outlined,
            'tu@email.com',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Teléfono',
            _phoneController,
            Icons.phone_outlined,
            '+593 99 999 9999',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Dirección',
            _addressController,
            Icons.location_on_outlined,
            'Tu dirección completa',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Ciudad',
            _cityController,
            Icons.location_city_outlined,
            'Tu ciudad',
          ),
          // Si es proveedor, mostrar también descripción
          if (user.userType == UserType.provider) ...[
            const SizedBox(height: 16),
            _buildModernTextField(
              'Descripción de servicios',
              _descriptionController,
              Icons.description_outlined,
              'Describe los servicios que ofreces...',
              maxLines: 4,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _loadUserData();
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TextField mejorado con mejor responsive design
  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 48,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Container(
                width: 48,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1B365D), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFEF4444), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
  // PARTE 8: SECCIÓN DE PROVEEDOR (SOLO LECTURA CUANDO NO ESTÁ EDITANDO)

  Widget _buildProviderSection(UserModel user) {
    // Solo mostrar cuando NO está editando (la descripción se edita en el formulario principal)
    if (_isEditing) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildModernCard(
        'Información del Proveedor',
        Icons.business_center_rounded,
        [
          _buildInfoRow(
            'Descripción',
            user.description?.isNotEmpty == true
                ? user.description!
                : 'No hay descripción disponible',
            Icons.description_outlined,
          ),
          if (user.services.isNotEmpty) ...[
            _buildDivider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B365D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: Color(0xFF1B365D),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Servicios ofrecidos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.services
                    .map((service) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B365D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    const Color(0xFF1B365D).withOpacity(0.2)),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              color: Color(0xFF1B365D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // InfoRow mejorado con mejor layout
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1B365D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B365D),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Divider mejorado
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
  // PARTE 9: CONFIGURACIÓN Y WIDGETS HELPER

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildModernCard(
        'Configuración',
        Icons.settings_rounded,
        [
          _buildSettingItem(
            'Cambiar contraseña',
            'Actualiza tu contraseña de acceso',
            Icons.lock_outline,
            () => _showChangePasswordDialog(),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Notificaciones',
            'Configura tus preferencias',
            Icons.notifications_outlined,
            () => _showNotificationSettings(),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Privacidad',
            'Gestiona tu privacidad',
            Icons.privacy_tip_outlined,
            () => _showPrivacySettings(),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Ayuda y soporte',
            'Obtén ayuda cuando la necesites',
            Icons.help_outline,
            () => _showHelpDialog(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFEF4444)),
                foregroundColor: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card moderno mejorado con mejor responsive design
  Widget _buildModernCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B365D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1B365D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // Action card mejorado con animaciones
  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Setting item mejorado
  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B365D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1B365D),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  // PARTE 10: FUNCIONES DE CONFIGURACIÓN, VALIDACIÓN Y LOADINGOVERLAY COMPLETO

  // Funciones de configuración con funcionalidad
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B365D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF1B365D),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Se enviará un enlace a tu correo para cambiar la contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Enlace enviado a tu correo',
                            isSuccess: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B365D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Enviar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildNotificationOption('Nuevas reservas', true),
            _buildNotificationOption('Mensajes', true),
            _buildNotificationOption('Promociones', false),
            _buildNotificationOption('Recordatorios', true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar('Configuración guardada', isSuccess: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar cambios'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
              Switch(
                value: value,
                onChanged: (newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
                activeColor: const Color(0xFF1B365D),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacySettings() {
    _showSnackBar('Abriendo configuración de privacidad...', isSuccess: true);
  }

  /// Función para cerrar sesión con confirmación
  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Estás seguro que deseas cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función de validación mejorada
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('El nombre es requerido');
      return false;
    }

    if (_nameController.text.trim().length < 2) {
      _showSnackBar('El nombre debe tener al menos 2 caracteres');
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

    if (_phoneController.text.trim().isNotEmpty &&
        !RegExp(r'^[\+]?[0-9]{10,15}$')
            .hasMatch(_phoneController.text.trim().replaceAll(' ', ''))) {
      _showSnackBar('Número de teléfono inválido');
      return false;
    }

    return true;
  }

  // SnackBar mejorado con mejor diseño
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isSuccess ? 2 : 3),
        elevation: 8,
      ),
    );
  }

  // Función de guardado mejorada con mejor manejo de errores
  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    // Ocultar teclado
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      final currentUser = authProvider.currentUser!;

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
        setState(() {
          _isEditing = false;
        });

        _showSnackBar('Perfil actualizado correctamente', isSuccess: true);
      } else {
        _showSnackBar('Error al actualizar perfil');
      }
    } catch (e) {
      _showSnackBar('Error al actualizar perfil: ${e.toString()}');
      debugPrint('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            color: backgroundColor ?? Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF1B365D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message ?? 'Cargando...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
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
