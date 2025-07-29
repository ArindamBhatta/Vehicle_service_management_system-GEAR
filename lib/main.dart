import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_riverpod/core/model/user_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/provider/user_provider.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:learn_riverpod/core/widgets/error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRoute {
  static const splash = '/splash';
  static const login = '/login';
  static const roleSelection = '/role-selection';
  static const onboardingShop = '/onboarding/shop';
  static const onboardingCarOwner = '/onboarding/car_owner';
  static const garage = '/garage';
  static const shopDashboard = '/shop-dashboard';
}

// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  // Watch essential providers
  final AsyncValue<User?> authState = ref.watch(authStateChangesProvider);
  //
  final AsyncValue<AppUser?> currentUser = ref.watch(currentUserProvider);

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
      GoRoute(
        path: AppRoute.login,
        name: AppRoute.login,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoute.roleSelection,
        name: AppRoute.roleSelection,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoute.onboardingShop,
        name: AppRoute.onboardingShop,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoute.onboardingCarOwner,
        name: AppRoute.onboardingCarOwner,
        builder: (context, state) => const Placeholder(),
      ),
      // GoRoute(
      //   path: AppRoute.garage,
      //   name: AppRoute.garage,
      //   builder: (context, state) => const ChatOverlay(
      //     currentRoute: AppRoute.garage,
      //     child: GaragePage(),
      //   ),
      // ),
      //after login going to shop dashboard
      // GoRoute(
      //   path: AppRoute.shopDashboard,
      //   name: AppRoute.shopDashboard,
      //   builder: (context, state) => const ChatOverlay(
      //     currentRoute: AppRoute.shopDashboard,
      //     child: ShopDashBoardNavigation(),
      //   ),
      // ),
    ],
    //defined redriect logic
    redirect: (BuildContext context, GoRouterState state) {
      final String currentPath = state.matchedLocation;
      AppLogger.logger.d("Redirect check: Current location = $currentPath");

      //Stay on splash until user manually moves
      if (authState.isLoading || currentPath == AppRoute.splash) {
        return null;
      }

      // Only proceed if splashDelay has finished (is not loading anymore)
      AppLogger.logger.d(
        "Redirect: Splash delay finished, auth state resolved.",
      );

      if (authState.hasError) {
        AppLogger.logger.e("Redirect: Auth error, redirecting to login.");
        return (currentPath == AppRoute.login) ? null : AppRoute.login;
      }

      //

      final supabaseUser = authState.value;

      final bool loggedIn = supabaseUser != null;
      AppLogger.logger.d("Redirect: LoggedIn = $loggedIn");

      if (!loggedIn) {
        AppLogger.logger.d("Redirect: User not logged in.");

        if (currentPath == AppRoute.login) {
          AppLogger.logger.d("Redirect: Allowing access to login screen.");
          return null; // Stay on login
        } else {
          AppLogger.logger.d(
            "Redirect: Forcing redirect to login from $currentPath.",
          );
          return AppRoute.login;
        }
      }

      return currentUser.when(
        data: (appUser) {
          AppLogger.logger.d(
            "AppUser data received: ${appUser?.toString() ?? 'null'}",
          );

          // This might happen briefly or if profile creation failed.
          if (appUser == null) {
            AppLogger.logger.e(
              "Redirect: Logged in but AppUser is null after future resolved. Redirecting to login (potential sign out).",
            );
            Future(() => ref.read(authServiceProvider).signOut());
            return AppRoute.login;
          }

          final homeRoute = appUser.role.isShopRelated
              ? AppRoute.shopDashboard
              : AppRoute.garage;

          // Add both onboarding routes here
          final intermediateRoutes = [
            AppRoute.splash,
            AppRoute.login,
            AppRoute.roleSelection,
            AppRoute.onboardingShop,
            AppRoute.onboardingCarOwner,
          ];

          //! filter out intermediateRoutes condition not work
          if (intermediateRoutes.contains(currentPath)) {
            AppLogger.logger.d(
              " Redirect: Redirecting user from intermediate route $currentPath to home route $homeRoute.",
            );
            return homeRoute;
          }

          return null;
        },
        loading: () {
          AppLogger.logger.d("Redirect: AppUser profile loading.");
          if (currentPath != AppRoute.splash) {
            AppLogger.logger.d(
              "Redirect: Profile loading, showing splash from $currentPath.",
            );
            return AppRoute.splash;
          }
          AppLogger.logger.d("Redirect: Profile loading, staying on splash.");
          return null;
        },
        error: (error, stack) {
          AppLogger.logger.e(
            "Redirect: Error loading AppUser, redirecting to login.",
            error: error,
            stackTrace: stack,
          );
          Future(() => ref.read(authServiceProvider).signOut());
          return AppRoute.login;
        },
      );
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

    runApp(const ProviderScope(child: MyApp()));
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

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // Watch the router provider

    return MaterialApp.router(
      title: 'Restomag Garage',
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
