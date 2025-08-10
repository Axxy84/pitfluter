import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/screens/novo_pedido_screen.dart';
import 'presentation/screens/caixa_screen.dart';
import 'presentation/screens/historico_caixas_screen.dart';
import 'presentation/screens/lista_pedidos_screen.dart';
import 'presentation/screens/mesas_abertas_screen.dart';
import 'presentation/screens/inicial_screen.dart';
import 'presentation/screens/price_editor_screen.dart';
import 'presentation/layouts/main_layout.dart';
import 'core/constants/supabase_constants.dart';

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

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

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
      debugShowCheckedModeBanner: false, // Remove a tag DEBUG
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
        '/': (context) =>
            const InicialScreen(), // Tela inicial que verifica o caixa
        '/main': (context) =>
            const MainLayout(), // Layout principal após verificação
        '/pedidos': (context) => const ListaPedidosScreen(),
        '/lista-pedidos': (context) => const ListaPedidosScreen(),
        // '/produtos': (context) => const ProdutosScreen(), // removida para evitar duplicidade
        '/caixa': (context) => const CaixaScreen(),
        '/historico-caixas': (context) => const HistoricoCaixasScreen(),
        '/mesas-abertas': (context) => const MesasAbertasScreen(),
        '/editar-precos': (context) => const PriceEditorScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/novo-pedido') {
          return MaterialPageRoute(
            builder: (context) => const NovoPedidoScreen(),
            fullscreenDialog: true,
          );
        }
        return null;
      },
    );
  }
}
