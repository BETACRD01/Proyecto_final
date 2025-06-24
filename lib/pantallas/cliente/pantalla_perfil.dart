// lib/pantallas/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client/home/widget_cargando.dart';
import '../../proveedores/proveedor_autenticacion.dart';
import '../../modelos/modelo_usuario.dart';
import 'client/perfil/controlador_perfil.dart';
import 'client/perfil/widgets_perfil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      context: context, 
      vsync: this,
      onUpdate: () => setState(() {}),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadUserData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Estados de carga
          if (!authProvider.isInitialized) {
            return const Center(
              child: WidgetCargando(mensaje: 'Inicializando...'),
            );
          }

          if (authProvider.isLoading) {
            return const Center(
              child: WidgetCargando(mensaje: 'Cargando perfil...'),
            );
          }

          final user = authProvider.currentUser;
          if (user == null) {
           return ProfileWidgets.buildErrorState(authProvider, context);
          }

          return ProfileWidgets.buildLoadingOverlay(
            isLoading: _controller.isLoading,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                ProfileWidgets.buildAppBar(user, _controller),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileWidgets.buildProfileStats(user),
                      const SizedBox(height: 16),
                      if (_controller.isEditing) ...[
                        ProfileWidgets.buildEditingForm(user, _controller),
                        const SizedBox(height: 24),
                      ] else ...[
                        ProfileWidgets.buildQuickActions(user, _controller),
                        const SizedBox(height: 24),
                        if (user.userType == UserType.provider)
                          Column(
                            children: [
                              ProfileWidgets.buildProviderSection(user),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ProfileWidgets.buildSettingsSection(_controller),
                        const SizedBox(height: 32),
                      ],
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}