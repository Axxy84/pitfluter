import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/cliente.dart';
import 'package:pitfluter/presentation/widgets/cliente_search_field.dart';

void main() {
  group('ClienteSearchField Widget Tests', () {
    final mockClientes = [
      const Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '(11) 99999-9999',
        email: 'joao@email.com',
        ativo: true,
        dataCadastro: DateTime.parse('2024-01-01T10:00:00Z'),
        ultimaAtualizacao: DateTime.parse('2024-01-01T10:00:00Z'),
      ),
      const Cliente(
        id: 2,
        nome: 'Maria Santos',
        telefone: '(11) 88888-8888',
        email: 'maria@email.com',
        ativo: true,
        dataCadastro: DateTime.parse('2024-01-01T10:00:00Z'),
        ultimaAtualizacao: DateTime.parse('2024-01-01T10:00:00Z'),
      ),
    ];

    testWidgets('should display search field correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar cliente...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show suggestions when typing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      // Type in search field
      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350)); // Wait for debounce

      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('(11) 99999-9999'), findsOneWidget);
    });

    testWidgets('should implement debounce correctly', (tester) async {
      int searchCallCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async {
                searchCallCount++;
                return mockClientes;
              },
            ),
          ),
        ),
      );

      // Type multiple characters quickly
      await tester.enterText(find.byType(TextField), 'J');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'Jo');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350));

      // Should only call search once after debounce
      expect(searchCallCount, equals(1));
    });

    testWidgets('should call onClienteSelected when suggestion is tapped', (tester) async {
      Cliente? selectedCliente;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) => selectedCliente = cliente,
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.text('João Silva'));
      
      expect(selectedCliente, equals(mockClientes[0]));
    });

    testWidgets('should show phone number in suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('(11) 99999-9999'), findsOneWidget);
    });

    testWidgets('should show no results message when no clients found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => [],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Cliente inexistente');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Nenhum cliente encontrado'), findsOneWidget);
    });

    testWidgets('should clear suggestions when field is cleared', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      // Type and show suggestions
      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('João Silva'), findsOneWidget);

      // Clear field
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('João Silva'), findsNothing);
    });

    testWidgets('should be accessible with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async => mockClientes,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Campo de busca de clientes'),
        findsOneWidget,
      );
    });

    testWidgets('should show loading indicator while searching', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClienteSearchField(
              onClienteSelected: (cliente) {},
              searchClientes: (query) async {
                await Future.delayed(const Duration(milliseconds: 100));
                return mockClientes;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}