import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nucleo/constantes/colores_app.dart';
import '../../proveedores/proveedor_autenticacion.dart';
import '../../modelos/modelo_usuario.dart';
import 'tablero/tablero_administrador.dart';
import 'proveedores/pantalla_proveedores_admin.dart';
import 'usuarios/pantalla_usuarios_admin.dart';
import 'servicios/pantalla_servicios_admin.dart';
import 'configuracion/pantalla_configuracion_admin.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Verificar permisos de administrador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminPermissions();
    });
  }

  void _checkAdminPermissions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null || user.userType != UserType.admin) {
      // Redirigir si no es administrador
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateToDashboard() {
    setState(() {
      _currentIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToProviders() {
    setState(() {
      _currentIndex = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToUsers() {
    setState(() {
      _currentIndex = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToServices() {
    setState(() {
      _currentIndex = 3;
    });
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToSettings() {
    setState(() {
      _currentIndex = 4;
    });
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        // Verificación de seguridad
        if (user == null || user.userType != UserType.admin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acceso Restringido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solo administradores autorizados pueden acceder',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Volver al Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(user),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              AdminDashboard(),
              AdminProvidersScreen(),
              AdminUsersScreen(),
              AdminServicesScreen(),
              AdminSettingsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'Proveedores',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Usuarios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_repair_service_outlined),
                activeIcon: Icon(Icons.home_repair_service),
                label: 'Servicios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Config',
              ),
            ],
          ),
          // Floating Action Button contextual
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Admin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Hola, ${user.name}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notificaciones de administrador
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                _showAdminNotifications();
              },
            ),
            // Badge de notificaciones pendientes
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3', // Número dinámico de notificaciones
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        // Menú de administrador
        PopupMenuButton<String>(
          onSelected: _handleAdminMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Mi Perfil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'backup',
              child: Row(
                children: [
                  Icon(Icons.backup_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Backup'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logs',
              child: Row(
                children: [
                  Icon(Icons.list_alt, size: 16),
                  SizedBox(width: 8),
                  Text('Logs del Sistema'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Cerrar Sesión',
                      style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
    );
  }

  Widget? _buildFloatingActionButton() {
    // FAB contextual según la pestaña actual
    switch (_currentIndex) {
      case 1: // Proveedores
        return FloatingActionButton.extended(
          onPressed: () {
            _showNewProviderDialog();
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.person_add),
          label: const Text('Nuevo'),
        );
      case 2: // Usuarios
        return FloatingActionButton(
          onPressed: () {
            _showUserStatsDialog();
          },
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.analytics),
        );
      case 3: // Servicios
        return FloatingActionButton(
          onPressed: () {
            _showNewCategoryDialog();
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showAdminNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Notificaciones Admin'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NotificationItem(
                icon: Icons.person_add,
                title: 'Nuevo proveedor pendiente',
                subtitle: 'Juan Pérez solicita aprobación',
                time: 'Hace 5 min',
                isUrgent: true,
              ),
              Divider(),
              _NotificationItem(
                icon: Icons.report_problem,
                title: 'Reporte de servicio',
                subtitle: 'Cliente reportó problema con limpieza',
                time: 'Hace 30 min',
              ),
              Divider(),
              _NotificationItem(
                icon: Icons.security,
                title: 'Login sospechoso detectado',
                subtitle: 'Múltiples intentos fallidos',
                time: 'Hace 1 hora',
                isUrgent: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a panel de notificaciones completo
            },
            child: const Text('Ver todas'),
          ),
        ],
      ),
    );
  }

  void _handleAdminMenuAction(String action) {
    switch (action) {
      case 'profile':
        // Navegar al perfil del admin
        break;
      case 'backup':
        _showBackupDialog();
        break;
      case 'logs':
        _showSystemLogs();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  void _showNewProviderDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Crear nuevo proveedor manualmente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showUserStatsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Estadísticas de usuarios'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNewCategoryDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Crear nueva categoría de servicio'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup del Sistema'),
        content:
            const Text('¿Deseas crear un backup completo de la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar lógica de backup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup iniciado...')),
              );
            },
            child: const Text('Crear Backup'),
          ),
        ],
      ),
    );
  }

  void _showSystemLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función: Ver logs del sistema'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
            '¿Estás seguro de que deseas cerrar sesión como administrador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

// Widget para elementos de notificación
class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isUrgent;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isUrgent ? AppColors.error : AppColors.primary,
            ),
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
                    color: isUrgent ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
