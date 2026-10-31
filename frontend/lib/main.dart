import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'shared/providers/storage_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent storage
  final storageService = await StorageService.init();

  // Initialize Supabase Flutter SDK
  await SupabaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const LegalHelperApp(),
    ),
  );
}
