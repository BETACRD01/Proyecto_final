import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'provider_dashboard.dart';
import 'provider_services.dart';
import 'provider_bookings.dart';
import '../common/chat_screen.dart';
import '../client/profile_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Verificar que el usuario sea realmente un proveedor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserPermissions();
    });
  }

  void _checkUserPermissions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null || user.userType != UserType.provider) {
      // Redirigir al login o pantalla de acceso denegado
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

  void navigateToServices() {
    setState(() {
      _currentIndex = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToBookings() {
    setState(() {
      _currentIndex = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToChat() {
    setState(() {
      _currentIndex = 3;
    });
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToProfile() {
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
        if (user == null || user.userType != UserType.provider) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acceso denegado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solo proveedores autorizados pueden acceder',
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
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              ProviderDashboard(),
              ProviderServices(),
              ProviderBookings(),
              ChatScreen(),
              ProfileScreen(),
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
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_repair_service_outlined),
                activeIcon: Icon(Icons.home_repair_service),
                label: 'Servicios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Reservas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
          // Floating Action Button para acciones rápidas
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    // Solo mostrar FAB en ciertas pestañas
    switch (_currentIndex) {
      case 1: // Servicios
        return FloatingActionButton(
          onPressed: () {
            // Acción para agregar nuevo servicio
            _showAddServiceDialog();
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 2: // Reservas
        return FloatingActionButton.extended(
          onPressed: () {
            // Acción para ver reservas pendientes
            _showPendingBookings();
          },
          backgroundColor: AppColors.secondary,
          icon: const Icon(Icons.notification_important),
          label: const Text('Pendientes'),
        );
      default:
        return null;
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_business, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Nuevo Servicio'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Deseas agregar un nuevo servicio?'),
            SizedBox(height: 8),
            Text(
              'Podrás configurar todos los detalles en la siguiente pantalla.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla de creación de servicio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de crear servicio próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showPendingBookings() {
    // Navegar directamente a la pestaña de pendientes en Reservas
    navigateToBookings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mostrando reservas pendientes'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Widget adicional para mostrar notificaciones en la app bar
class ProviderAppBarNotifications extends StatelessWidget {
  const ProviderAppBarNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            _showNotificationsDialog(context);
          },
        ),
        // Badge de notificaciones
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
              '3', // Número de notificaciones pendientes
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
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Notificaciones'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationItem(
              icon: Icons.calendar_today,
              title: 'Nueva reserva',
              subtitle: 'Limpieza de hogar - Mañana 10:00 AM',
              time: 'Hace 5 min',
            ),
            Divider(),
            _NotificationItem(
              icon: Icons.star,
              title: 'Nueva calificación',
              subtitle: 'Cliente te dio 5 estrellas',
              time: 'Hace 1 hora',
            ),
            Divider(),
            _NotificationItem(
              icon: Icons.message,
              title: 'Mensaje nuevo',
              subtitle: 'Cliente pregunta sobre el servicio',
              time: 'Hace 2 horas',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla completa de notificaciones
            },
            child: const Text('Ver todas'),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
