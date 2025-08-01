import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/produto_preco.dart';

void main() {
  group('ProdutoPreco Entity', () {
    test('should create ProdutoPreco with required properties', () {
      // arrange
      const produtoPreco = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        precoPromocional: 22.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoPreco.id, 1);
      expect(produtoPreco.produtoId, 1);
      expect(produtoPreco.tamanhoId, 1);
      expect(produtoPreco.preco, 25.90);
      expect(produtoPreco.precoPromocional, 22.90);
      expect(produtoPreco.ativo, true);
      expect(produtoPreco.dataCadastro, '2024-01-01T10:00:00Z');
      expect(produtoPreco.ultimaAtualizacao, '2024-01-01T10:00:00Z');
    });

    test('should create ProdutoPreco with optional promotional price null', () {
      // arrange
      const produtoPreco = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoPreco.precoPromocional, null);
    });

    test('should return promotional price when available', () {
      // arrange
      const produtoPrecoComDesconto = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        precoPromocional: 22.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produtoPrecoSemDesconto = ProdutoPreco(
        id: 2,
        produtoId: 1,
        tamanhoId: 2,
        preco: 30.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoPrecoComDesconto.precoFinal, 22.90);
      expect(produtoPrecoSemDesconto.precoFinal, 30.90);
    });

    test('should check if has promotional price', () {
      // arrange
      const produtoPrecoComDesconto = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        precoPromocional: 22.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produtoPrecoSemDesconto = ProdutoPreco(
        id: 2,
        produtoId: 1,
        tamanhoId: 2,
        preco: 30.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoPrecoComDesconto.temPromocao, true);
      expect(produtoPrecoSemDesconto.temPromocao, false);
    });

    test('should calculate discount percentage', () {
      // arrange
      const produtoPreco = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 100.0,
        precoPromocional: 80.0,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final desconto = produtoPreco.percentualDesconto;

      // assert
      expect(desconto, 20.0);
    });

    test('should support copyWith method', () {
      // arrange
      const produtoPreco = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final produtoPrecoAtualizado = produtoPreco.copyWith(
        preco: 30.90,
        precoPromocional: 27.90,
        ativo: false,
      );

      // assert
      expect(produtoPrecoAtualizado.id, 1);
      expect(produtoPrecoAtualizado.produtoId, 1);
      expect(produtoPrecoAtualizado.tamanhoId, 1);
      expect(produtoPrecoAtualizado.preco, 30.90);
      expect(produtoPrecoAtualizado.precoPromocional, 27.90);
      expect(produtoPrecoAtualizado.ativo, false);
    });

    test('should support equality comparison', () {
      // arrange
      const produtoPreco1 = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produtoPreco2 = ProdutoPreco(
        id: 1,
        produtoId: 1,
        tamanhoId: 1,
        preco: 25.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const produtoPreco3 = ProdutoPreco(
        id: 2,
        produtoId: 1,
        tamanhoId: 2,
        preco: 30.90,
        ativo: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(produtoPreco1, produtoPreco2);
      expect(produtoPreco1, isNot(produtoPreco3));
    });
  });
}