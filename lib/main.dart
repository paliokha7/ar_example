import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'features/ar/presentation/screens/plane_detection_screen.dart';
import 'screens/ar_examples_screen.dart';
import 'screens/face_mask_screen.dart';
import 'screens/ring_try_on_screen.dart';
import 'screens/body_tracking_screen.dart';

void main() {
  init();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/ar-examples',
  routes: [
    GoRoute(
      path: '/ar-examples',
      builder: (context, state) => const ARExamplesScreen(),
    ),
    GoRoute(
      path: '/plane-detection',
      builder: (context, state) => const PlaneDetectionScreen(),
    ),
    GoRoute(
      path: '/face-mask',
      builder: (context, state) => const FaceMaskScreen(),
    ),
    GoRoute(
      path: '/ring-try-on',
      builder: (context, state) => const RingTryOnScreen(),
    ),
    GoRoute(
      path: '/body-tracking',
      builder: (context, state) => const BodyTrackingScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AR Examples',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
        ),
      ),
      routerConfig: _router,
    );
  }
}
