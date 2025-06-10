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

  /// Muestra diálogo para recuperación de contraseña
  ///
  /// Permite al usuario solicitar un enlace de recuperación via email
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.email,
              controller: emailController,
              validator: Validators.validateEmail,
              isEmail: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (emailController.text.isNotEmpty) {
                          // Enviar solicitud de recuperación
                          bool success = await authProvider.resetPassword(
                            emailController.text.trim(),
                          );

                          if (!mounted) return;

                          Navigator.pop(context);
                          // Mostrar resultado
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Email de recuperación enviado'
                                    : 'Error al enviar email',
                              ),
                              backgroundColor:
                                  success ? AppColors.success : AppColors.error,
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
