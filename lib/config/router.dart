import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/providers/auth_provider.dart';

// Screens
import 'package:hms_app/screens/auth/login_screen.dart';
import 'package:hms_app/screens/dashboard/dashboard_screen.dart';
import 'package:hms_app/screens/bookings/bookings_list_screen.dart';
import 'package:hms_app/screens/bookings/booking_detail_screen.dart';
import 'package:hms_app/screens/bookings/create_booking_screen.dart';
import 'package:hms_app/screens/rooms/rooms_list_screen.dart';
import 'package:hms_app/screens/guests/guests_list_screen.dart';
import 'package:hms_app/screens/operations/operations_screen.dart';
import 'package:hms_app/screens/billing/billing_screen.dart';
import 'package:hms_app/screens/inventory/inventory_screen.dart';
import 'package:hms_app/screens/calendar/calendar_screen.dart';
import 'package:hms_app/screens/reports/reports_screen.dart';
import 'package:hms_app/screens/audit/audit_screen.dart';
import 'package:hms_app/screens/notifications/notifications_screen.dart';
import 'package:hms_app/screens/settings/settings_screen.dart';
import 'package:hms_app/screens/more/more_screen.dart';
import 'package:hms_app/screens/shell/app_shell.dart';
import 'package:hms_app/screens/shell/seeding_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isLoginRoute = state.matchedLocation == '/login';
      if (isLoading) return null;
      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/';

      return null;
    },
    routes: [
      // Login
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => SeedingWrapper(
          child: AppShell(navigationShell: navigationShell),
        ),
        branches: [
          // Dashboard tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Bookings tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateBookingScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return BookingDetailScreen(bookingId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Rooms tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const RoomsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return RoomDetailScreen(roomId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Operations tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/operations',
                builder: (context, state) => const OperationsScreen(),
              ),
            ],
          ),

          // More tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // Secondary routes
      GoRoute(
        path: '/guests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GuestsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return GuestDetailScreen(guestId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/billing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BillingScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return InvoiceDetailScreen(invoiceId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/inventory',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/audit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuditScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
