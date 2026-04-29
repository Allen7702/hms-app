import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  await ConnectivityService().init();
  runApp(
    const ProviderScope(
      child: HmsApp(),
    ),
  );
}
