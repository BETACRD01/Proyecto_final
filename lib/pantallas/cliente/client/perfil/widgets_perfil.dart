// lib/pantallas/profile/profile_widgets.dart (Parte 1)

import 'package:flutter/material.dart';
import '../../../../proveedores/proveedor_autenticacion.dart';
import '../../../../modelos/modelo_usuario.dart';
import 'controlador_perfil.dart';
import 'dialogos_perfil.dart';

class ProfileWidgets {
  
  // 📱 Loading Overlay
  static Widget buildLoadingOverlay({
    required bool isLoading,
    required Widget child,
    String? message,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                      message ?? 'Actualizando perfil...',
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

  // ❌ Error State
  static Widget buildErrorState(AuthProvider authProvider, BuildContext context) {
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                   color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                        onPressed: () => authProvider.refreshUserData(),
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
                         context,  // ✅
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

  // 🎨 App Bar con Header
  static Widget buildAppBar(UserModel user, ProfileController controller) {
    return SliverAppBar(
      expandedHeight: 220,
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
              colors: [Color(0xFF1B365D), Color(0xFF2563EB)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
  const SizedBox(height: 10),  // ✅ CAMBIO: De 15 a 10
  _buildProfileImage(user, controller),
  const SizedBox(height: 8),   // ✅ CAMBIO: De 12 a 8
  Text(user.name, /*...*/),
  const SizedBox(height: 1),   // ✅ CAMBIO: De 2 a 1
  Text(user.email, /*...*/),
  const SizedBox(height: 6),   // ✅ CAMBIO: De 8 a 6
  _buildUserBadges(user),
],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(controller.context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), // ✅ CAMBIO
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
        if (!controller.isEditing)
          IconButton(
            onPressed: controller.toggleEditing,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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

  // 📷 Imagen de perfil
  static Widget _buildProfileImage(UserModel user, ProfileController controller) {
    return GestureDetector(
      onTap: controller.isEditing && !controller.isUploadingImage 
          ? controller.pickImage 
          : null,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImageContent(user, controller),
            ),
          ),
          // Indicador de progreso
          if (controller.isUploadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: controller.uploadProgress,
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(controller.uploadProgress * 100).toInt()}%',
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
          // Icono de cámara
          if (controller.isEditing && !controller.isUploadingImage)
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
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

  static Widget _buildImageContent(UserModel user, ProfileController controller) {
    // Imagen local seleccionada
    if (controller.selectedImage != null) {
      return Image.file(controller.selectedImage!, fit: BoxFit.cover);
    }

    // Imagen de perfil desde red
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      return Image.network(
        user.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
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

    return _buildDefaultAvatar();
  }

  static Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
          const Color(0xFF1B365D).withValues(alpha: 0.8), // ✅ CAMBIO
          const Color(0xFF2563EB).withValues(alpha: 0.8), // ✅ CAMBIO
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

static Widget _buildUserBadges(UserModel user) {
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 6,
    runSpacing: 6,
    children: [
      _buildUserBadge(  // ✅ QUITAR Flexible, solo dejar directo
        user.userType == UserType.provider ? 'Proveedor' : 'Cliente',
        user.userType == UserType.provider
            ? Icons.business_center
            : Icons.person,
      ),
      if (user.userType == UserType.provider && user.rating > 0)
        _buildUserBadge(  // ✅ QUITAR Flexible, solo dejar directo
          '${user.rating.toStringAsFixed(1)} ⭐',
          Icons.star,
        ),
    ],
  );
}

static Widget _buildUserBadge(String text, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),  // ✅ CAMBIO: Reducir horizontal de 12 a 10
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),  // ✅ CAMBIO: Reducir de 6 a 4
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,  // ✅ CAMBIO: Reducir de 12 a 11
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
  // lib/pantallas/profile/profile_widgets.dart (Parte 2 - Continuación)

  // 📊 Estadísticas del perfil
  static Widget buildProfileStats(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      transform: Matrix4.translationValues(0, -15, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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

  static Widget _buildProviderStats(UserModel user) {
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
        Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
        Expanded(
          child: _buildStatItem(
            '${user.totalRatings}',
            'Reseñas',
            Icons.rate_review_rounded,
            const Color(0xFF10B981),
          ),
        ),
        Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
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

  static Widget _buildClientStats(UserModel user) {
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
        Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
        Expanded(
          child: _buildStatItem(
            '5',
            'Favoritos',
            Icons.favorite_rounded,
            const Color(0xFFEF4444),
          ),
        ),
        Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
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

  static Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
             color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
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

  // 🚀 Acciones rápidas
  static Widget buildQuickActions(UserModel user, ProfileController controller) {
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
                  controller.toggleEditing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  user.userType == UserType.provider ? 'Mis servicios' : 'Historial',
                  user.userType == UserType.provider ? 'Gestiona servicios' : 'Ver actividad',
                  user.userType == UserType.provider
                      ? Icons.business_center_rounded
                      : Icons.history_rounded,
                  const Color(0xFF10B981),
                  () => controller.navigateToServices(user),
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
                  controller.navigateToSettings,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Ayuda',
                  'Soporte y preguntas',
                  Icons.help_rounded,
                  const Color(0xFF8B5CF6),
                  () => ProfileDialogs.showHelpDialog(controller.context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildActionCard(
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
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

  // ℹ️ Información del proveedor
  static Widget buildProviderSection(UserModel user) {
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
                    color: const Color(0xFF1B365D).withValues(alpha: 0.1),
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
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.services
                    .map((service) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                           color: const Color(0xFF1B365D).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                            color: const Color(0xFF1B365D).withValues(alpha: 0.2)),
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

  static Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1B365D), size: 18),
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
// lib/pantallas/profile/profile_widgets.dart (Parte 3 Final)

  // 📝 Formulario de edición
  static Widget buildEditingForm(UserModel user, ProfileController controller) {
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
                color: const Color(0xFF1B365D).withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                SizedBox(width: 8),
                Expanded(
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
            controller.nameController,
            Icons.person_outline,
            'Ingresa tu nombre completo',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Correo electrónico',
            controller.emailController,
            Icons.email_outlined,
            'tu@email.com',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Teléfono',
            controller.phoneController,
            Icons.phone_outlined,
            '+593 99 999 9999',
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Dirección',
            controller.addressController,
            Icons.location_on_outlined,
            'Tu dirección completa',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            'Ciudad',
            controller.cityController,
            Icons.location_city_outlined,
            'Tu ciudad',
          ),
          if (user.userType == UserType.provider) ...[
            const SizedBox(height: 16),
            _buildModernTextField(
              'Descripción de servicios',
              controller.descriptionController,
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
                  onPressed: controller.cancelEditing,
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
                  onPressed: controller.isLoading ? null : controller.saveProfile,
                  icon: controller.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: Text(controller.isLoading ? 'Guardando...' : 'Guardar'),
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

  static Widget _buildModernTextField(
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
          constraints: const BoxConstraints(minHeight: 48),
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
                child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
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
                borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
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

  // ⚙️ Configuración
  static Widget buildSettingsSection(ProfileController controller) {
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
            () => ProfileDialogs.showChangePasswordDialog(controller.context),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Notificaciones',
            'Configura tus preferencias',
            Icons.notifications_outlined,
            () => ProfileDialogs.showNotificationSettings(controller.context),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Privacidad',
            'Gestiona tu privacidad',
            Icons.privacy_tip_outlined,
            controller.showPrivacySettings,
          ),
          _buildDivider(),
          _buildSettingItem(
            'Ayuda y soporte',
            'Obtén ayuda cuando la necesites',
            Icons.help_outline,
            () => ProfileDialogs.showHelpDialog(controller.context),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ProfileDialogs.showLogoutDialog(controller.context),
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

  static Widget _buildSettingItem(
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
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1B365D), size: 18),
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

  // 🎨 Helper widgets
  static Widget _buildModernCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
           color: Colors.black.withValues(alpha: 0.05),
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
                   color: const Color(0xFF1B365D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF1B365D), size: 20),
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

  static Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
}
  