import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service_model.dart';
import '../common/chat_screen.dart';
import 'profile_screen.dart';
import '../booking/booking_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateToBookings() {
    setState(() {
      _currentIndex = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToChat() {
    setState(() {
      _currentIndex = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _HomeTab(
            onNavigateToBookings: navigateToBookings,
            onNavigateToChat: navigateToChat,
          ),
          const BookingListScreen(),
          const ChatScreen(),
          const ProfileScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: AppStrings.bookings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onNavigateToBookings;
  final VoidCallback onNavigateToChat;

  const _HomeTab({
    required this.onNavigateToBookings,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ServiceProvider>(context, listen: false)
              .loadServices();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 24),
              _buildServiceCategories(context),
              const SizedBox(height: 24),
              _buildPopularServices(context),
              const SizedBox(height: 24),
              _buildFeaturedProviders(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        String userName = 'Usuario';

        if (authProvider.currentUser != null) {
          final user = authProvider.currentUser!;
          if (user.name.isNotEmpty) {
            userName = user.name;
          } else if (user.email.isNotEmpty) {
            userName = user.email.split('@')[0];
          }
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¿Qué servicio necesitas hoy?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificaciones próximamente'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TEMPORALMENTE DESHABILITADO hasta obtener el nombre correcto de la clase
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Búsqueda próximamente disponible'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Buscar servicios...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategories(BuildContext context) {
    final categories = [
      {
        'name': 'Limpieza',
        'icon': Icons.cleaning_services,
        'category': 'Limpieza'
      },
      {'name': 'Plomería', 'icon': Icons.plumbing, 'category': 'Plomería'},
      {
        'name': 'Electricidad',
        'icon': Icons.electrical_services,
        'category': 'Electricidad'
      },
      {
        'name': 'Carpintería',
        'icon': Icons.handyman,
        'category': 'Carpintería'
      },
      {'name': 'Más', 'icon': Icons.more_horiz, 'category': null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ver todas las categorías próximamente'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: categories
              .map((category) => Expanded(
                    child: _buildCategoryItem(
                      context,
                      category['name'] as String,
                      category['icon'] as IconData,
                      category['category'] as String?,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String name, IconData icon, String? category) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoría ${category ?? name} próximamente'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category != null
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: category != null
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.grey[400]!,
                ),
              ),
              child: Icon(
                icon,
                color: category != null ? AppColors.primary : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    category != null ? AppColors.textPrimary : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Servicios Populares',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ver todos los servicios próximamente'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            if (serviceProvider.isLoading) {
              return _buildServicesSkeleton();
            }

            if (serviceProvider.services.isEmpty) {
              return _buildEmptyServices('No hay servicios disponibles');
            }

            final displayServices = serviceProvider.services.take(5).toList();

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayServices.length,
                itemBuilder: (context, index) {
                  final service = displayServices[index];
                  return _buildServiceCard(context, service);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedProviders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            if (serviceProvider.isLoading) {
              return _buildServicesSkeleton();
            }

            if (serviceProvider.services.isEmpty) {
              return _buildEmptyServices('No hay servicios disponibles');
            }

            final recentServices = serviceProvider.services.take(3).toList();

            return Column(
              children: recentServices
                  .map((service) => _buildServiceListItem(context, service))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // Método mejorado para obtener el precio del servicio
  String _getServicePrice(ServiceModel service) {
    // Método directo y limpio para acceder al precio
    try {
      // Asumiendo que ServiceModel tiene una propiedad 'price' de tipo double
      // Si no es así, ajusta según tu modelo

      // Opción 1: Si ServiceModel tiene getter price
      // return service.price?.toStringAsFixed(0) ?? 'N/A';

      // Opción 2: Si ServiceModel tiene diferentes campos de precio
      // Usa reflection de manera segura
      final Map<String, dynamic> serviceData = _serviceToMap(service);

      // Buscar campos de precio comunes
      final priceFields = ['price', 'basePrice', 'cost', 'amount', 'fee'];

      for (String field in priceFields) {
        if (serviceData.containsKey(field) && serviceData[field] != null) {
          final value = serviceData[field];
          if (value is num) {
            return value.toStringAsFixed(0);
          } else if (value is String) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              return parsed.toStringAsFixed(0);
            }
          }
        }
      }

      return 'Consultar';
    } catch (e) {
      debugPrint('Error obteniendo precio del servicio: $e');
      return 'N/A';
    }
  }

  // Método auxiliar para convertir ServiceModel a Map
  Map<String, dynamic> _serviceToMap(ServiceModel service) {
    // Esta implementación depende de tu ServiceModel específico
    // Opción 1: Si ServiceModel tiene método toJson()
    // return service.toJson();

    // Opción 2: Mapeo manual (ajusta según tu modelo)
    return {
      'id': service.id,
      'description': service.description,
      'providerName': service.providerName,
      'category': service.category,
      'rating': service.rating,
      'isActive': service.isActive,
      // Añade aquí los campos de precio que tenga tu modelo
      // 'price': service.price,
      // 'basePrice': service.basePrice,
      // etc.
    };
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    return GestureDetector(
      onTap: () {
        _showServiceDialog(context, service);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: _buildServiceIcon(service.category.toString()),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.providerName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_getServicePrice(service)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceListItem(BuildContext context, ServiceModel service) {
    return GestureDetector(
      onTap: () {
        _showServiceDialog(context, service);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildServiceIcon(service.category.toString()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.providerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${_getServicePrice(service)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método centralizado para mostrar diálogo de servicio
  void _showServiceDialog(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogInfo('Proveedor', service.providerName),
            _buildDialogInfo(
                'Rating', '${service.rating.toStringAsFixed(1)} ⭐'),
            _buildDialogInfo('Precio', '\$${_getServicePrice(service)}'),
            _buildDialogInfo('Categoría', service.category.toString()),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  service.isActive ? Icons.check_circle : Icons.cancel,
                  color: service.isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  service.isActive ? 'Servicio activo' : 'Servicio inactivo',
                  style: TextStyle(
                    color: service.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (service.isActive)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reservando ${service.description}...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Reservar'),
            ),
        ],
      ),
    );
  }

  Widget _buildDialogInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(String category) {
    IconData icon;
    switch (category.toLowerCase()) {
      case 'cleaning':
      case 'limpieza':
        icon = Icons.cleaning_services;
        break;
      case 'plumbing':
      case 'plomería':
        icon = Icons.plumbing;
        break;
      case 'electrical':
      case 'electricidad':
        icon = Icons.electrical_services;
        break;
      case 'carpentry':
      case 'carpintería':
        icon = Icons.handyman;
        break;
      case 'beauty':
      case 'belleza':
        icon = Icons.face;
        break;
      case 'maintenance':
      case 'mantenimiento':
        icon = Icons.build;
        break;
      default:
        icon = Icons.build;
    }

    return Center(
      child: Icon(
        icon,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildServicesSkeleton() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 180,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyServices(String message) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
