// lib/pantallas/chat/widgets/item_conversacion.dart

import 'package:flutter/material.dart';
import '../modelos/modelo_conversacion.dart';
import '../utilidades/utilidades_chat.dart';

class ItemConversacion extends StatelessWidget {
  final ModeloConversacion conversacion;
  final VoidCallback alTocar;
  final VoidCallback alMantenerPresionado;

  const ItemConversacion({
    Key? key,
    required this.conversacion,
    required this.alTocar,
    required this.alMantenerPresionado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tieneNoLeidos = conversacion.mensajesNoLeidos > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: conversacion.colorCategoria.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: alTocar,
          onLongPress: alMantenerPresionado,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _construirAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: _construirInfoConversacion(tieneNoLeidos),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirAvatar() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                conversacion.colorCategoria,
                conversacion.colorCategoria.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: conversacion.colorCategoria.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            conversacion.avatar,
            color: Colors.white,
            size: 28,
          ),
        ),
        if (conversacion.estaEnLinea)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _construirInfoConversacion(bool tieneNoLeidos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                conversacion.nombreProveedor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: tieneNoLeidos ? FontWeight.bold : FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              UtilidadesChat.formatearTiempo(conversacion.fechaHora),
              style: TextStyle(
                fontSize: 12,
                color: tieneNoLeidos ? conversacion.colorCategoria : const Color(0xFF64748B),
                fontWeight: tieneNoLeidos ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          conversacion.nombreServicio,
          style: TextStyle(
            fontSize: 13,
            color: conversacion.colorCategoria,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                conversacion.ultimoMensaje,
                style: TextStyle(
                  fontSize: 14,
                  color: tieneNoLeidos
                      ? const Color(0xFF374151)
                      : const Color(0xFF64748B),
                  fontWeight: tieneNoLeidos ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tieneNoLeidos)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: conversacion.colorCategoria,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  UtilidadesChat.formatearConteoNoLeidos(conversacion.mensajesNoLeidos),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}