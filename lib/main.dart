import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gear_app/core/provider/auth_provider.dart';
import 'package:gear_app/core/utils/logger.dart';
import 'package:gear_app/core/widgets/error.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRoute {
  static const splash = '/splash';
  static const onBoarding = '/on-boarding';
  static const login = '/login';
}

// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: true,
    routes: [
      // Define routes using AppRoute constants
      GoRoute(
        path: AppRoute.splash,
        name: AppRoute.splash,
        builder: (context, state) => const Placeholder(),
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) {
      final String currentPath = state.matchedLocation;
      AppLogger.logger.d("Redirect check: Current location = $currentPath");
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateChangesProvider.stream),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env.dev");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        '.env file not found or SUPABASE_URL/SUPABASE_ANON_KEY missing.',
      );
    }

    AppLogger.logger.i('Initializing Supabase...');
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    AppLogger.logger.i('Supabase initialized successfully.');

    runApp(const ProviderScope(child: GearApp()));
  } catch (e, stackTrace) {
    AppLogger.logger.e(
      'Error initializing app',
      error: e,
      stackTrace: stackTrace,
    );
    // Consider showing a more user-friendly error UI using the router if possible
    runApp(ErrorApp(error: e.toString()));
  }
}

class GearApp extends HookConsumerWidget {
  const GearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // Watch the router provider

    return MaterialApp.router(
      title: 'Restomag Garage',
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
