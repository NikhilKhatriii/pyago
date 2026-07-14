import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/app_shell.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/communities/presentation/screens/communities_screen.dart';
import '../../features/create/presentation/screens/create_screen.dart';
import '../../features/create/domain/models/draft_model.dart';
import '../../features/drafts/presentation/screens/drafts_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/comments_screen.dart';
import '../../features/home/domain/models/post_model.dart';
import '../../features/chat/presentation/screens/chat_thread_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration for the whole app. Auth state gates every
/// protected route via [redirect]; the bottom-nav shell wraps the five
/// top-level destinations via [StatefulShellRoute].
final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  
  // Create a Listenable that triggers whenever the AuthController state changes.
  // This is more reliable than listening to a derived provider.
  final listenable = _StateNotifierListenable(authController);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Enable logs to help debug navigation
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final loc = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return loc == '/splash' ? null : '/splash';
      }

      final publicRoutes = {
        '/splash', '/welcome', '/onboarding', '/login', '/register',
        '/forgot-password', '/otp-verification', '/complete-profile',
      };

      if (status == AuthStatus.unauthenticated) {
        // If we just finished loading and are at splash, go to welcome.
        if (loc == '/splash') return '/welcome';
        return publicRoutes.contains(loc) ? null : '/welcome';
      }

      // Authenticated: keep users out of the auth flow.
      if (loc == '/splash' || loc == '/welcome' || loc == '/login' || loc == '/register') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/welcome', name: 'welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondary, child) =>
              SlideTransition(
            position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut))
                .animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
        ),
      ),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/otp-verification', name: 'otp-verification', builder: (context, state) => const OtpVerificationScreen()),
      GoRoute(path: '/complete-profile', name: 'complete-profile', builder: (context, state) => const CompleteProfileScreen()),

      GoRoute(path: '/search', name: 'search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/notifications', name: 'notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/chat', name: 'chat', builder: (context, state) => const ChatListScreen()),
      GoRoute(
        path: '/chat/:threadId',
        name: 'chat-thread',
        builder: (context, state) => ChatThreadScreen(
          threadId: state.pathParameters['threadId']!,
          title: (state.extra as Map?)?['title'] as String? ?? 'Chat',
        ),
      ),
      GoRoute(
        path: '/post/:id/comments',
        name: 'comments',
        builder: (context, state) => CommentsScreen(post: state.extra as PostModel),
      ),
      GoRoute(path: '/bookmarks', name: 'bookmarks', builder: (context, state) => const BookmarksScreen()),
      GoRoute(path: '/drafts', name: 'drafts', builder: (context, state) => const DraftsScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/explore', name: 'explore', builder: (context, state) => const ExploreScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                name: 'create',
                builder: (context, state) => CreateScreen(existingDraft: state.extra as DraftModel?),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/communities', name: 'communities', builder: (context, state) => const CommunitiesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
});

/// A simple [Listenable] that triggers when a [StateNotifier] changes.
class _StateNotifierListenable extends ChangeNotifier {
  _StateNotifierListenable(StateNotifier notifier) {
    notifier.addListener((_) => notifyListeners());
  }
}
