import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/pedidos_screen.dart';
import 'presentation/screens/produtos_screen.dart';
import 'presentation/screens/novo_pedido_screen.dart';
import 'presentation/screens/caixa_screen.dart';
import 'presentation/screens/historico_caixas_screen.dart';
import 'presentation/layouts/main_layout.dart';
import 'presentation/blocs/pedidos_bloc.dart';
import 'data/repositories/pedido_repository_impl.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PedidosBloc(
            repository: PedidoRepositoryImpl(),
          )..add(CarregarPedidos()),
        ),
      ],
      child: MaterialApp(
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
          '/': (context) => const MainLayout(), // Usando MainLayout com sidebar fixa
          '/pedidos': (context) => const PedidosScreen(),
          '/produtos': (context) => const ProdutosScreen(),
          '/caixa': (context) => const CaixaScreen(),
          '/historico-caixas': (context) => const HistoricoCaixasScreen(),
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
      ),
    );
  }
}

