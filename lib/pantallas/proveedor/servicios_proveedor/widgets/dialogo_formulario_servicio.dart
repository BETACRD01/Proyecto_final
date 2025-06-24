// lib/caracteristicas/servicios_proveedor/widgets/dialogo_formulario_servicio.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../nucleo/constantes/colores_app.dart';
import '../../../../nucleo/widgets/boton_personalizado.dart';
import '../modelos/modelo_servicio.dart';
import '../utilidades/ayudantes_servicio.dart';

class DialogoFormularioServicio extends StatefulWidget {
  final ModeloServicio? servicio; // null para crear nuevo
  final String proveedorId;

  const DialogoFormularioServicio({
    Key? key,
    this.servicio,
    required this.proveedorId,
  }) : super(key: key);

  @override
  State<DialogoFormularioServicio> createState() => _DialogoFormularioServicioState();
}

class _DialogoFormularioServicioState extends State<DialogoFormularioServicio> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  
  String _categoriaSeleccionada = 'plomeria';
  bool _estaCargando = false;

  bool get _esEdicion => widget.servicio != null;

  @override
  void initState() {
    super.initState();
    _inicializarCampos();
  }

  void _inicializarCampos() {
    if (_esEdicion) {
      final servicio = widget.servicio!;
      _nombreController.text = servicio.nombre;
      _descripcionController.text = servicio.descripcion;
      _precioController.text = servicio.precioPorHora.toString();
      _categoriaSeleccionada = servicio.categoria;
    } else {
      // Sugerir precio basado en categoría por defecto
      _precioController.text = AyudantesServicio.obtenerPrecioSugerido(_categoriaSeleccionada).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFormulario(),
            const SizedBox(height: 24),
            _buildBotones(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _esEdicion ? Icons.edit : Icons.add_circle_outline,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _esEdicion ? 'Editar Servicio' : 'Agregar Servicio',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCampoNombre(),
          const SizedBox(height: 16),
          _buildCampoCategoria(),
          const SizedBox(height: 16),
          _buildCampoDescripcion(),
          const SizedBox(height: 16),
          _buildCampoPrecio(),
        ],
      ),
    );
  }

  Widget _buildCampoNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del servicio *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nombreController,
          decoration: InputDecoration(
            hintText: 'Ej: Plomería residencial',
            prefixIcon: const Icon(Icons.home_repair_service),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (valor) => AyudantesServicio.validarLongitudTexto(
            valor, 'El nombre', 3, 50,
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildCampoCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _categoriaSeleccionada,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: AyudantesServicio.obtenerCategorias()
              .map((categoria) => DropdownMenuItem(
                    value: categoria['valor'],
                    child: Text(categoria['nombre']!),
                  ))
              .toList(),
          onChanged: (valor) {
            setState(() {
              _categoriaSeleccionada = valor!;
              // Actualizar precio sugerido
              if (_precioController.text.isEmpty || 
                  _precioController.text == AyudantesServicio.obtenerPrecioSugerido(_categoriaSeleccionada).toString()) {
                _precioController.text = AyudantesServicio.obtenerPrecioSugerido(_categoriaSeleccionada).toString();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildCampoDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe tu servicio detalladamente...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (valor) => AyudantesServicio.validarLongitudTexto(
            valor, 'La descripción', 10, 500,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildCampoPrecio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precio por hora *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _precioController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: 'USD',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: AyudantesServicio.validarPrecio,
        ),
      ],
    );
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _estaCargando ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _esEdicion ? 'Actualizar' : 'Agregar',
            onPressed: _estaCargando ? null : _guardarServicio,
            isLoading: _estaCargando,
          ),
        ),
      ],
    );
  }

  void _guardarServicio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    try {
      final servicio = _esEdicion
          ? widget.servicio!.copyWith(
              nombre: _nombreController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              categoria: _categoriaSeleccionada,
              precioPorHora: double.parse(_precioController.text),
              fechaActualizacion: DateTime.now(),
            )
          : ModeloServicio.nuevo(
              nombre: _nombreController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              categoria: _categoriaSeleccionada,
              precioPorHora: double.parse(_precioController.text),
              proveedorId: widget.proveedorId,
            );

      // Simular guardado
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.of(context).pop(servicio);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }
}