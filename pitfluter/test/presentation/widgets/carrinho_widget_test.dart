import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/produto.dart';
import 'package:pitfluter/domain/entities/tamanho.dart';
import 'package:pitfluter/presentation/widgets/carrinho_widget.dart';

void main() {
  group('CarrinhoWidget Widget Tests', () {
    const mockProduto = Produto(
      id: 1,
      nome: 'Pizza Margherita',
      categoriaId: 1,
      ativo: true,
      tempoPreparoMinutos: 30,
      ordem: 1,
      dataCadastro: '2024-01-01T10:00:00Z',
      ultimaAtualizacao: '2024-01-01T10:00:00Z',
    );

    const mockTamanho = Tamanho(
      id: 1,
      nome: 'Média',
      fatorMultiplicador: 1.0,
      ativo: true,
      ordem: 1,
      dataCadastro: '2024-01-01T10:00:00Z',
      ultimaAtualizacao: '2024-01-01T10:00:00Z',
    );

    final mockItens = [
      CarrinhoItem(
        produto: mockProduto,
        tamanho: mockTamanho,
        quantidade: 2,
        precoUnitario: 25.90,
      ),
    ];

    testWidgets('should display cart items correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(find.text('Carrinho'), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Média'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should calculate total correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(find.text('R\$ 51,80'), findsOneWidget); // 2 x 25.90
    });

    testWidgets('should show empty state when no items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: const [],
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(find.text('Carrinho vazio'), findsOneWidget);
      expect(find.text('Adicione produtos ao carrinho'), findsOneWidget);
    });

    testWidgets('should call onQuantidadeChanged when quantity is changed', (tester) async {
      CarrinhoItem? changedItem;
      int? newQuantidade;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {
                changedItem = item;
                newQuantidade = quantidade;
              },
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      // Tap increment button
      await tester.tap(find.byIcon(Icons.add));
      
      expect(changedItem, equals(mockItens[0]));
      expect(newQuantidade, equals(3));
    });

    testWidgets('should call onItemRemoved when remove button is tapped', (tester) async {
      CarrinhoItem? removedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) => removedItem = item,
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      expect(removedItem, equals(mockItens[0]));
    });

    testWidgets('should call onFinalizarPedido when finalize button is tapped', (tester) async {
      bool finalizarCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () => finalizarCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finalizar Pedido'));
      expect(finalizarCalled, isTrue);
    });

    testWidgets('should disable finalize button when cart is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: const [],
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should prevent quantity from going below 1', (tester) async {
      final singleItem = [
        CarrinhoItem(
          produto: mockProduto,
          tamanho: mockTamanho,
          quantidade: 1,
          precoUnitario: 25.90,
        ),
      ];

      int? newQuantidade;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: singleItem,
              onQuantidadeChanged: (item, quantidade) {
                newQuantidade = quantidade;
              },
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      // Try to decrement below 1
      await tester.tap(find.byIcon(Icons.remove));
      
      // Should not call onQuantidadeChanged with 0
      expect(newQuantidade, isNull);
    });

    testWidgets('should be accessible with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Carrinho de compras'),
        findsOneWidget,
      );
    });

    testWidgets('should display item subtotal correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(find.text('R\$ 51,80'), findsOneWidget); // 2 x 25.90
    });

    testWidgets('should show item count in header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarrinhoWidget(
              itens: mockItens,
              onQuantidadeChanged: (item, quantidade) {},
              onItemRemoved: (item) {},
              onFinalizarPedido: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('(2 itens)'), findsOneWidget);
    });
  });
}