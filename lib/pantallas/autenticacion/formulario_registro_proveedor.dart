import 'package:flutter/material.dart';
import '../../nucleo/constantes/colores_app.dart';
import '../../nucleo/widgets/boton_personalizado.dart';
import '../../nucleo/widgets/campo_texto_personalizado.dart';
class ProviderRegistrationForm extends StatefulWidget {
  const ProviderRegistrationForm({Key? key}) : super(key: key);

  @override
  State<ProviderRegistrationForm> createState() =>
      _ProviderRegistrationFormState();
}

class _ProviderRegistrationFormState extends State<ProviderRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _servicesController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _referencesController = TextEditingController();
  final _portfolioController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _experienceController.dispose();
    _servicesController.dispose();
    _availabilityController.dispose();
    _referencesController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simular envío del formulario
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '¡Formulario enviado! Tu solicitud está siendo revisada por el administrador.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Volver a login después de un momento
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Proveedor'),
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
                  'Completa tu perfil de proveedor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta información será revisada por nuestro equipo',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Campos del formulario
                CustomTextField(
                  label: 'Años de experiencia',
                  controller: _experienceController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor indica tus años de experiencia';
                    }
                    return null;
                  },
                  prefixIcon: Icons.work_history,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Servicios que ofreces',
                  controller: _servicesController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor describe los servicios que ofreces';
                    }
                    return null;
                  },
                  prefixIcon: Icons.handyman,
                  maxLines: 3,
                  hint: 'Ej: Limpieza, jardinería, plomería, electricidad...',
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Disponibilidad horaria',
                  controller: _availabilityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor indica tu disponibilidad';
                    }
                    return null;
                  },
                  prefixIcon: Icons.schedule,
                  maxLines: 2,
                  hint:
                      'Ej: Lunes a viernes 8am-6pm, fines de semana disponible',
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Referencias (opcional)',
                  controller: _referencesController,
                  prefixIcon: Icons.people,
                  maxLines: 3,
                  hint: 'Contactos de clientes anteriores o empleadores',
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Portfolio/Trabajos anteriores (opcional)',
                  controller: _portfolioController,
                  prefixIcon: Icons.photo_library,
                  maxLines: 2,
                  hint:
                      'Enlaces a fotos o descripciones de trabajos realizados',
                ),

                const SizedBox(height: 32),

                // Información importante
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
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Proceso de aprobación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tu solicitud será revisada por nuestro equipo administrativo. Te contactaremos en un plazo de 2-3 días hábiles para confirmar tu aprobación.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón de envío
                CustomButton(
                  text: _isLoading ? 'Enviando...' : 'Enviar solicitud',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                // Botón para volver
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Volver',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
