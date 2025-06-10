// screens/auth/login_screen.dart
//
// Pantalla de autenticación principal
// Maneja login con email/contraseña y navegación por tipo de usuario
// Soporta: admin, provider, client
//
// Autor: [Tu Nombre]
// Versión: 1.0.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

/// Pantalla principal de autenticación
///
/// Funcionalidades:
/// - Login con email/contraseña
/// - Navegación automática por tipo de usuario
/// - Recuperación de contraseña
/// - Validación de formularios
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Liberar recursos para evitar memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Maneja el proceso de login completo
  ///
  /// Flujo:
  /// 1. Valida formulario
  /// 2. Autentica con AuthProvider
  /// 3. Determina tipo de usuario
  /// 4. Navega al dashboard correspondiente
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Ejecutar autenticación
      bool success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        final user = authProvider.currentUser;

        // Debug info
        debugPrint('🔍 DEBUG - Login exitoso:');
        debugPrint('- Usuario ID: ${user?.id}');
        debugPrint('- Nombre: ${user?.name}');
        debugPrint('- Email: ${user?.email}');
        debugPrint('- UserType: ${user?.userType}');
        debugPrint('- UserType index: ${user?.userType.index}');

        // Navegación por tipo de usuario
        if (user?.userType == UserType.admin) {
          debugPrint(
              '✅ Detectado como ADMINISTRADOR - Redirigiendo a AdminHome');
          Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
        } else if (user?.userType == UserType.provider) {
          debugPrint(
              '✅ Detectado como PROVEEDOR - Redirigiendo a ProviderHome');
          Navigator.pushReplacementNamed(context, AppRoutes.providerHome);
        } else {
          debugPrint('✅ Detectado como CLIENTE - Redirigiendo a Home');
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (mounted) {
        // Mostrar error de autenticación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Header: Logo y título
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.home_repair_service,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Formulario: Email y contraseña
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  isEmail: true,
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),

                const SizedBox(height: 16),

                // Enlace: Recuperar contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón principal: Login
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Divisor visual
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón secundario: Registro
                CustomButton(
                  text: 'Crear cuenta nueva',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  isOutlined: true,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo mejorado para recuperación de contraseña
  ///
  /// Permite al usuario solicitar un enlace de recuperación via email
  /// Incluye animaciones, mejor UX y validación en tiempo real
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: Colors.white,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height *
                      0.8, // Límite de altura
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    // Hacer scrolleable
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con ícono y color (más compacto)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(20), // Reducido de 24 a 20
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50, // Reducido de 60 a 50
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Icon(
                                  Icons.lock_reset,
                                  color: Colors.white,
                                  size: 25, // Reducido de 30 a 25
                                ),
                              ),
                              const SizedBox(height: 12), // Reducido de 16 a 12
                              const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: 18, // Reducido de 20 a 18
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6), // Reducido de 8 a 6
                              const Text(
                                'No te preocupes, te ayudamos a recuperarla',
                                style: TextStyle(
                                  fontSize: 13, // Reducido de 14 a 13
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Contenido del formulario (optimizado)
                        Padding(
                          padding:
                              const EdgeInsets.all(20), // Reducido de 24 a 20
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Descripción del proceso (más compacta)
                                Container(
                                  padding: const EdgeInsets.all(
                                      12), // Reducido de 16 a 12
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue[600],
                                        size: 18, // Reducido de 20 a 18
                                      ),
                                      const SizedBox(
                                          width: 10), // Reducido de 12 a 10
                                      const Expanded(
                                        child: Text(
                                          'Te enviaremos un enlace seguro a tu correo para que puedas crear una nueva contraseña.',
                                          style: TextStyle(
                                            fontSize: 12, // Reducido de 13 a 12
                                            color: AppColors.textSecondary,
                                            height:
                                                1.3, // Reducido de 1.4 a 1.3
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                    height: 18), // Reducido de 24 a 18

                                // Campo de email
                                CustomTextField(
                                  label: 'Correo electrónico',
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El correo es obligatorio';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icons.email_outlined,
                                  hint: 'tu-email@ejemplo.com',
                                  isEmail: true,
                                ),

                                const SizedBox(
                                    height: 20), // Reducido de 24 a 20

                                // Botones de acción
                                Row(
                                  children: [
                                    // Botón cancelar
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  14), // Reducido de 16 a 14
                                          side: BorderSide(
                                            color: Colors.grey
                                                .withValues(alpha: 0.3),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15, // Reducido de 16 a 15
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 12), // Reducido de 16 a 12

                                    // Botón enviar
                                    Expanded(
                                      flex: 2,
                                      child: Consumer<AuthProvider>(
                                        builder:
                                            (context, authProvider, child) {
                                          return ElevatedButton(
                                            onPressed: authProvider.isLoading
                                                ? null
                                                : () async {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      // Enviar solicitud de recuperación
                                                      bool success =
                                                          await authProvider
                                                              .resetPassword(
                                                        emailController.text
                                                            .trim(),
                                                      );

                                                      if (!context.mounted)
                                                        return;

                                                      Navigator.pop(context);

                                                      // Mostrar resultado con animación
                                                      if (success) {
                                                        _showSuccessSnackBar();
                                                      } else {
                                                        _showErrorSnackBar(
                                                            authProvider
                                                                .errorMessage);
                                                      }
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  vertical:
                                                      14), // Reducido de 16 a 14
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: authProvider.isLoading
                                                ? const SizedBox(
                                                    width:
                                                        18, // Reducido de 20 a 18
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.send,
                                                          size:
                                                              16), // Reducido de 18 a 16
                                                      SizedBox(
                                                          width:
                                                              6), // Reducido de 8 a 6
                                                      Text(
                                                        'Enviar enlace',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              15, // Reducido de 16 a 15
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 12), // Reducido de 16 a 12

                                // Información adicional
                                Center(
                                  child: Text(
                                    'El enlace será válido por 24 horas',
                                    style: TextStyle(
                                      fontSize: 11, // Reducido de 12 a 11
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Muestra SnackBar de éxito con animación
  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mark_email_read,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enlace enviado correctamente',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Revisa tu bandeja de entrada',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Muestra SnackBar de error
  void _showErrorSnackBar(String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage ?? 'Error al enviar el enlace',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: _showForgotPasswordDialog,
        ),
      ),
    );
  }
}
