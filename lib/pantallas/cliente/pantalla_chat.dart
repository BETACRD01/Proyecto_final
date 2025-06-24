import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cliente/client/chat/controladores/controlador_chat.dart';
import '../cliente/client/chat/widgets/header_chat.dart';
import '../cliente/client/chat/widgets/barra_busqueda.dart';
import '../cliente/client/chat/widgets/item_conversacion.dart';
import '../cliente/client/chat/widgets/estado_vacio.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late ControladorChat _controlador;          // ✅ AGREGAR: Instancia propia
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionDesvanecimiento;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorChat();         // ✅ AGREGAR: Crear aquí
    _inicializarAnimaciones();
  }

  void _inicializarAnimaciones() {
    _controladorAnimacion = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animacionDesvanecimiento = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controladorAnimacion,
      curve: Curves.easeInOut,
    ));
    _controladorAnimacion.forward();
  }

  @override
  void dispose() {
    _controlador.dispose();                   // ✅ AGREGAR: Disponer manualmente
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(     // ✅ CAMBIO: .value en lugar de create
      value: _controlador,                    // ✅ CAMBIO: Pasar instancia existente
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: FadeTransition(
            opacity: _animacionDesvanecimiento,
            child: Consumer<ControladorChat>(
              builder: (context, controlador, child) {
                return Column(
                  children: [
                    HeaderChat(
                      mensajeEstado: controlador.mensajeEstado,
                      conteoNoLeidos: controlador.totalNoLeidos,
                      alTocarNotificacion: controlador.abrirNotificaciones,
                    ),
                    BarraBusqueda(
                      alTocarBuscar: _abrirBusqueda,
                      alTocarFiltro: controlador.abrirFiltros,
                    ),
                    Expanded(
                      child: _construirCuerpo(controlador),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: Consumer<ControladorChat>(
          builder: (context, controlador, child) {
            return FloatingActionButton(
              onPressed: controlador.iniciarNuevoChat,
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_comment_rounded),
            );
          },
        ),
      ),
    );
  }

  Widget _construirCuerpo(ControladorChat controlador) {
    if (controlador.estaCargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      );
    }

    if (controlador.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              controlador.error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!controlador.disposed) {  // ✅ PROTECCIÓN EXTRA
                  controlador.actualizarConversaciones();
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (controlador.conversacionesFiltradas.isEmpty) {
      return EstadoVacio(
        alIrAServicios: controlador.irAServicios,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (!controlador.disposed) {          // ✅ PROTECCIÓN EXTRA
          await controlador.actualizarConversaciones();
        }
      },
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: controlador.conversacionesFiltradas.length,
        itemBuilder: (context, indice) {
          final conversacion = controlador.conversacionesFiltradas[indice];
          return ItemConversacion(
            conversacion: conversacion,
            alTocar: () => _manejarToque(controlador, conversacion),
            alMantenerPresionado: () => _mostrarOpcionesConversacion(controlador, conversacion),
          );
        },
      ),
    );
  }

  // ===================== MÉTODOS DE ACCIÓN =====================

  void _manejarToque(ControladorChat controlador, conversacion) {
    if (!controlador.disposed) {             // ✅ PROTECCIÓN EXTRA
      controlador.abrirConversacion(conversacion);
    }
    
    // Mostrar feedback visual
    if (mounted) {                           // ✅ PROTECCIÓN EXTRA
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo chat con ${conversacion.nombreProveedor}'),
          backgroundColor: conversacion.colorCategoria,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _mostrarOpcionesConversacion(ControladorChat controlador, conversacion) {
    if (!mounted) return;                    // ✅ PROTECCIÓN EXTRA
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              conversacion.nombreProveedor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.mark_as_unread),
              title: const Text('Marcar como no leído'),
              onTap: () {
                Navigator.pop(context);
                if (!controlador.disposed) {
                  controlador.marcarComoNoLeido(conversacion.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar conversación'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(controlador, conversacion.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Bloquear contacto'),
              onTap: () {
                Navigator.pop(context);
                _confirmarBloqueo(controlador, conversacion.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(ControladorChat controlador, String idConversacion) {
    if (!mounted) return;                    // ✅ PROTECCIÓN EXTRA
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conversación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta conversación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!controlador.disposed) {
                controlador.eliminarConversacion(idConversacion);
                _mostrarMensajeExito('Conversación eliminada');
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmarBloqueo(ControladorChat controlador, String idConversacion) {
    if (!mounted) return;                    // ✅ PROTECCIÓN EXTRA
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear contacto'),
        content: const Text('¿Estás seguro de que quieres bloquear este contacto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!controlador.disposed) {
                controlador.bloquearContacto(idConversacion);
                _mostrarMensajeExito('Contacto bloqueado');
              }
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _abrirBusqueda() {
    if (!mounted) return;                    // ✅ PROTECCIÓN EXTRA
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Búsqueda avanzada próximamente'),
        backgroundColor: Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarMensajeExito(String mensaje) {
    if (!mounted) return;                    // ✅ PROTECCIÓN EXTRA
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}