// lib/pantallas/reservas/pantalla_formulario_reserva.dart
import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/rutas_app.dart';

/// 📝 Pantalla para crear una nueva reserva
class PantallaFormularioReserva extends StatefulWidget {
  const PantallaFormularioReserva({Key? key}) : super(key: key);

  @override
  State<PantallaFormularioReserva> createState() => _PantallaFormularioReservaState();
}

class _PantallaFormularioReservaState extends State<PantallaFormularioReserva> {
  final _formKey = GlobalKey<FormState>();
  final _servicioController = TextEditingController(text: 'Consulta Médica');
  final _proveedorController = TextEditingController(text: 'Dr. Juan Pérez');
  final _notasController = TextEditingController();
  final _precioController = TextEditingController(text: '50.00');
  
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  bool cargando = false;
  bool terminosAceptados = false;

  @override
  void dispose() {
    _servicioController.dispose();
    _proveedorController.dispose();
    _notasController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _construirAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _construirTarjetaServicio(),
              const SizedBox(height: 20),
              _construirTarjetaFechaHora(),
              const SizedBox(height: 20),
              _construirTarjetaNotas(),
              const SizedBox(height: 20),
              _construirTarjetaResumen(),
              const SizedBox(height: 20),
              _construirTerminos(),
              const SizedBox(height: 30),
              _construirBotonReservar(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 AppBar simple
  AppBar _construirAppBar() {
    return AppBar(
      title: const Text('Nueva Reserva'),
      backgroundColor: const Color(0xFF1B365D),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  /// 🏷️ Información del servicio
  Widget _construirTarjetaServicio() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Servicio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _servicioController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                prefixIcon: Icon(Icons.business_center),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre del servicio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proveedorController,
              decoration: const InputDecoration(
                labelText: 'Proveedor',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre del proveedor';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (\$)',
                prefixIcon: Icon(Icons.monetization_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un precio válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 Selección de fecha y hora
  Widget _construirTarjetaFechaHora() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fecha y Hora',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            // Selector de fecha
            InkWell(
              onTap: _seleccionarFecha,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF9FAFB),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fechaSeleccionada != null
                            ? '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}'
                            : 'Seleccionar fecha',
                        style: TextStyle(
                          fontSize: 16,
                          color: fechaSeleccionada != null
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Selector de hora
            InkWell(
              onTap: _seleccionarHora,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF9FAFB),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        horaSeleccionada != null
                            ? horaSeleccionada!.format(context)
                            : 'Seleccionar hora',
                        style: TextStyle(
                          fontSize: 16,
                          color: horaSeleccionada != null
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📝 Campo de notas
  Widget _construirTarjetaNotas() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas Adicionales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Agrega cualquier información adicional sobre tu reserva...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 Resumen de la reserva
  Widget _construirTarjetaResumen() {
    if (fechaSeleccionada == null || horaSeleccionada == null) {
      return const SizedBox.shrink();
    }



    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.1),
              const Color(0xFF059669).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de la Reserva',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _construirItemResumen('Servicio', _servicioController.text),
            _construirItemResumen('Proveedor', _proveedorController.text),
            _construirItemResumen(
              'Fecha',
              '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
            ),
            _construirItemResumen('Hora', horaSeleccionada!.format(context)),
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Total a pagar:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Text(
                  '\${precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemResumen(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$etiqueta:',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Términos y condiciones
  Widget _construirTerminos() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Checkbox(
              value: terminosAceptados,
              onChanged: (value) {
                setState(() {
                  terminosAceptados = value ?? false;
                });
              },
              activeColor: const Color(0xFF1B365D),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    terminosAceptados = !terminosAceptados;
                  });
                },
                child: const Text(
                  'Acepto los términos y condiciones del servicio',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Botón para confirmar reserva
  Widget _construirBotonReservar() {
    final puedeReservar = fechaSeleccionada != null &&
        horaSeleccionada != null &&
        terminosAceptados &&
        !cargando;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: puedeReservar ? _confirmarReserva : null,
        icon: cargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.event_available),
        label: Text(cargando ? 'Procesando...' : 'Confirmar Reserva'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B365D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🎯 MÉTODOS DE ACCIÓN

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B365D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B365D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  Future<void> _confirmarReserva() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
    });

    try {
      // Simulamos la creación de la reserva
      await Future.delayed(const Duration(seconds: 2));
      
      // Aquí conectarías con tu BookingProvider real:
      /*
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final fechaCompleta = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      );
      
      final exito = await bookingProvider.createBooking(
        serviceName: _servicioController.text,
        providerName: _proveedorController.text,
        scheduledDate: fechaCompleta,
        totalPrice: double.parse(_precioController.text),
        notes: _notasController.text.trim(),
      );
      */

      // Por ahora simulamos éxito
      final exito = true;

      if (exito && mounted) {
        _mostrarExito();
        // Esperar un poco y navegar a la lista de reservas
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.bookings);
        }
      } else {
        _mostrarError('No se pudo crear la reserva. Intenta nuevamente.');
      }
    } catch (e) {
      _mostrarError('Error al crear la reserva: $e');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void _mostrarExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('¡Reserva creada exitosamente!'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}