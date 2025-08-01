import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/produto.dart';

void main() {
  group('Produto Entity', () {
    test('should create Produto with required properties', () {
      // arrange
      const produto = Produto(
        id: 1,
        nome: 'Pizza Margherita',
        descricao: 'Pizza com molho de tomate, mussarela e manjericão',
        categoriaId: 1,
        sku: 'PIZ001',
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produto.id, 1);
      expect(produto.nome, 'Pizza Margherita');
      expect(produto.descricao, 'Pizza com molho de tomate, mussarela e manjericão');
      expect(produto.categoriaId, 1);
      expect(produto.sku, 'PIZ001');
      expect(produto.ativo, true);
      expect(produto.tempoPreparoMinutos, 25);
      expect(produto.ordem, 1);
      expect(produto.dataCadastro, '2024-01-01T10:00:00Z');
      expect(produto.ultimaAtualizacao, '2024-01-01T10:00:00Z');
    });

    test('should create Produto with optional fields null', () {
      // arrange
      const produto = Produto(
        id: 1,
        nome: 'Pizza Margherita',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produto.descricao, null);
      expect(produto.sku, null);
      expect(produto.imagemUrl, null);
      expect(produto.observacoes, null);
    });

    test('should check if product is available', () {
      // arrange
      const produtoAtivo = Produto(
        id: 1,
        nome: 'Pizza Margherita',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produtoInativo = Produto(
        id: 2,
        nome: 'Pizza Desativada',
        categoriaId: 1,
        ativo: false,
        tempoPreparoMinutos: 25,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoAtivo.estaDisponivel, true);
      expect(produtoInativo.estaDisponivel, false);
    });

    test('should support copyWith method', () {
      // arrange
      const produto = Produto(
        id: 1,
        nome: 'Pizza Original',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final produtoAtualizado = produto.copyWith(
        nome: 'Pizza Premium',
        ativo: false,
        tempoPreparoMinutos: 30,
      );

      // assert
      expect(produtoAtualizado.id, 1);
      expect(produtoAtualizado.nome, 'Pizza Premium');
      expect(produtoAtualizado.categoriaId, 1);
      expect(produtoAtualizado.ativo, false);
      expect(produtoAtualizado.tempoPreparoMinutos, 30);
      expect(produtoAtualizado.ordem, 1);
    });

    test('should support equality comparison', () {
      // arrange
      const produto1 = Produto(
        id: 1,
        nome: 'Pizza Margherita',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produto2 = Produto(
        id: 1,
        nome: 'Pizza Margherita',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 25,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produto3 = Produto(
        id: 2,
        nome: 'Pizza Calabresa',
        categoriaId: 1,
        ativo: true,
        tempoPreparoMinutos: 20,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produto1, produto2);
      expect(produto1, isNot(produto3));
    });
  });
}