import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/categoria.dart';

void main() {
  group('Categoria Entity', () {
    test('should create Categoria with required properties', () {
      // arrange
      const categoria = Categoria(
        id: 1,
        nome: 'Pizzas',
        descricao: 'Categoría de pizzas variadas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(categoria.id, 1);
      expect(categoria.nome, 'Pizzas');
      expect(categoria.descricao, 'Categoría de pizzas variadas');
      expect(categoria.ativo, true);
      expect(categoria.ordem, 1);
      expect(categoria.dataCadastro, '2024-01-01T10:00:00Z');
      expect(categoria.ultimaAtualizacao, '2024-01-01T10:00:00Z');
    });

    test('should create Categoria with optional fields null', () {
      // arrange
      const categoria = Categoria(
        id: 1,
        nome: 'Pizzas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(categoria.descricao, null);
    });

    test('should support copyWith method', () {
      // arrange
      const categoria = Categoria(
        id: 1,
        nome: 'Pizzas',
        descricao: 'Categoría original',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final categoriaAtualizada = categoria.copyWith(
        nome: 'Pizzas Premium',
        ativo: false,
      );

      // assert
      expect(categoriaAtualizada.id, 1);
      expect(categoriaAtualizada.nome, 'Pizzas Premium');
      expect(categoriaAtualizada.descricao, 'Categoría original');
      expect(categoriaAtualizada.ativo, false);
      expect(categoriaAtualizada.ordem, 1);
    });

    test('should support equality comparison', () {
      // arrange
      const categoria1 = Categoria(
        id: 1,
        nome: 'Pizzas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const categoria2 = Categoria(
        id: 1,
        nome: 'Pizzas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const categoria3 = Categoria(
        id: 2,
        nome: 'Bebidas',
        ativo: true,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(categoria1, categoria2);
      expect(categoria1, isNot(categoria3));
    });

    test('should have proper toString representation', () {
      // arrange
      const categoria = Categoria(
        id: 1,
        nome: 'Pizzas',
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final stringRepresentation = categoria.toString();

      // assert
      expect(stringRepresentation, contains('Categoria'));
      expect(stringRepresentation, contains('id: 1'));
      expect(stringRepresentation, contains('nome: Pizzas'));
    });
  });
}