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
        body: const Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.cleaning_services_outlined),
                  text: 'Housekeeping',
                ),
                Tab(icon: Icon(Icons.build_outlined), text: 'Maintenance'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [HousekeepingScreen(), MaintenanceScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
