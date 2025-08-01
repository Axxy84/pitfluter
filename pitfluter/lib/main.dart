import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/pedidos_screen.dart';
import 'presentation/modals/novo_pedido_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize Supabase (opcional para demo)
  // await Supabase.initialize(
  //   url: SupabaseConstants.supabaseUrl,
  //   anonKey: SupabaseConstants.supabaseAnonKey,
  // );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizzaria Sistema',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC2626), // Vermelho pizzaria
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFDC2626),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/pedidos': (context) => const PedidosScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/novo-pedido') {
          return MaterialPageRoute(
            builder: (context) => const NovoPedidoModal(),
            fullscreenDialog: true,
          );
        }
        return null;
      },
    );
  }
}

