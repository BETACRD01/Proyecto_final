// lib/pantallas/chat/widgets/barra_busqueda.dart

import 'package:flutter/material.dart';

class BarraBusqueda extends StatelessWidget {
  final VoidCallback alTocarBuscar;
  final VoidCallback alTocarFiltro;
  final String? consultaBusqueda;
  final ValueChanged<String>? alCambiarBusqueda;
  final bool esInteractiva;

  const BarraBusqueda({
    Key? key,
    required this.alTocarBuscar,
    required this.alTocarFiltro,
    this.consultaBusqueda,
    this.alCambiarBusqueda,
    this.esInteractiva = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: esInteractiva ? _construirBarraInteractiva() : _construirBarraTocable(),
        ),
      ),
    );
  }

  Widget _construirBarraTocable() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: alTocarBuscar,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Buscar conversaciones...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            GestureDetector(
              onTap: alTocarFiltro,
              child: Icon(
                Icons.tune_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBarraInteractiva() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: alCambiarBusqueda,
              decoration: const InputDecoration(
                hintText: 'Buscar conversaciones...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          GestureDetector(
            onTap: alTocarFiltro,
            child: Icon(
              Icons.tune_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}