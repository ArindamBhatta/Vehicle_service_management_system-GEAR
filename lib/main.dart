import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:learn_riverpod/core/provider/provider.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

class AppRoute {
  static const splash = '/splash';
  static const login = '/login';
  static const roleSelection = '/role-selection';
  static const onboardingTravelerAgant = '/onboarding/travel_agent';
  static const onboardingTraveler = '/onboarding/traveler';
  static const agantProfile = '/travel/agent_profile';
  static const travelSpotDashBoard = '/travel_dashboard';
}

// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  // Watch essential providers
  final authState = ref.watch(authStateChangesProvider);
  // final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoute.splash,
        name: 'splash',
        builder: (context, state) => Container(),
      ),

      GoRoute(
        path: AppRoute.login,
        name: 'login',
        builder: (context, state) => Container(),
      ),

      GoRoute(
        path: AppRoute.roleSelection,
        name: 'role-selection',
        builder: (context, state) => Container(),
      ),

      GoRoute(
        path: AppRoute.onboardingTravelerAgant,
        name: 'onboarding/travel_agent',
        builder: (context, state) => Container(),
      ),

      GoRoute(
        path: AppRoute.onboardingTraveler,
        name: 'onboarding/traveler',
        builder: (context, state) => Container(),
      ),

      GoRoute(
        path: AppRoute.agantProfile,
        name: 'travel/agent_profile',
        builder: (context, state) => Container(),
      ),
      // GoRoute(
      //   path: AppRoute.travelSpotDashBoard,
      //   name: 'travel_dashboard',
      //   builder: (context, state) => const ChatOverlay(
      //     currentRoute: AppRoute.travelSpotDashBoard,
      //     child: TravelSpotDashBoardPage(),
      //   ),
      // ),
    ],
    //defined redriect logic
    redirect: (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;
      AppLogger.logger.d("Redirect check: Current location = $currentPath");

      // Stay on splash until user manually moves
      // if (authState.isLoading || currentLocation == AppRoute.splash) {
      //   return null; // Stay on splash until user manually moves
      // }
    },
  );
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Container(),
    );
  }
}
