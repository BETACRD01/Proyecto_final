class AppRoutes {
  // 🔹 RUTAS DE AUTENTICACIÓN
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // 🔹 RUTAS DE USUARIO CLIENTE
  static const String home = '/home';
  static const String profile = '/profile';
  static const String services = '/services';
  static const String serviceDetail = '/service-detail';
  static const String bookingForm = '/booking-form';
  static const String bookings = '/bookings';
  static const String bookingDetail = '/booking-detail';

  // 🔹 RUTAS DE PROVEEDOR
  static const String providerHome = '/provider-home';
  static const String providerDashboard = '/provider-dashboard';
  static const String providerServices = '/provider-services';
  static const String providerBookings = '/provider-bookings';
  static const String providerProfile = '/provider-profile';
  static const String providerRegistrationForm = '/provider-registration-form';

  // 🔹 RUTAS DE ADMINISTRADOR
  static const String adminHome = '/admin-home';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminProviders = '/admin-providers';
  static const String adminUsers = '/admin-users';
  static const String adminServices = '/admin-services';
  static const String adminSettings = '/admin-settings';

  // 🔹 RUTAS COMPARTIDAS/GENERALES
  static const String map = '/map';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String search = '/search';

  // 🔹 RUTAS LEGALES/INFORMACIÓN
  static const String termsAndConditions = '/terms-and-conditions';
  static const String privacyPolicy = '/privacy-policy';
  static const String aboutUs = '/about-us';
  static const String helpAndSupport = '/help-and-support';
}
