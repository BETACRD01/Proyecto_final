// nucleo/widgets/client/seccion_acciones_rapidas.dart
import 'package:flutter/material.dart';
import '../../../../nucleo/constantes/colores_app.dart';

class SeccionAccionesRapidas extends StatelessWidget {
 final VoidCallback alNavegarAReservas;
 final VoidCallback alNavegarAChat;

 const SeccionAccionesRapidas({
   Key? key,
   required this.alNavegarAReservas,
   required this.alNavegarAChat,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 20),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           '¿Qué quieres hacer?',
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: AppColors.textPrimary,
           ),
         ),
         const SizedBox(height: 15),
         _construirGrillaAcciones(context),
       ],
     ),
   );
 }

 Widget _construirGrillaAcciones(BuildContext context) {
   final acciones = [
     {
       'titulo': 'Contratar\nservicio',
       'icono': Icons.handyman,
       'color': AppColors.primary,
       'accion': () => _navegarAServicios(context),
     },
     {
       'titulo': 'Ver mis\nreservas',
       'icono': Icons.calendar_today,
       'color': AppColors.success,
       'accion': alNavegarAReservas,
     },
     {
       'titulo': 'Buscar por\ncategoría',
       'icono': Icons.search,
       'color': AppColors.secondary,
       'accion': () => _navegarABusqueda(context),
     },
     {
       'titulo': 'Contactar\nsoporte',
       'icono': Icons.support_agent,
       'color': AppColors.warning,
       'accion': alNavegarAChat,
     },
     {
       'titulo': 'Ver\nhistorial',
       'icono': Icons.history,
       'color': AppColors.info,
       'accion': () => _mostrarHistorial(context),
     },
     {
       'titulo': 'Calificar\nservicio',
       'icono': Icons.star_rate,
       'color': AppColors.accent,
       'accion': () => _mostrarCalificaciones(context),
     },
   ];

   return Column(
     children: [
       _construirFilaAcciones(context, acciones.sublist(0, 3)),
       const SizedBox(height: 12),
       _construirFilaAcciones(context, acciones.sublist(3, 6)),
     ],
   );
 }

 Widget _construirFilaAcciones(BuildContext context, List<Map<String, dynamic>> acciones) {
   return Row(
     children: acciones.map((accion) {
       return Expanded(
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 6),
           child: TarjetaAccion(
             titulo: accion['titulo'] as String,
             icono: accion['icono'] as IconData,
             color: accion['color'] as Color,
             alTocar: accion['accion'] as VoidCallback?,
           ),
         ),
       );
     }).toList(),
   );
 }

 void _navegarAServicios(BuildContext context) {
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text('🔧 Navegando a servicios...'),
       backgroundColor: AppColors.primary,
       behavior: SnackBarBehavior.floating,
     ),
   );
 }

 void _navegarABusqueda(BuildContext context) {
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text('🔍 Función de búsqueda próximamente'),
       backgroundColor: AppColors.secondary,
       behavior: SnackBarBehavior.floating,
     ),
   );
 }

 void _mostrarHistorial(BuildContext context) {
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text('📋 Historial próximamente'),
       backgroundColor: AppColors.info,
       behavior: SnackBarBehavior.floating,
     ),
   );
 }

 void _mostrarCalificaciones(BuildContext context) {
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text('⭐ Calificaciones próximamente'),
       backgroundColor: AppColors.accent,
       behavior: SnackBarBehavior.floating,
     ),
   );
 }
}

class TarjetaAccion extends StatelessWidget {
 final String titulo;
 final IconData icono;
 final Color color;
 final VoidCallback? alTocar;

 const TarjetaAccion({
   Key? key,
   required this.titulo,
   required this.icono,
   required this.color,
   this.alTocar,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Material(
     color: Colors.transparent,
     child: InkWell(
       onTap: alTocar ?? () => _mostrarMensajeProximamente(context),
       borderRadius: BorderRadius.circular(12),
       child: Container(
         height: 100,
         decoration: BoxDecoration(
           color: AppColors.surface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: AppColors.divider),
           boxShadow: [
             BoxShadow(
               color: AppColors.shadow,
               blurRadius: 8,
               offset: const Offset(0, 2),
             ),
           ],
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Icon(icono, color: color, size: 22),
             ),
             const SizedBox(height: 8),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 4),
               child: Text(
                 titulo,
                 style: const TextStyle(
                   fontSize: 11,
                   fontWeight: FontWeight.w600,
                   color: AppColors.textPrimary,
                   height: 1.2,
                 ),
                 textAlign: TextAlign.center,
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

 void _mostrarMensajeProximamente(BuildContext context) {
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('$titulo próximamente'),
       backgroundColor: color,
       behavior: SnackBarBehavior.floating,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
     ),
   );
 }
}