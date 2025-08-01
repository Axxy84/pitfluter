import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/produto.dart';
import 'package:pitfluter/domain/entities/categoria.dart';
import 'package:pitfluter/domain/entities/tamanho.dart';
import 'package:pitfluter/presentation/widgets/produto_selector.dart';

void main() {
  group('ProdutoSelector Widget Tests', () {
    final mockCategorias = [
      const Categoria(
        id: 1,
        nome: 'Pizzas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
      const Categoria(
        id: 2,
        nome: 'Bebidas',
        ativo: true,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
    ];

    final mockProdutos = [
      const Produto(
        id: 1,
        nome: 'Pizza Margherita',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 30,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
      const Produto(
        id: 2,
        nome: 'Coca Cola',
        categoriaId: 2,
        ativo: true,
        tempoPreparoMinutos: 5,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
    ];

    final mockTamanhos = [
      const Tamanho(
        id: 1,
        nome: 'Pequena',
        fatorMultiplicador: 0.8,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
      const Tamanho(
        id: 2,
        nome: 'Média',
        fatorMultiplicador: 1.0,
        ativo: true,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
      const Tamanho(
        id: 3,
        nome: 'Grande',
        fatorMultiplicador: 1.5,
        ativo: true,
        ordem: 3,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      ),
    ];

    testWidgets('should display category tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(find.text('Pizzas'), findsOneWidget);
      expect(find.text('Bebidas'), findsOneWidget);
    });

    testWidgets('should display products grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(find.text('Pizza Margherita'), findsOneWidget);
    });

    testWidgets('should filter products by category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      // Tap on Bebidas category
      await tester.tap(find.text('Bebidas'));
      await tester.pumpAndSettle();

      expect(find.text('Coca Cola'), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsNothing);
    });

    testWidgets('should show size selection dialog when product is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pizza Margherita'));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar Tamanho'), findsOneWidget);
      expect(find.text('Pequena'), findsOneWidget);
      expect(find.text('Média'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
    });

    testWidgets('should call onProdutoSelected when size is selected', (tester) async {
      Produto? selectedProduto;
      Tamanho? selectedTamanho;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {
                selectedProduto = produto;
                selectedTamanho = tamanho;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pizza Margherita'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Média'));
      await tester.pumpAndSettle();

      expect(selectedProduto, equals(mockProdutos[0]));
      expect(selectedTamanho, equals(mockTamanhos[1]));
    });

    testWidgets('should show half-and-half option for pizzas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
              allowHalfAndHalf: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pizza Margherita'));
      await tester.pumpAndSettle();

      expect(find.text('Meio a Meio'), findsOneWidget);
    });

    testWidgets('should display product images when available', (tester) async {
      final produtoComImagem = mockProdutos[0].copyWith(
        imagemUrl: 'https://example.com/pizza.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: [produtoComImagem],
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show placeholder when no image available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fastfood), findsAtLeastNWidgets(1));
    });

    testWidgets('should be accessible with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: mockProdutos,
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Seletor de produtos'),
        findsOneWidget,
      );
    });

    testWidgets('should show empty state when no products available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoSelector(
              categorias: mockCategorias,
              produtos: const [],
              tamanhos: mockTamanhos,
              onProdutoSelected: (produto, tamanho) {},
            ),
          ),
        ),
      );

      expect(find.text('Nenhum produto disponível'), findsOneWidget);
    });
  });
}