import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../core/data/supabase_client_provider.dart';
import 'app.dart';

/// Initializes application services and global error boundaries before running the root widget.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Flutter framework error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('BedLink Framework Error: ${details.exceptionAsString()}');
  };

  // Configure platform asynchronous error handling
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('BedLink Uncaught Error: $error\n$stack');
    return true;
  };

  // Resolve environment configuration and initialize Supabase if configured
  final supabaseConfig = SupabaseConfig.fromEnvironment();
  await initializeSupabase(supabaseConfig);

  runApp(
    ProviderScope(
      overrides: [
        supabaseConfigProvider.overrideWithValue(supabaseConfig),
      ],
      child: const BedLinkApp(),
    ),
  );
}
