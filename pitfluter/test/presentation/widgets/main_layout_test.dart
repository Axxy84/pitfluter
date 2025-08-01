import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/presentation/widgets/main_layout.dart';

void main() {
  group('MainLayout Widget Tests', () {
    testWidgets('should display sidebar with navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      expect(find.text('PitFlutter'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('Produtos'), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('Estoque'), findsOneWidget);
      expect(find.text('Financeiro'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
    });

    testWidgets('should highlight current route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      final pedidosListTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Pedidos'),
          matching: find.byType(ListTile),
        ),
      );

      expect(pedidosListTile.selected, isTrue);
    });

    testWidgets('should call onNavigate when navigation item is tapped', (tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) => navigatedRoute = route,
          ),
        ),
      );

      await tester.tap(find.text('Produtos'));
      expect(navigatedRoute, equals('/produtos'));
    });

    testWidgets('should display body content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body Content'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      expect(find.text('Test Body Content'), findsOneWidget);
    });

    testWidgets('should use correct colors for theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      // Check if sidebar has correct background color
      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.backgroundColor, equals(const Color(0xFF7C2D12)));
    });

    testWidgets('should display navigation icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.inventory), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should be responsive on desktop', (tester) async {
      // Set a large screen size to simulate desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      // On desktop, sidebar should be permanently visible
      expect(find.byType(Drawer), findsOneWidget);
      
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display app logo/title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      expect(find.text('PitFlutter'), findsOneWidget);
      expect(find.byIcon(Icons.local_pizza), findsOneWidget);
    });

    testWidgets('should be accessible with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Menu de navegação principal'),
        findsOneWidget,
      );
    });

    testWidgets('should show user info section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
            userName: 'João Silva',
            userEmail: 'joao@email.com',
          ),
        ),
      );

      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('joao@email.com'), findsOneWidget);
    });

    testWidgets('should display logout button', (tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MainLayout(
            body: const Text('Test Body'),
            currentRoute: '/pedidos',
            onNavigate: (route) {},
            onLogout: () => logoutCalled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.logout));
      expect(logoutCalled, isTrue);
    });
  });
}