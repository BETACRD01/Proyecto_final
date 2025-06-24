// lib/caracteristicas/servicios_proveedor/modelos/modelo_servicio.dart

class ModeloServicio {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final double precioPorHora;
  final bool estaActivo;
  final double calificacion;
  final int totalCalificaciones;
  final String proveedorId;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  const ModeloServicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precioPorHora,
    required this.estaActivo,
    required this.calificacion,
    required this.totalCalificaciones,
    required this.proveedorId,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // Constructor para crear servicio nuevo
  ModeloServicio.nuevo({
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precioPorHora,
    required this.proveedorId,
  })  : id = '',
        estaActivo = true,
        calificacion = 0.0,
        totalCalificaciones = 0,
        fechaCreacion = DateTime.now(),
        fechaActualizacion = DateTime.now();

  // Método copyWith para actualizaciones
  ModeloServicio copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? categoria,
    double? precioPorHora,
    bool? estaActivo,
    double? calificacion,
    int? totalCalificaciones,
    String? proveedorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ModeloServicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precioPorHora: precioPorHora ?? this.precioPorHora,
      estaActivo: estaActivo ?? this.estaActivo,
      calificacion: calificacion ?? this.calificacion,
      totalCalificaciones: totalCalificaciones ?? this.totalCalificaciones,
      proveedorId: proveedorId ?? this.proveedorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  // Conversión a Map para API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio_por_hora': precioPorHora,
      'esta_activo': estaActivo,
      'calificacion': calificacion,
      'total_calificaciones': totalCalificaciones,
      'proveedor_id': proveedorId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  // Crear desde Map (desde API)
  factory ModeloServicio.fromMap(Map<String, dynamic> map) {
    return ModeloServicio(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: map['categoria'] ?? '',
      precioPorHora: (map['precio_por_hora'] ?? 0.0).toDouble(),
      estaActivo: map['esta_activo'] ?? true,
      calificacion: (map['calificacion'] ?? 0.0).toDouble(),
      totalCalificaciones: map['total_calificaciones'] ?? 0,
      proveedorId: map['proveedor_id'] ?? '',
      fechaCreacion: DateTime.tryParse(map['fecha_creacion'] ?? '') ?? DateTime.now(),
      fechaActualizacion: DateTime.tryParse(map['fecha_actualizacion'] ?? '') ?? DateTime.now(),
    );
  }

  // Validaciones
  bool get esValido {
    return nombre.isNotEmpty &&
           descripcion.isNotEmpty &&
           categoria.isNotEmpty &&
           precioPorHora > 0 &&
           proveedorId.isNotEmpty;
  }

  String? validarNombre() {
    if (nombre.isEmpty) return 'El nombre es requerido';
    if (nombre.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    if (nombre.length > 50) return 'El nombre no puede exceder 50 caracteres';
    return null;
  }

  String? validarDescripcion() {
    if (descripcion.isEmpty) return 'La descripción es requerida';
    if (descripcion.length < 10) return 'La descripción debe tener al menos 10 caracteres';
    if (descripcion.length > 500) return 'La descripción no puede exceder 500 caracteres';
    return null;
  }

  String? validarPrecio() {
    if (precioPorHora <= 0) return 'El precio debe ser mayor a 0';
   return 'El precio no puede exceder \$10,000';
  }

  @override
  String toString() {
    return 'ModeloServicio(id: $id, nombre: $nombre, categoria: $categoria, precio: $precioPorHora)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModeloServicio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}