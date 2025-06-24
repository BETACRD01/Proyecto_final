import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../nucleo/constantes/colores_app.dart';
import '../../nucleo/constantes/textos_app.dart';
import '../../nucleo/widgets/boton_personalizado.dart';
import '../../nucleo/widgets/campo_texto_personalizado.dart';
import '../../nucleo/utilidades/validadores.dart';
import '../../proveedores/proveedor_autenticacion.dart';
import '../../modelos/modelo_usuario.dart';

// 🔹 WIDGET PERSONALIZADO PARA SELECTOR DE FECHA CON DROPDOWNS
class DateSelectorWidget extends StatefulWidget {
  final String? initialValue;
  final String label;
  final Function(String) onDateChanged;
  final String? Function(String?)? validator;

  const DateSelectorWidget({
    Key? key,
    this.initialValue,
    required this.label,
    required this.onDateChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  // Lista de meses en español
  final Map<String, String> months = {
    '01': 'Enero',
    '02': 'Febrero',
    '03': 'Marzo',
    '04': 'Abril',
    '05': 'Mayo',
    '06': 'Junio',
    '07': 'Julio',
    '08': 'Agosto',
    '09': 'Septiembre',
    '10': 'Octubre',
    '11': 'Noviembre',
    '12': 'Diciembre',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _parseInitialDate(widget.initialValue!);
    }
  }

  void _parseInitialDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        selectedDay = parts[0];
        selectedMonth = parts[1];
        selectedYear = parts[2];
      }
    } catch (e) {
      debugPrint('Error parseando fecha inicial: $e');
    }
  }

  void _onDateChanged() {
    if (selectedDay != null && selectedMonth != null && selectedYear != null) {
      final dateString = '$selectedDay/$selectedMonth/$selectedYear';
      widget.onDateChanged(dateString);
    }
  }

  List<String> _getDaysForMonth() {
    if (selectedMonth == null || selectedYear == null) {
      return List.generate(
          31, (index) => (index + 1).toString().padLeft(2, '0'));
    }

    final year = int.parse(selectedYear!);
    final month = int.parse(selectedMonth!);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(
        daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final minAge = 14;
    final maxAge = 75;
    final years = List.generate(
      maxAge - minAge + 1,
      (index) => (currentYear - minAge - index).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.cake_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Selecciona tu fecha de nacimiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Selector de día
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Día',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedDay != null
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDay,
                              hint: const Text('--',
                                  style: TextStyle(fontSize: 12)),
                              isExpanded: true,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('--',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                ..._getDaysForMonth().map((day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(day,
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedDay = value;
                                  if (selectedMonth != null &&
                                      selectedYear != null) {
                                    final daysInMonth = _getDaysForMonth();
                                    if (selectedDay != null &&
                                        !daysInMonth.contains(selectedDay!)) {
                                      selectedDay = null;
                                    }
                                  }
                                });
                                _onDateChanged();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Selector de mes
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedMonth != null
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              hint: const Text('--',
                                  style: TextStyle(fontSize: 12)),
                              isExpanded: true,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('--',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                ...months.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value;
                                  if (selectedDay != null &&
                                      selectedYear != null) {
                                    final daysInMonth = _getDaysForMonth();
                                    if (!daysInMonth.contains(selectedDay!)) {
                                      selectedDay = null;
                                    }
                                  }
                                });
                                _onDateChanged();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Selector de año
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Año',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedYear != null
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedYear,
                              hint: const Text('--',
                                  style: TextStyle(fontSize: 12)),
                              isExpanded: true,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('--',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                ...years.map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year,
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value;
                                  if (selectedDay != null &&
                                      selectedMonth != null) {
                                    final daysInMonth = _getDaysForMonth();
                                    if (!daysInMonth.contains(selectedDay!)) {
                                      selectedDay = null;
                                    }
                                  }
                                });
                                _onDateChanged();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Mostrar fecha seleccionada
              if (selectedDay != null &&
                  selectedMonth != null &&
                  selectedYear != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Fecha: $selectedDay de ${months[selectedMonth!]} de $selectedYear',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculateAge(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Mensaje de error si existe
        if (widget.validator != null) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final dateString = selectedDay != null &&
                      selectedMonth != null &&
                      selectedYear != null
                  ? '$selectedDay/$selectedMonth/$selectedYear'
                  : null;
              final errorMessage = widget.validator!(dateString);

              if (errorMessage != null) {
                return Text(
                  errorMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  String _calculateAge() {
    if (selectedDay == null || selectedMonth == null || selectedYear == null) {
      return '';
    }

    try {
      final birthDate = DateTime(
        int.parse(selectedYear!),
        int.parse(selectedMonth!),
        int.parse(selectedDay!),
      );

      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return 'Tienes $age años';
    } catch (e) {
      return '';
    }
  }
}

// 🔹 CLASE PRINCIPAL DEL REGISTRO
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para clientes
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Controladores para proveedores
  final _providerNameController = TextEditingController();
  final _providerEmailController = TextEditingController();
  final _providerPhoneController = TextEditingController();
  final _providerAddressController = TextEditingController();
  final _providerCityController = TextEditingController();
  final _providerPasswordController = TextEditingController();
  final _providerConfirmPasswordController = TextEditingController();
  final _providerCedulaController = TextEditingController();
  final _providerDateOfBirthController = TextEditingController();
  final _experienceController = TextEditingController();
  final _servicesController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  UserType _selectedUserType = UserType.client;
  String _selectedAvailability = 'flexible';

  // Variables para hoja de vida
  File? _selectedCV;
  String? _cvFileName;
  bool _isUploadingCV = false;

  // 🔹 NUEVA VARIABLE PARA CHECKBOX DE TÉRMINOS
  bool _acceptedTerms = false;

  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthStateChanged);

    // Dispose controladores de clientes
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cedulaController.dispose();
    _dateOfBirthController.dispose();

    // Dispose controladores de proveedores
    _providerNameController.dispose();
    _providerEmailController.dispose();
    _providerPhoneController.dispose();
    _providerAddressController.dispose();
    _providerCityController.dispose();
    _providerPasswordController.dispose();
    _providerConfirmPasswordController.dispose();
    _providerCedulaController.dispose();
    _providerDateOfBirthController.dispose();
    _experienceController.dispose();
    _servicesController.dispose();
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
          Navigator.pop(context);
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

  String? _validateEcuadorianID(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es obligatoria';
    }

    String cedula = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cedula.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }

    int provincia = int.tryParse(cedula.substring(0, 2)) ?? 0;
    if (provincia < 1 || provincia > 24) {
      return 'Código de provincia inválido';
    }

    int tercerDigito = int.tryParse(cedula[2]) ?? 0;
    if (tercerDigito >= 6) {
      return 'Cédula de persona natural inválida';
    }

    List<int> coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int digito = int.parse(cedula[i]);
      int resultado = digito * coeficientes[i];

      if (resultado >= 10) {
        resultado = resultado - 9;
      }

      suma += resultado;
    }

    int digitoVerificador = (10 - (suma % 10)) % 10;
    int ultimoDigito = int.parse(cedula[9]);

    if (digitoVerificador != ultimoDigito) {
      return 'Cédula inválida - dígito verificador incorrecto';
    }

    return null;
  }

  Future<void> _selectCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        const maxSize = 10 * 1024 * 1024;

        if (fileSize > maxSize) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'El archivo es muy grande. Máximo permitido: 10MB'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          _selectedCV = file;
          _cvFileName = result.files.single.name;
        });

        if (!mounted) return;
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Archivo seleccionado: $_cvFileName ($fileSizeMB MB)'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al seleccionar archivo: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _uploadCVToFirebase() async {
    if (_selectedCV == null) return null;

    try {
      setState(() {
        _isUploadingCV = true;
      });

      String fileName =
          'cv_${DateTime.now().millisecondsSinceEpoch}_$_cvFileName';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('providers_cv').child(fileName);

      UploadTask uploadTask = storageRef.putFile(_selectedCV!);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
            '🔄 Progreso de subida: ${(progress * 100).toStringAsFixed(1)}%');

        if (mounted && progress < 1.0) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Subiendo CV: ${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploadingCV = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white),
                SizedBox(width: 8),
                Text('CV subido exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return downloadURL;
    } catch (e) {
      setState(() {
        _isUploadingCV = false;
      });

      if (!mounted) return null;

      String errorMessage = 'Error al subir archivo';
      if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Sin permisos para subir archivo';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'Límite de almacenamiento excedido';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _selectCV(),
          ),
        ),
      );

      return null;
    }
  }

  void _removeCVSelection() {
    setState(() {
      _selectedCV = null;
      _cvFileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text('Archivo removido'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateNumbersOnly(String? value, String fieldName,
      {int? minLength, int? maxLength}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '$fieldName debe contener solo números';
    }

    if (minLength != null && value.length < minLength) {
      return '$fieldName debe tener al menos $minLength dígitos';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName debe tener máximo $maxLength dígitos';
    }

    return null;
  }

  Future<void> _handleRegister() async {
    // Validar términos para proveedores
    if (_selectedUserType == UserType.provider && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Debes aceptar los términos para continuar'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Map<String, dynamic> userData;

      if (_selectedUserType == UserType.client) {
        userData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'userType': _selectedUserType,
          'cedula': _cedulaController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
        };
      } else {
        String? cvURL;
        if (_selectedCV != null) {
          cvURL = await _uploadCVToFirebase();
          if (cvURL == null) {
            return;
          }
        }

        userData = {
          'email': _providerEmailController.text.trim(),
          'password': _providerPasswordController.text,
          'name': _providerNameController.text.trim(),
          'phone': _providerPhoneController.text.trim(),
          'address': _providerAddressController.text.trim(),
          'city': _providerCityController.text.trim(),
          'userType': _selectedUserType,
          'cedula': _providerCedulaController.text.trim(),
          'dateOfBirth': _providerDateOfBirthController.text.trim(),
          'experience': _experienceController.text.trim(),
          'services': _servicesController.text.trim(),
          'availability': _selectedAvailability,
          'emergencyContact': _emergencyContactController.text.trim(),
          'cvURL': cvURL,
          'cvFileName': _cvFileName,
          'acceptedTerms': _acceptedTerms, // Guardar aceptación de términos
        };
      }

      await authProvider.signUpWithExtraData(userData);
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

                const SizedBox(height: 32),

                // Formularios separados
                if (_selectedUserType == UserType.client) ...[
                  _buildClientForm(),
                ] else ...[
                  _buildProviderForm(),
                ],

                const SizedBox(height: 32),

                // Botón de registro
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
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
                    );
                  },
                ),

                // Loading indicator
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            _selectedUserType == UserType.provider
                                ? 'Validando información...'
                                : 'Configurando tu cuenta...',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
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

  // Formulario para clientes
  Widget _buildClientForm() {
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

        // Nuevo selector de fecha
        DateSelectorWidget(
          label: 'Fecha de nacimiento',
          initialValue: _dateOfBirthController.text,
          onDateChanged: (dateString) {
            setState(() {
              _dateOfBirthController.text = dateString;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La fecha de nacimiento es obligatoria';
            }

            try {
              final parts = value.split('/');
              if (parts.length != 3) return 'Formato de fecha inválido';

              final birthDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );

              final now = DateTime.now();
              int age = now.year - birthDate.year;

              if (now.month < birthDate.month ||
                  (now.month == birthDate.month && now.day < birthDate.day)) {
                age--;
              }

              if (age < 18) {
                return 'Debes ser mayor de 18 años para registrarte';
              }

              if (age > 100) {
                return 'Por favor verifica la fecha ingresada';
              }
            } catch (e) {
              return 'Fecha inválida';
            }

            return null;
          },
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

  // Formulario para proveedores
  Widget _buildProviderForm() {
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
          controller: _providerNameController,
          validator: Validators.validateName,
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Cédula de ciudadanía ecuatoriana',
          controller: _providerCedulaController,
          validator: _validateEcuadorianID,
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          hint: 'Ej: 1234567890',
        ),

        const SizedBox(height: 16),

        // Selector de fecha para proveedores
        DateSelectorWidget(
          label: 'Fecha de nacimiento',
          initialValue: _providerDateOfBirthController.text,
          onDateChanged: (dateString) {
            setState(() {
              _providerDateOfBirthController.text = dateString;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La fecha de nacimiento es obligatoria';
            }

            try {
              final parts = value.split('/');
              if (parts.length != 3) return 'Formato de fecha inválido';

              final birthDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );

              final now = DateTime.now();
              int age = now.year - birthDate.year;

              if (now.month < birthDate.month ||
                  (now.month == birthDate.month && now.day < birthDate.day)) {
                age--;
              }

              if (age < 18) {
                return 'Debes ser mayor de 18 años para ser proveedor';
              }

              if (age > 75) {
                return 'Edad máxima permitida: 75 años';
              }
            } catch (e) {
              return 'Fecha inválida';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.email,
          controller: _providerEmailController,
          validator: Validators.validateEmail,
          isEmail: true,
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Teléfono/Celular',
          controller: _providerPhoneController,
          validator: Validators.validatePhone,
          isPhone: true,
          prefixIcon: Icons.phone_outlined,
          hint: 'Ej: +593 99 123 4567',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Dirección completa',
          controller: _providerAddressController,
          validator: (value) => Validators.validateRequired(value, 'Dirección'),
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          hint: 'Calle, número, sector, referencias',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Ciudad',
          controller: _providerCityController,
          validator: (value) => Validators.validateRequired(value, 'Ciudad'),
          prefixIcon: Icons.location_city_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.password,
          controller: _providerPasswordController,
          validator: Validators.validatePassword,
          isPassword: true,
          prefixIcon: Icons.lock_outlined,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: AppStrings.confirmPassword,
          controller: _providerConfirmPasswordController,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _providerPasswordController.text,
          ),
          isPassword: true,
          prefixIcon: Icons.lock_outlined,
        ),

        const SizedBox(height: 32),

        // Información profesional
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
            String? numberValidation = _validateNumbersOnly(
                value, 'Años de experiencia',
                minLength: 1, maxLength: 2);
            if (numberValidation != null) return numberValidation;

            final years = int.tryParse(value!);
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

        const Text(
          'Disponibilidad horaria',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Column(
          children: [
            _buildAvailabilityOption(
              'flexible',
              'Horario flexible',
              'Puedo adaptarme a las necesidades del cliente',
              Icons.schedule_outlined,
            ),
            _buildAvailabilityOption(
              'morning',
              'Solo mañanas',
              'Lunes a sábado: 7:00 AM - 12:00 PM',
              Icons.wb_sunny_outlined,
            ),
            _buildAvailabilityOption(
              'afternoon',
              'Solo tardes',
              'Lunes a sábado: 1:00 PM - 6:00 PM',
              Icons.wb_twilight_outlined,
            ),
            _buildAvailabilityOption(
              'full_time',
              'Tiempo completo',
              'Lunes a sábado: 7:00 AM - 6:00 PM',
              Icons.access_time,
            ),
          ],
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'Contacto de emergencia',
          controller: _emergencyContactController,
          validator: (value) => _validateNumbersOnly(
              value, 'Contacto de emergencia',
              minLength: 9, maxLength: 15),
          prefixIcon: Icons.emergency_outlined,
          keyboardType: TextInputType.phone,
          hint: 'Ej: 0987654321',
        ),

        const SizedBox(height: 16),

        // 🔹 SECCIÓN DE HOJA DE VIDA - MOVIDA AQUÍ (ARRIBA DEL PROCESO DE VERIFICACIÓN)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hoja de Vida (CV)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  if (_selectedCV != null)
                    IconButton(
                      onPressed: _removeCVSelection,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'Remover archivo',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Sube tu currículum vitae para que los clientes conozcan tu experiencia',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isUploadingCV ? null : _selectCV,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedCV != null
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCV != null
                          ? Colors.green
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isUploadingCV) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text(
                          'Subiendo archivo...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ] else if (_selectedCV != null) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cvFileName ?? 'Archivo seleccionado',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toca para cambiar archivo',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Seleccionar hoja de vida',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PDF, DOC o DOCX • Máximo 10MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_selectedCV == null) ...[
                const SizedBox(height: 8),
                const Text(
                  '💡 Opcional: Una buena hoja de vida aumenta tus posibilidades de conseguir clientes',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Info proceso de aprobación
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
                    Icons.verified_user_outlined,
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
                '• Tu cédula será verificada automáticamente\n• Validaremos tu información de contacto\n• Recibirás respuesta en 24-48 horas\n• Podrás cargar documentos adicionales desde tu perfil',
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

        // 🔹 CHECKBOX DE TÉRMINOS Y CONDICIONES (REEMPLAZA EL CONTENEDOR ANTERIOR)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _acceptedTerms
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.orange.withValues(alpha: 0.3),
              width: _acceptedTerms ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.policy_outlined,
                    color: _acceptedTerms ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Términos y Condiciones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 CHECKBOX CON TEXTO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptedTerms = !_acceptedTerms;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Al registrarme como proveedor, confirmo que toda la información es veraz y acepto los ',
                            ),
                            TextSpan(
                              text:
                                  'términos de verificación y calidad de servicio',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' de la plataforma.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Mensaje de validación
              if (!_acceptedTerms) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 40), // Espacio del checkbox
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Debes aceptar los términos para continuar',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 40), // Espacio del checkbox
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Términos aceptados correctamente',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Widget para opciones de disponibilidad
  Widget _buildAvailabilityOption(
      String value, String title, String description, IconData icon) {
    bool isSelected = _selectedAvailability == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvailability = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
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
          // Limpiar campos al cambiar tipo
          if (userType == UserType.client) {
            // Limpiar campos de proveedor
            _providerNameController.clear();
            _providerEmailController.clear();
            _providerPhoneController.clear();
            _providerAddressController.clear();
            _providerCityController.clear();
            _providerPasswordController.clear();
            _providerConfirmPasswordController.clear();
            _providerCedulaController.clear();
            _providerDateOfBirthController.clear();
            _experienceController.clear();
            _servicesController.clear();
            _emergencyContactController.clear();
            _selectedAvailability = 'flexible';
            _selectedCV = null;
            _cvFileName = null;
            _acceptedTerms = false; // Resetear términos
          } else {
            // Limpiar campos de cliente
            _nameController.clear();
            _emailController.clear();
            _phoneController.clear();
            _addressController.clear();
            _cityController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
            _cedulaController.clear();
            _dateOfBirthController.clear();
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

// 🔹 REFERENCIA DE VALIDACIÓN DE MÉTODOS PRIVADOS FALTANTES
// Este comentario es para recordar que estas funciones están en la clase RegisterScreen

/*
Los siguientes métodos están incluidos en la primera parte del archivo:

- _validateEcuadorianID()
- _selectCV()
- _uploadCVToFirebase()
- _removeCVSelection()
- _validateNumbersOnly()
- _handleRegister()

Para usar este código completo, debes:
1. Copiar la primera parte (DateSelectorWidget + parte inicial de RegisterScreen)
2. Copiar la segunda parte (métodos principales)
3. Copiar esta tercera parte (formularios y widgets)

El código está dividido en 3 partes por limitaciones de longitud.
*/
