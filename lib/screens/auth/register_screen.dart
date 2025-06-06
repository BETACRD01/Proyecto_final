import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Controladores adicionales para campos de proveedor
  final _experienceController = TextEditingController();
  final _servicesController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _referencesController = TextEditingController();
  final _certificationController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  UserType _selectedUserType = UserType.client;

  // ✅ Variable para guardar la referencia del AuthProvider
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Guarda la referencia del provider
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    // ✅ Usa la referencia guardada, no context.read()
    _authProvider?.removeListener(_onAuthStateChanged);

    // Dispose de todos los controladores
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cedulaController.dispose();
    _dateOfBirthController.dispose();
    _experienceController.dispose();
    _servicesController.dispose();
    _availabilityController.dispose();
    _referencesController.dispose();
    _certificationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(authProvider.successMessage!)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      authProvider.clearSuccess();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context); // Volver a login
        }
      });
    }

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(authProvider.errorMessage!)),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      authProvider.clearError();
    }
  }

  // Método para seleccionar fecha de nacimiento
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate:
          DateTime.now().subtract(const Duration(days: 6570)), // Mínimo 18 años
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        userType: _selectedUserType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Únete a nuestra comunidad',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedUserType == UserType.provider
                      ? 'Completa todos los datos para ser proveedor'
                      : 'Completa tus datos para comenzar',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Tipo de usuario
                const Text(
                  'Tipo de Usuario',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeCard(
                        UserType.client,
                        'Cliente',
                        'Busco servicios para mi hogar',
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUserTypeCard(
                        UserType.provider,
                        'Proveedor',
                        'Ofrezco servicios domésticos',
                        Icons.work_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Campos básicos (siempre visibles)
                _buildBasicFields(),

                // Campos adicionales para proveedores (condicionales)
                if (_selectedUserType == UserType.provider) ...[
                  const SizedBox(height: 32),
                  _buildProviderFields(),
                ],

                const SizedBox(height: 32),

                // Botón de registro
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        CustomButton(
                          text: authProvider.isLoading
                              ? (_selectedUserType == UserType.provider
                                  ? 'Enviando solicitud...'
                                  : 'Creando cuenta...')
                              : (_selectedUserType == UserType.provider
                                  ? 'Enviar solicitud'
                                  : AppStrings.register),
                          onPressed:
                              authProvider.isLoading ? null : _handleRegister,
                          isLoading: authProvider.isLoading,
                        ),
                        if (authProvider.isLoading) ...[
                          const SizedBox(height: 16),
                          Text(
                            _selectedUserType == UserType.provider
                                ? 'Preparando tu solicitud...'
                                : 'Configurando tu cuenta...',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Link a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Campos básicos (siempre visibles)
  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          label: 'Nombre completo',
          controller: _nameController,
          validator: Validators.validateName,
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Cédula de ciudadanía',
          controller: _cedulaController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La cédula es obligatoria';
            }
            if (value.length < 8 || value.length > 15) {
              return 'Ingresa una cédula válida';
            }
            return null;
          },
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          hint: 'Ej: 1234567890',
        ),

        const SizedBox(height: 16),

        // Campo de fecha con GestureDetector
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Fecha de nacimiento',
              controller: _dateOfBirthController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha de nacimiento es obligatoria';
                }
                return null;
              },
              prefixIcon: Icons.calendar_today_outlined,
              hint: 'Toca para seleccionar fecha',
            ),
          ),
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.email,
          controller: _emailController,
          validator: Validators.validateEmail,
          isEmail: true,
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Teléfono/Celular',
          controller: _phoneController,
          validator: Validators.validatePhone,
          isPhone: true,
          prefixIcon: Icons.phone_outlined,
          hint: 'Ej: +593 99 123 4567',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Dirección completa',
          controller: _addressController,
          validator: (value) => Validators.validateRequired(value, 'Dirección'),
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          hint: 'Calle, número, sector, referencias',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Ciudad',
          controller: _cityController,
          validator: (value) => Validators.validateRequired(value, 'Ciudad'),
          prefixIcon: Icons.location_city_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.password,
          controller: _passwordController,
          validator: Validators.validatePassword,
          isPassword: true,
          prefixIcon: Icons.lock_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.confirmPassword,
          controller: _confirmPasswordController,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          isPassword: true,
          prefixIcon: Icons.lock_outlined,
        ),
      ],
    );
  }

  // Campos adicionales para proveedores
  Widget _buildProviderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Profesional',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          label: 'Años de experiencia',
          controller: _experienceController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tus años de experiencia';
            }
            final years = int.tryParse(value);
            if (years == null || years < 0 || years > 50) {
              return 'Ingresa un número válido (0-50)';
            }
            return null;
          },
          prefixIcon: Icons.work_history,
          keyboardType: TextInputType.number,
          hint: 'Ej: 5',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Servicios que ofreces',
          controller: _servicesController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Describe los servicios que ofreces';
            }
            if (value.length < 10) {
              return 'Describe con más detalle tus servicios';
            }
            return null;
          },
          prefixIcon: Icons.handyman,
          maxLines: 3,
          hint:
              'Ej: Limpieza general, limpieza profunda, jardinería, plomería básica...',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Horarios disponibles',
          controller: _availabilityController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Indica tu disponibilidad horaria';
            }
            return null;
          },
          prefixIcon: Icons.schedule,
          maxLines: 2,
          hint: 'Ej: Lunes a viernes 8:00am - 6:00pm, Sábados medio tiempo',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Certificaciones o cursos',
          controller: _certificationController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Indica tus certificaciones o cursos relacionados';
            }
            return null;
          },
          prefixIcon: Icons.school_outlined,
          maxLines: 3,
          hint:
              'Ej: Curso de primeros auxilios, certificación en limpieza industrial...',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Contacto de emergencia',
          controller: _emergencyContactController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Proporciona un contacto de emergencia';
            }
            return null;
          },
          prefixIcon: Icons.emergency_outlined,
          maxLines: 2,
          hint: 'Nombre y teléfono de contacto de emergencia',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Referencias laborales',
          controller: _referencesController,
          prefixIcon: Icons.people_outline,
          maxLines: 3,
          hint:
              'Nombres y teléfonos de clientes anteriores o empleadores (opcional)',
        ),

        const SizedBox(height: 16),

        // Info sobre proceso de aprobación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Proceso de verificación',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Tu cédula será verificada\n• Se validarán tus referencias\n• Recibirás respuesta en 2-3 días hábiles\n• Podrás subir documentos adicionales después',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Términos y condiciones para proveedores
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: const Text(
            'Al registrarte como proveedor, aceptas cumplir con nuestras políticas de calidad y estar disponible para verificaciones periódicas.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(
    UserType userType,
    String title,
    String description,
    IconData icon,
  ) {
    bool isSelected = _selectedUserType == userType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
          // Limpiar campos de proveedor cuando cambie a cliente
          if (userType == UserType.client) {
            _experienceController.clear();
            _servicesController.clear();
            _availabilityController.clear();
            _referencesController.clear();
            _certificationController.clear();
            _emergencyContactController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
