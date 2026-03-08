import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hms_app/screens/housekeeping/housekeeping_screen.dart';
import 'package:hms_app/screens/maintenance/maintenance_screen.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: const Text('Operations'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.cleaning_services_outlined), text: 'Housekeeping'),
                      Tab(icon: Icon(Icons.build_outlined), text: 'Maintenance'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            HousekeepingScreen(),
            MaintenanceScreen(),
          ],
        ),
      ),
    );
  }
}
